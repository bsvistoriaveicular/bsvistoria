class ContaReceber {
  final int id;
  final String descricao;
  final double valor;
  final String formaPagamento;
  final DateTime dataRecebimento;
  final String tipo;
  final String? contatoCliente;
  final DateTime criadoEm;

  ContaReceber({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.formaPagamento,
    required this.dataRecebimento,
    required this.tipo,
    this.contatoCliente,
    required this.criadoEm,
  });

  factory ContaReceber.fromJson(Map<String, dynamic> json) {
    return ContaReceber(
      id: json['id'] as int,
      descricao: json['descricao'] as String,
      valor: (json['valor'] as num).toDouble(),
      formaPagamento: json['forma_pagamento'] as String,
      dataRecebimento: DateTime.parse(json['data_recebimento'] as String),
      tipo: json['tipo'] as String,
      contatoCliente: json['contato_cliente'] as String?,
      criadoEm: DateTime.parse(json['criado_em'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'valor': valor,
      'forma_pagamento': formaPagamento,
      'data_recebimento': dataRecebimento.toIso8601String(),
      'tipo': tipo,
      'contato_cliente': contatoCliente,
      'criado_em': criadoEm.toIso8601String(),
    };
  }
}
