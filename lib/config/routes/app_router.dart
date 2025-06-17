import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bs_vistoria_veicular/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:bs_vistoria_veicular/features/auth/presentation/pages/login_page.dart';
import 'package:bs_vistoria_veicular/features/contas_receber/presentation/pages/contas_receber_page.dart';
import 'package:bs_vistoria_veicular/features/contas_pagar/presentation/pages/contas_pagar_page.dart';
import 'package:bs_vistoria_veicular/features/relatorios/presentation/pages/relatorios_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/contas-receber',
        builder: (context, state) => const ContasReceberPage(),
      ),
      GoRoute(
        path: '/contas-pagar',
        builder: (context, state) => const ContasPagarPage(),
      ),
      GoRoute(
        path: '/relatorios',
        builder: (context, state) => const RelatoriosPage(),
      ),
    ],
  );
});
