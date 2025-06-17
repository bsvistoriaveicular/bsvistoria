import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bs_vistoria_veicular/features/contas_pagar/domain/entities/conta_pagar.dart';
import 'package:bs_vistoria_veicular/core/providers/notification_provider.dart';
import 'package:bs_vistoria_veicular/core/services/notification_service.dart';

final contasPagarProvider =
    StateNotifierProvider<ContasPagarNotifier, AsyncValue<List<ContaPagar>>>(
        (ref) {
  return ContasPagarNotifier(ref);
});

class ContasPagarNotifier extends StateNotifier<AsyncValue<List<ContaPagar>>> {
  final Ref _ref;
  late final NotificationService _notificationService;

  ContasPagarNotifier(this._ref) : super(const AsyncValue.loading()) {
    _notificationService = _ref.read(notificationServiceProvider);
    _init();
  }

  final _supabase = Supabase.instance.client;

  Future<void> _init() async {
    try {
      final response = await _supabase
          .from('contas_pagar')
          .select()
          .order('data_pagamento', ascending: false);

      final contas =
          (response as List).map((json) => ContaPagar.fromJson(json)).toList();

      state = AsyncValue.data(contas);
      // Agendar notificações para contas de provisão
      final contasProvisao = contas.where((c) => c.tipo == 'Provisão').toList();
      _notificationService.scheduleFutureDueNotifications(
        contasAPagarProvisao: contasProvisao,
        contasAReceberProvisao: [], // Não há contas a receber neste provedor
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> adicionarConta({
    required String descricao,
    required double valor,
    required String formaPagamento,
    required DateTime dataPagamento,
    required String tipo,
    String? fornecedor,
  }) async {
    try {
      final response = await _supabase.from('contas_pagar').insert({
        'descricao': descricao,
        'valor': valor,
        'forma_pagamento': formaPagamento,
        'data_pagamento': dataPagamento.toIso8601String(),
        'tipo': tipo,
        'fornecedor': fornecedor,
      }).select();

      final novaConta = ContaPagar.fromJson(response.first);
      state.whenData((contas) {
        final updatedContas = [novaConta, ...contas];
        state = AsyncValue.data(updatedContas);
        final contasProvisao =
            updatedContas.where((c) => c.tipo == 'Provisão').toList();
        _notificationService.scheduleFutureDueNotifications(
          contasAPagarProvisao: contasProvisao,
          contasAReceberProvisao: [],
        );
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> removerConta(int id) async {
    try {
      await _supabase.from('contas_pagar').delete().eq('id', id);

      state.whenData((contas) {
        final updatedContas = contas.where((conta) => conta.id != id).toList();
        state = AsyncValue.data(updatedContas);
        final contasProvisao =
            updatedContas.where((c) => c.tipo == 'Provisão').toList();
        _notificationService.scheduleFutureDueNotifications(
          contasAPagarProvisao: contasProvisao,
          contasAReceberProvisao: [],
        );
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
