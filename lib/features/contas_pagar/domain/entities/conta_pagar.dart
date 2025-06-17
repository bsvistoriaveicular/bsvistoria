class ContaPagar {
  final int id;
  final String descricao;
  final double valor;
  final String formaPagamento;
  final DateTime dataPagamento;
  final String tipo;
  final String? fornecedor;
  final DateTime criadoEm;

  ContaPagar({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.formaPagamento,
    required this.dataPagamento,
    required this.tipo,
    this.fornecedor,
    required this.criadoEm,
  });

  factory ContaPagar.fromJson(Map<String, dynamic> json) {
    return ContaPagar(
      id: json['id'] as int,
      descricao: json['descricao'] as String,
      valor: (json['valor'] as num).toDouble(),
      formaPagamento: json['forma_pagamento'] as String,
      dataPagamento: DateTime.parse(json['data_pagamento'] as String),
      tipo: json['tipo'] as String,
      fornecedor: json['fornecedor'] as String?,
      criadoEm: DateTime.parse(json['criado_em'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'valor': valor,
      'forma_pagamento': formaPagamento,
      'data_pagamento': dataPagamento.toIso8601String(),
      'tipo': tipo,
      'fornecedor': fornecedor,
      'criado_em': criadoEm.toIso8601String(),
    };
  }
}
