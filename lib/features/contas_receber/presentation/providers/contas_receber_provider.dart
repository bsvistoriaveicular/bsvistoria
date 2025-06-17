import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bs_vistoria_veicular/features/contas_receber/domain/entities/conta_receber.dart';
import 'package:bs_vistoria_veicular/core/providers/notification_provider.dart';
import 'package:bs_vistoria_veicular/core/services/notification_service.dart';

final contasReceberProvider = StateNotifierProvider<ContasReceberNotifier,
    AsyncValue<List<ContaReceber>>>((ref) {
  return ContasReceberNotifier(ref);
});

class ContasReceberNotifier
    extends StateNotifier<AsyncValue<List<ContaReceber>>> {
  final Ref _ref;
  late final NotificationService _notificationService;

  ContasReceberNotifier(this._ref) : super(const AsyncValue.loading()) {
    _notificationService = _ref.read(notificationServiceProvider);
    _init();
  }

  final _supabase = Supabase.instance.client;

  Future<void> _init() async {
    try {
      final response = await _supabase
          .from('contas_receber')
          .select()
          .order('data_recebimento', ascending: false);

      final contas = (response as List)
          .map((json) => ContaReceber.fromJson(json))
          .toList();

      state = AsyncValue.data(contas);
      // Agendar notificações para contas de provisão
      final contasProvisao = contas.where((c) => c.tipo == 'Provisão').toList();
      _notificationService.scheduleFutureDueNotifications(
        contasAReceberProvisao: contasProvisao,
        contasAPagarProvisao: [], // Não há contas a pagar neste provedor
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> adicionarConta({
    required String descricao,
    required double valor,
    required String formaPagamento,
    required DateTime dataRecebimento,
    required String tipo,
    String? contatoCliente,
  }) async {
    try {
      final response = await _supabase.from('contas_receber').insert({
        'descricao': descricao,
        'valor': valor,
        'forma_pagamento': formaPagamento,
        'data_recebimento': dataRecebimento.toIso8601String(),
        'tipo': tipo,
        'contato_cliente': contatoCliente,
      }).select();

      final novaConta = ContaReceber.fromJson(response.first);
      state.whenData((contas) {
        final updatedContas = [novaConta, ...contas];
        state = AsyncValue.data(updatedContas);
        final contasProvisao =
            updatedContas.where((c) => c.tipo == 'Provisão').toList();
        _notificationService.scheduleFutureDueNotifications(
          contasAReceberProvisao: contasProvisao,
          contasAPagarProvisao: [],
        );
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> removerConta(int id) async {
    try {
      await _supabase.from('contas_receber').delete().eq('id', id);

      state.whenData((contas) {
        final updatedContas = contas.where((conta) => conta.id != id).toList();
        state = AsyncValue.data(updatedContas);
        final contasProvisao =
            updatedContas.where((c) => c.tipo == 'Provisão').toList();
        _notificationService.scheduleFutureDueNotifications(
          contasAReceberProvisao: contasProvisao,
          contasAPagarProvisao: [],
        );
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
