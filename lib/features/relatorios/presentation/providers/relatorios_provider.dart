import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:bs_vistoria_veicular/features/contas_receber/domain/entities/conta_receber.dart';
import 'package:bs_vistoria_veicular/features/contas_pagar/domain/entities/conta_pagar.dart';

class RelatorioFinanceiro {
  final double totalEntradas;
  final double totalSaidas;
  final double saldo;
  final List<ContaReceber> contasRecebidas;
  final List<ContaReceber> contasAReceberProvisao;
  final List<ContaPagar> contasPagas;
  final List<ContaPagar> contasAPagarProvisao;

  RelatorioFinanceiro({
    required this.totalEntradas,
    required this.totalSaidas,
    required this.saldo,
    required this.contasRecebidas,
    required this.contasAReceberProvisao,
    required this.contasPagas,
    required this.contasAPagarProvisao,
  });
}

final relatoriosProvider = FutureProvider.family<RelatorioFinanceiro,
    ({DateTime dataInicio, DateTime dataFim})>((ref, params) async {
  final supabase = Supabase.instance.client;

  // Buscar contas a receber
  final List<dynamic> contasReceberRaw = await supabase
      .from('contas_receber')
      .select()
      .gte('data_recebimento', params.dataInicio.toIso8601String())
      .lte('data_recebimento', params.dataFim.toIso8601String());

  // Buscar contas a pagar
  final List<dynamic> contasPagarRaw = await supabase
      .from('contas_pagar')
      .select()
      .gte('data_pagamento', params.dataInicio.toIso8601String())
      .lte('data_pagamento', params.dataFim.toIso8601String());

  double totalEntradas = 0;
  double totalSaidas = 0;

  final List<ContaReceber> contasRecebidas = [];
  final List<ContaReceber> contasAReceberProvisao = [];

  for (var contaJson in contasReceberRaw) {
    final conta = ContaReceber.fromJson(contaJson);
    if (conta.tipo == 'entrada') {
      totalEntradas += conta.valor;
      contasRecebidas.add(conta);
    } else if (conta.tipo == 'provisao') {
      contasAReceberProvisao.add(conta);
    }
  }

  final List<ContaPagar> contasPagas = [];
  final List<ContaPagar> contasAPagarProvisao = [];

  for (var contaJson in contasPagarRaw) {
    final conta = ContaPagar.fromJson(contaJson);
    if (conta.tipo == 'pago') {
      totalSaidas += conta.valor;
      contasPagas.add(conta);
    } else if (conta.tipo == 'provisao') {
      contasAPagarProvisao.add(conta);
    }
  }

  return RelatorioFinanceiro(
    totalEntradas: totalEntradas,
    totalSaidas: totalSaidas,
    saldo: totalEntradas - totalSaidas,
    contasRecebidas: contasRecebidas,
    contasAReceberProvisao: contasAReceberProvisao,
    contasPagas: contasPagas,
    contasAPagarProvisao: contasAPagarProvisao,
  );
});
