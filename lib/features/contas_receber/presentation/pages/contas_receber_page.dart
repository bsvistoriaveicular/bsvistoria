import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bs_vistoria_veicular/features/contas_receber/presentation/providers/contas_receber_provider.dart';
import 'package:bs_vistoria_veicular/features/contas_receber/domain/entities/conta_receber.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:bs_vistoria_veicular/core/providers/ocr_scan_provider.dart';
import 'package:intl/intl.dart';

class ContasReceberPage extends ConsumerStatefulWidget {
  const ContasReceberPage({super.key});

  @override
  ConsumerState<ContasReceberPage> createState() => _ContasReceberPageState();
}

class _ContasReceberPageState extends ConsumerState<ContasReceberPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _formaPagamentoController = TextEditingController();
  final _contatoClienteController = TextEditingController();
  DateTime _dataRecebimento = DateTime.now();
  String _tipo = 'entrada';

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _formaPagamentoController.dispose();
    _contatoClienteController.dispose();
    super.dispose();
  }

  Future<void> _handleScan() async {
    final ocrService = ref.read(ocrScanServiceProvider);
    try {
      final scannedText = await ocrService.scanImage();
      if (scannedText != null) {
        _parseAndFillForm(scannedText);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Texto do cupom escaneado e analisado!'),
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhum texto detectado no cupom.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao escanear cupom: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _parseAndFillForm(String scannedText) {
    // Lógica de parsing para extrair dados do texto
    // Implementaremos isso no próximo passo (Passo 4)

    // Exemplo básico (você precisará refinar isso)
    // Para fins de demonstração, preenchemos com valores fixos ou extraídos de forma simplificada.
    // Você precisará de regex mais robustos para casos reais.

    // Tenta extrair o valor (ex: TOTAL R$ 125,90)
    RegExp valorRegex = RegExp(
        r'(?:TOTAL|VALOR|Total a Pagar)[^\d]*R\$\s*([\d,\.]+)',
        caseSensitive: false);
    Match? valorMatch = valorRegex.firstMatch(scannedText);
    if (valorMatch != null && valorMatch.group(1) != null) {
      String valorStr = valorMatch.group(1)!;
      valorStr = valorStr.replaceAll('.', '').replaceAll(
          ',', '.'); // Remove separadores de milhar e troca vírgula por ponto
      _valorController.text = double.parse(valorStr)
          .toStringAsFixed(2); // Formata para 2 casas decimais
    }

    // Tenta extrair a data (ex: Data: 17/06/2025)
    RegExp dataRegex = RegExp(
        r'(?:Data|Dt|Data da venda)[:\s]*(\d{2}[/\-]\d{2}[/\-]\d{4})',
        caseSensitive: false);
    Match? dataMatch = dataRegex.firstMatch(scannedText);
    if (dataMatch != null && dataMatch.group(1) != null) {
      try {
        _dataRecebimento = DateFormat('dd/MM/yyyy')
            .parse(dataMatch.group(1)!.replaceAll('-', '/'));
      } catch (e) {
        // Fallback ou log de erro se o parsing da data falhar
        debugPrint('Erro ao parsear data: $e');
      }
    }

    // Tenta identificar descrição/contato (palavras-chave)
    // Esta parte é mais complexa e depende muito dos dados esperados
    // Por exemplo, podemos procurar por nomes de estabelecimentos conhecidos ou categorias
    if (scannedText.toLowerCase().contains('supermercado')) {
      _descricaoController.text = 'Compras de Supermercado';
    } else if (scannedText.toLowerCase().contains('posto') ||
        scannedText.toLowerCase().contains('combustível')) {
      _descricaoController.text = 'Abastecimento';
    }
    // Exemplo para contato/cliente (você pode expandir esta lógica)
    _contatoClienteController.text = ''; // Limpar ou tentar inferir

    setState(() {}); // Atualiza a UI com os dados preenchidos
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

      await ref.read(contasReceberProvider.notifier).adicionarConta(
            descricao: _descricaoController.text,
            valor: valor,
            formaPagamento: _formaPagamentoController.text,
            dataRecebimento: _dataRecebimento,
            tipo: _tipo,
            contatoCliente:
                _tipo == 'provisao' ? _contatoClienteController.text : null,
          );

      _formKey.currentState!.reset();
      _descricaoController.clear();
      _valorController.clear();
      _formaPagamentoController.clear();
      _contatoClienteController.clear();
      setState(() {
        _dataRecebimento = DateTime.now();
        _tipo = 'entrada';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta a receber adicionada com sucesso!'),
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
    final contasReceber = ref.watch(contasReceberProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas a Receber'),
      ),
      body: isSmallScreen
          ? _buildSmallScreenLayout(context, contasReceber)
          : _buildLargeScreenLayout(context, contasReceber),
    );
  }

  Widget _buildSmallScreenLayout(
      BuildContext context, AsyncValue<List<ContaReceber>> contasReceber) {
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
                child: _buildContasList(contasReceber),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout(
      BuildContext context, AsyncValue<List<ContaReceber>> contasReceber) {
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
              child: _buildContasList(contasReceber),
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
          ElevatedButton.icon(
            onPressed: _handleScan,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Escanear Cupom'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.primary, // Cor de destaque
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
            title: const Text('Data de Recebimento'),
            subtitle: Text(
              '${_dataRecebimento.day}/${_dataRecebimento.month}/${_dataRecebimento.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dataRecebimento,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() => _dataRecebimento = date);
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
                value: 'entrada',
                child: Text('Entrada'),
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
              controller: _contatoClienteController,
              decoration: InputDecoration(
                labelText: 'Contato do Cliente',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
              validator: (value) {
                if (_tipo == 'provisao' && (value == null || value.isEmpty)) {
                  return 'Por favor, insira o contato do cliente';
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

  Widget _buildContasList(AsyncValue<List<ContaReceber>> contasReceber) {
    return contasReceber.when(
      data: (contas) {
        if (contas.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma conta a receber cadastrada',
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
                      'Recebimento: ${conta.dataRecebimento.day}/${conta.dataRecebimento.month}/${conta.dataRecebimento.year}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      softWrap: true,
                    ),
                    if (conta.contatoCliente != null &&
                        conta.contatoCliente!.isNotEmpty)
                      Text(
                        'Contato: ${conta.contatoCliente}',
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
                          .read(contasReceberProvider.notifier)
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
