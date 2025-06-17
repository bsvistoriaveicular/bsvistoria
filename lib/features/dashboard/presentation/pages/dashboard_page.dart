import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bs_vistoria_veicular/features/auth/presentation/providers/auth_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('B&S Vistoria Veicular'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      drawer: NavigationDrawer(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.amber,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_car,
                  size: 48,
                  color: Colors.black,
                ),
                SizedBox(height: 8),
                Text(
                  'B&S Vistoria Veicular',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Contas a Receber'),
            onTap: () => context.go('/contas-receber'),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.payment),
            label: const Text('Contas a Pagar'),
            onTap: () => context.go('/contas-pagar'),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.bar_chart),
            label: const Text('Relatórios'),
            onTap: () => context.go('/relatorios'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 550, // Ajustado para 550
            ),
            const SizedBox(height: 24),
            const Text(
              'Bem-vindo ao Sistema de Gestão Financeira',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationDrawerDestination extends StatelessWidget {
  final Widget icon;
  final Widget label;
  final VoidCallback onTap;

  const NavigationDrawerDestination({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: label,
      onTap: onTap,
    );
  }
}
