import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bs_vistoria_veicular/features/contas_pagar/presentation/providers/contas_pagar_provider.dart';
import 'package:bs_vistoria_veicular/features/contas_pagar/domain/entities/conta_pagar.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class ContasPagarPage extends ConsumerStatefulWidget {
  const ContasPagarPage({super.key});

  @override
  ConsumerState<ContasPagarPage> createState() => _ContasPagarPageState();
}

class _ContasPagarPageState extends ConsumerState<ContasPagarPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _formaPagamentoController = TextEditingController();
  final _fornecedorController = TextEditingController();
  DateTime _dataPagamento = DateTime.now();
  String _tipo = 'pago';

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _formaPagamentoController.dispose();
    _fornecedorController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Parse o valor do controlador, removendo a máscara de moeda
      final double valor = double.parse(
        _valorController.text
            .replaceAll('R\$', '')
            .replaceAll('.', '')
            .replaceAll(',', '.'),
      );

      await ref.read(contasPagarProvider.notifier).adicionarConta(
            descricao: _descricaoController.text,
            valor: valor,
            formaPagamento: _formaPagamentoController.text,
            dataPagamento: _dataPagamento,
            tipo: _tipo,
            fornecedor: _tipo == 'provisao' ? _fornecedorController.text : null,
          );

      _formKey.currentState!.reset();
      _descricaoController.clear();
      _valorController.clear();
      _formaPagamentoController.clear();
      _fornecedorController.clear();
      setState(() {
        _dataPagamento = DateTime.now();
        _tipo = 'pago';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta a pagar adicionada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contasPagar = ref.watch(contasPagarProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas a Pagar'),
      ),
      body: isSmallScreen
          ? _buildSmallScreenLayout(context, contasPagar)
          : _buildLargeScreenLayout(context, contasPagar),
    );
  }

  Widget _buildSmallScreenLayout(
      BuildContext context, AsyncValue<List<ContaPagar>> contasPagar) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildForm(),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildContasList(contasPagar),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout(
      BuildContext context, AsyncValue<List<ContaPagar>> contasPagar) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildForm(),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildContasList(contasPagar),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _descricaoController,
            decoration: InputDecoration(
              labelText: 'Descrição',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira uma descrição';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _valorController,
            decoration: InputDecoration(
              labelText: 'Valor',
              prefixText: 'R\$ ',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              MoneyInputFormatter(leadingSymbol: 'R\$', useSymbolPadding: true)
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira um valor';
              }
              // Converte para double antes de validar
              final double? parsedValue = double.tryParse(value
                  .replaceAll('R\$', '')
                  .replaceAll('.', '')
                  .replaceAll(',', '.'));
              if (parsedValue == null || parsedValue <= 0) {
                return 'Por favor, insira um valor válido (mínimo R\$ 0,01)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _formaPagamentoController,
            decoration: InputDecoration(
              labelText: 'Forma de Pagamento',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira a forma de pagamento';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Data de Pagamento'),
            subtitle: Text(
              '${_dataPagamento.day}/${_dataPagamento.month}/${_dataPagamento.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dataPagamento,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() => _dataPagamento = date);
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _tipo,
            decoration: InputDecoration(
              labelText: 'Tipo',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(
                value: 'pago',
                child: Text('Pago'),
              ),
              DropdownMenuItem(
                value: 'provisao',
                child: Text('Provisão'),
              ),
            ],
            onChanged: (value) {
              setState(() => _tipo = value!);
            },
          ),
          if (_tipo == 'provisao') ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _fornecedorController,
              decoration: InputDecoration(
                labelText: 'Fornecedor / Observações',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
              validator: (value) {
                if (_tipo == 'provisao' && (value == null || value.isEmpty)) {
                  return 'Por favor, insira o fornecedor ou observações';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Adicionar',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContasList(AsyncValue<List<ContaPagar>> contasPagar) {
    return contasPagar.when(
      data: (contas) {
        if (contas.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma conta a pagar cadastrada',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: contas.length,
          itemBuilder: (context, index) {
            final conta = contas[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  conta.descricao,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  softWrap: true,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${conta.valor.toStringAsFixed(2)} - ${conta.formaPagamento}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      softWrap: true,
                    ),
                    Text(
                      'Pagamento: ${conta.dataPagamento.day}/${conta.dataPagamento.month}/${conta.dataPagamento.year}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      softWrap: true,
                    ),
                    if (conta.fornecedor != null &&
                        conta.fornecedor!.isNotEmpty)
                      Text(
                        'Fornecedor: ${conta.fornecedor}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        softWrap: true,
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon:
                      const Icon(Icons.delete_forever, color: Colors.redAccent),
                  onPressed: () async {
                    try {
                      await ref
                          .read(contasPagarProvider.notifier)
                          .removerConta(conta.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Conta removida com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Erro ao carregar contas: $error'),
      ),
    );
  }
}
