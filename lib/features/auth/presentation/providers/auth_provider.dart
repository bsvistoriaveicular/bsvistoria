import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.data(null)) {
    _init();
  }

  final _supabase = Supabase.instance.client;

  void _init() {
    state = AsyncValue.data(_supabase.auth.currentUser);
    _supabase.auth.onAuthStateChange.listen((event) {
      state = AsyncValue.data(event.session?.user);
    });
  }

  Future<void> login({
    required String identifier, // Pode ser email ou nome
    required String senha,
  }) async {
    try {
      state = const AsyncValue.loading();
      // ATENÇÃO: Esta é uma implementação de login ALTAMENTE INSEGURA
      // e é usada APENAS para fins de demonstração, conforme solicitado.
      // Armazenar senhas em texto claro no banco de dados é uma grande
      // VULNERABILIDADE DE SEGURANÇA e NÃO DEVE SER FEITO EM PRODUÇÃO.
      // O sistema de autenticação padrão do Supabase (signInWithPassword)
      // deve ser usado para garantir a segurança das senhas.
      final response = await _supabase
          .from('usuarios')
          .select()
          .eq('senha', senha)
          .or('email.ilike.${identifier.toLowerCase()},nome.ilike.${identifier.toLowerCase()}') // Converte explicitamente para minúsculas para garantir a comparação case-insensitive
          .single();

      if (response != null) {
        // Se a resposta não for nula, um usuário foi encontrado
        // Não há um objeto User do Supabase Auth para este tipo de login.
        state = const AsyncValue.data(null);
      } else {
        // Se nenhum usuário for encontrado, lançar uma exceção de credenciais inválidas
        throw Exception(
            'Credenciais inválidas. Verifique seu e-mail/nome de usuário e senha.');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      state = const AsyncValue.loading();
      await _supabase.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
