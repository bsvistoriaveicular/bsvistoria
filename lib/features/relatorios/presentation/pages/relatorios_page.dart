import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bs_vistoria_veicular/features/relatorios/presentation/providers/relatorios_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart' as intl;
import 'package:bs_vistoria_veicular/features/contas_receber/domain/entities/conta_receber.dart';
import 'package:bs_vistoria_veicular/features/contas_pagar/domain/entities/conta_pagar.dart';

class RelatoriosPage extends ConsumerStatefulWidget {
  const RelatoriosPage({super.key});

  @override
  ConsumerState<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends ConsumerState<RelatoriosPage> {
  DateTime _dataInicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime _dataFim = DateTime.now();

  Future<void> _generatePdf(RelatorioFinanceiro relatorio) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(level: 0, text: 'Relatório Financeiro'),
          pw.Paragraph(
              text:
                  'Período: ${intl.DateFormat('dd/MM/yyyy').format(_dataInicio)} - ${intl.DateFormat('dd/MM/yyyy').format(_dataFim)}'),
          pw.Divider(),
          pw.Header(level: 1, text: 'Resumo Financeiro'),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total de Entradas:'),
              pw.Text('R\$ ${relatorio.totalEntradas.toStringAsFixed(2)}'),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total de Saídas:'),
              pw.Text('R\$ ${relatorio.totalSaidas.toStringAsFixed(2)}'),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Saldo:'),
              pw.Text(
                'R\$ ${relatorio.saldo.toStringAsFixed(2)}',
                style: pw.TextStyle(
                    color:
                        relatorio.saldo >= 0 ? PdfColors.green : PdfColors.red),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, text: 'Contas a Receber (Recebidas)'),
          pw.Table.fromTextArray(
            headers: [
              'Descrição',
              'Valor',
              'Forma Pagamento',
              'Data',
              'Contato'
            ],
            data: relatorio.contasRecebidas
                .map((conta) => [
                      conta.descricao,
                      'R\$ ${conta.valor.toStringAsFixed(2)}',
                      conta.formaPagamento,
                      intl.DateFormat('dd/MM/yyyy')
                          .format(conta.dataRecebimento),
                      conta.contatoCliente ?? '',
                    ])
                .toList(),
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.center,
              4: pw.Alignment.centerLeft,
            },
          ),
          if (relatorio.contasAReceberProvisao.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),
                pw.Header(level: 1, text: 'Contas a Receber (Provisão)'),
                pw.Table.fromTextArray(
                  headers: [
                    'Descrição',
                    'Valor',
                    'Forma Pagamento',
                    'Data',
                    'Contato'
                  ],
                  data: relatorio.contasAReceberProvisao
                      .map((conta) => [
                            conta.descricao,
                            'R\$ ${conta.valor.toStringAsFixed(2)}',
                            conta.formaPagamento,
                            intl.DateFormat('dd/MM/yyyy')
                                .format(conta.dataRecebimento),
                            conta.contatoCliente ?? '',
                          ])
                      .toList(),
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.amber100),
                  cellHeight: 30,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerRight,
                    2: pw.Alignment.centerLeft,
                    3: pw.Alignment.center,
                    4: pw.Alignment.centerLeft,
                  },
                ),
              ],
            ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, text: 'Contas a Pagar (Pagas)'),
          pw.Table.fromTextArray(
            headers: [
              'Descrição',
              'Valor',
              'Forma Pagamento',
              'Data',
              'Fornecedor'
            ],
            data: relatorio.contasPagas
                .map((conta) => [
                      conta.descricao,
                      'R\$ ${conta.valor.toStringAsFixed(2)}',
                      conta.formaPagamento,
                      intl.DateFormat('dd/MM/yyyy').format(conta.dataPagamento),
                      conta.fornecedor ?? '',
                    ])
                .toList(),
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.center,
              4: pw.Alignment.centerLeft,
            },
          ),
          if (relatorio.contasAPagarProvisao.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),
                pw.Header(level: 1, text: 'Contas a Pagar (Provisão)'),
                pw.Table.fromTextArray(
                  headers: [
                    'Descrição',
                    'Valor',
                    'Forma Pagamento',
                    'Data',
                    'Fornecedor'
                  ],
                  data: relatorio.contasAPagarProvisao
                      .map((conta) => [
                            conta.descricao,
                            'R\$ ${conta.valor.toStringAsFixed(2)}',
                            conta.formaPagamento,
                            intl.DateFormat('dd/MM/yyyy')
                                .format(conta.dataPagamento),
                            conta.fornecedor ?? '',
                          ])
                      .toList(),
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.amber100),
                  cellHeight: 30,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerRight,
                    2: pw.Alignment.centerLeft,
                    3: pw.Alignment.center,
                    4: pw.Alignment.centerLeft,
                  },
                ),
              ],
            ),
        ],
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'relatorio_financeiro.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final relatorioAsync = ref.watch(relatoriosProvider((
      dataInicio: _dataInicio,
      dataFim: _dataFim,
    )));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: relatorioAsync.when(
              data: (relatorio) => () => _generatePdf(relatorio),
              loading: () => null,
              error: (error, stack) => null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Período',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectDate(context, true),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              'Início: ${intl.DateFormat('dd/MM/yyyy').format(_dataInicio)}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectDate(context, false),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              'Fim: ${intl.DateFormat('dd/MM/yyyy').format(_dataFim)}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            relatorioAsync.when(
              data: (relatorio) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumo Financeiro
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Resumo Financeiro',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const Divider(),
                            _buildSummaryRow(
                              context,
                              'Total de Entradas',
                              relatorio.totalEntradas,
                              Colors.green,
                              Icons.arrow_downward,
                            ),
                            _buildSummaryRow(
                              context,
                              'Total de Saídas',
                              relatorio.totalSaidas,
                              Colors.red,
                              Icons.arrow_upward,
                            ),
                            _buildSummaryRow(
                              context,
                              'Saldo Total',
                              relatorio.saldo,
                              relatorio.saldo >= 0 ? Colors.green : Colors.red,
                              relatorio.saldo >= 0
                                  ? Icons.account_balance_wallet
                                  : Icons.warning,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Contas a Receber (Recebidas)
                    _buildSectionHeader(
                        context, 'Contas a Receber (Recebidas)'),
                    const SizedBox(height: 8),
                    _buildDataTable(
                        context, relatorio.contasRecebidas, 'receber'),

                    if (relatorio.contasAReceberProvisao.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                              context, 'Contas a Receber (Provisão)'),
                          const SizedBox(height: 8),
                          _buildDataTable(context,
                              relatorio.contasAReceberProvisao, 'receber'),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // Contas a Pagar (Pagas)
                    _buildSectionHeader(context, 'Contas a Pagar (Pagas)'),
                    const SizedBox(height: 8),
                    _buildDataTable(context, relatorio.contasPagas, 'pagar'),

                    if (relatorio.contasAPagarProvisao.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                              context, 'Contas a Pagar (Provisão)'),
                          const SizedBox(height: 8),
                          _buildDataTable(
                              context, relatorio.contasAPagarProvisao, 'pagar'),
                        ],
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Erro ao carregar relatórios: $error')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String title,
    double value,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _buildDataTable<T>(
    BuildContext context,
    List<T> data,
    String type,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: _buildColumns(type),
        rows: _buildRows(data, type),
        headingRowColor: MaterialStateProperty.all(
            Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
        dataRowColor: MaterialStateProperty.all(
            Theme.of(context).colorScheme.surface.withOpacity(0.05)),
        border: TableBorder.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
    );
  }

  List<DataColumn> _buildColumns(String type) {
    if (type == 'receber') {
      return const [
        DataColumn(label: Text('Descrição')),
        DataColumn(label: Text('Valor'), numeric: true),
        DataColumn(label: Text('Forma Pagamento')),
        DataColumn(label: Text('Data')),
        DataColumn(label: Text('Contato')),
      ];
    } else {
      return const [
        DataColumn(label: Text('Descrição')),
        DataColumn(label: Text('Valor'), numeric: true),
        DataColumn(label: Text('Forma Pagamento')),
        DataColumn(label: Text('Data')),
        DataColumn(label: Text('Fornecedor')),
      ];
    }
  }

  List<DataRow> _buildRows<T>(List<T> data, String type) {
    if (type == 'receber') {
      return data.map((item) {
        final conta = item as ContaReceber;
        return DataRow(
          cells: [
            DataCell(Text(conta.descricao)),
            DataCell(Text('R\$ ${conta.valor.toStringAsFixed(2)}')),
            DataCell(Text(conta.formaPagamento)),
            DataCell(Text(
                intl.DateFormat('dd/MM/yyyy').format(conta.dataRecebimento))),
            DataCell(Text(conta.contatoCliente ?? '')),
          ],
        );
      }).toList();
    } else {
      return data.map((item) {
        final conta = item as ContaPagar;
        return DataRow(
          cells: [
            DataCell(Text(conta.descricao)),
            DataCell(Text('R\$ ${conta.valor.toStringAsFixed(2)}')),
            DataCell(Text(conta.formaPagamento)),
            DataCell(Text(
                intl.DateFormat('dd/MM/yyyy').format(conta.dataPagamento))),
            DataCell(Text(conta.fornecedor ?? '')),
          ],
        );
      }).toList();
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _dataInicio : _dataFim,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStartDate ? _dataInicio : _dataFim)) {
      setState(() {
        if (isStartDate) {
          _dataInicio = picked;
        } else {
          _dataFim = picked;
        }
      });
    }
  }
}
