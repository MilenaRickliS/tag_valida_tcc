// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tag_valida/screens/configuracoes_impressora/widgets/status_pill.dart';

import '../../models/printer_config_model.dart';
import '../../providers/printer_config_provider.dart';
import '../../services/elgin_l42_network_service.dart';
import './widgets/resumo_card.dart';
import './widgets/config_card.dart';


class ConfiguracoesImpressoraScreen extends StatefulWidget {
  const ConfiguracoesImpressoraScreen({super.key});

  @override
  State<ConfiguracoesImpressoraScreen> createState() =>
      _ConfiguracoesImpressoraScreenState();
}

class _ConfiguracoesImpressoraScreenState
    extends State<ConfiguracoesImpressoraScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _modeloCtrl;
  late final TextEditingController _ipCtrl;
  late final TextEditingController _portaCtrl;

  bool _ativo = true;
  bool _padrao = true;
  String _tipoConexao = 'network';
  String _tamanhoEtiqueta = '60x40';

  bool _testing = false;
  bool _saving = false;
  bool _testingPrint = false;
  bool _testingAdvance = false;

  bool? _ultimoTesteOk;
  String? _statusMsg;

  static const _lightCard = Colors.white;
  static const _lightText = Color(0xFF2B2B2B);

  static const _darkCard = Color(0xFF1E1E1E);
  static const _darkText = Colors.white;
  static const _gold = Color(0xFFD4AF37);

  static const _green = Color(0xFF2E7D32);
  static const _red = Color(0xFFC62828);

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _card(BuildContext context) => _isDark(context) ? _darkCard : _lightCard;
  Color _text(BuildContext context) => _isDark(context) ? _darkText : _lightText;
  Color _muted(BuildContext context) => _isDark(context)
      ? const Color(0xFFD6D6D6)
      : Colors.black.withOpacity(0.60);
  Color _border(BuildContext context) => _isDark(context)
      ? _gold.withOpacity(0.16)
      : Colors.black.withOpacity(0.07);

  @override
  void initState() {
    super.initState();

    _nomeCtrl = TextEditingController(text: 'Impressora principal');
    _modeloCtrl = TextEditingController(text: 'Elgin L42 Pro');
    _ipCtrl = TextEditingController();
    _portaCtrl = TextEditingController(text: '9100');

    _nomeCtrl.addListener(() => setState(() {}));
    _modeloCtrl.addListener(() => setState(() {}));
    _ipCtrl.addListener(() => setState(() {}));
    _portaCtrl.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final provider = context.read<PrinterConfigProvider>();
      await provider.load(uid);

      final current = provider.defaultPrinter;
      if (current != null && mounted) {
        _fill(current);
      }
    });
  }

  void _fill(PrinterConfigModel model) {
    _nomeCtrl.text = model.nome;
    _modeloCtrl.text = model.modelo;
    _ipCtrl.text = model.ip;
    _portaCtrl.text = model.porta.toString();
    _ativo = model.ativo;
    _padrao = model.padrao;
    _tipoConexao = model.tipoConexao;
    _tamanhoEtiqueta = model.tamanhoEtiqueta;
    setState(() {});
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _modeloCtrl.dispose();
    _ipCtrl.dispose();
    _portaCtrl.dispose();
    super.dispose();
  }

  Future<ElginL42NetworkService> _buildService() async {
    return ElginL42NetworkService(
      ip: _ipCtrl.text.trim(),
      port: int.tryParse(_portaCtrl.text.trim()) ?? 9100,
    );
  }

  Future<void> _testarConexao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _testing = true;
      _statusMsg = null;
    });

    try {
      final service = await _buildService();
      final ok = await service.testConnection();

      if (!ok) {
        throw Exception('Não foi possível conectar à impressora.');
      }

      setState(() {
        _ultimoTesteOk = true;
        _statusMsg = 'Conexão estabelecida com sucesso.';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Conexão OK com a impressora.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _ultimoTesteOk = false;
        _statusMsg = 'Falha ao conectar à impressora.';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro no teste: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _imprimirTeste() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _testingPrint = true;
      _statusMsg = null;
    });

    try {
      final service = await _buildService();
      final ok = await service.testConnection();

      if (!ok) {
        throw Exception('Não foi possível conectar à impressora.');
      }

      await service.printTeste();

      setState(() {
        _ultimoTesteOk = true;
        _statusMsg = 'Etiqueta de teste enviada com sucesso.';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Etiqueta de teste enviada para impressão.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _ultimoTesteOk = false;
        _statusMsg = 'Erro ao enviar etiqueta de teste.';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao imprimir teste: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _testingPrint = false);
    }
  }

  Future<void> _avancarEtiqueta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _testingAdvance = true;
      _statusMsg = null;
    });

    try {
      final service = await _buildService();
      final ok = await service.testConnection();

      if (!ok) {
        throw Exception('Não foi possível conectar à impressora.');
      }

      await service.avancarEtiqueta();

      setState(() {
        _ultimoTesteOk = true;
        _statusMsg = 'Comando de avanço enviado com sucesso.';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Comando de avanço enviado para a impressora.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _ultimoTesteOk = false;
        _statusMsg = 'Erro ao avançar etiqueta.';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao avançar etiqueta: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _testingAdvance = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('Usuário não autenticado.');
      }

      final provider = context.read<PrinterConfigProvider>();
      final current = provider.defaultPrinter;

      final model = (current ?? PrinterConfigModel.empty(uid)).copyWith(
        nome: _nomeCtrl.text.trim(),
        modelo: _modeloCtrl.text.trim(),
        tipoConexao: _tipoConexao,
        ip: _ipCtrl.text.trim(),
        porta: int.tryParse(_portaCtrl.text.trim()) ?? 9100,
        tamanhoEtiqueta: _tamanhoEtiqueta,
        ativo: _ativo,
        padrao: _padrao,
        updatedAt: DateTime.now(),
      );

      await provider.save(model);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Configuração da impressora salva com sucesso.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrinterConfigProvider>();
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 880;
    final isDark = _isDark(context);

    final statusColor = _ultimoTesteOk == null
        ? (isDark ? _gold : Colors.black54)
        : (_ultimoTesteOk! ? _green : _red);

    final statusBg = _ultimoTesteOk == null
        ? (isDark
            ? _gold.withOpacity(0.10)
            : Colors.grey.withOpacity(0.10))
        : (_ultimoTesteOk!
            ? _green.withOpacity(0.10)
            : _red.withOpacity(0.10));

    final statusBorder = _ultimoTesteOk == null
        ? (isDark
            ? _gold.withOpacity(0.18)
            : Colors.grey.withOpacity(0.18))
        : (_ultimoTesteOk!
            ? _green.withOpacity(0.20)
            : _red.withOpacity(0.20));

    final statusTitle = _ultimoTesteOk == null
        ? 'Conexão não testada'
        : (_ultimoTesteOk! ? 'Conectada' : 'Sem conexão');

    return Container(
    color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFDF7ED),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _card(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _border(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Configuração da impressora",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _text(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Configure a impressora de etiquetas da produção, teste a conexão em rede e envie uma etiqueta de teste para validar o funcionamento.",
                      style: TextStyle(
                        color: _muted(context),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (provider.error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.withOpacity(0.18)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                provider.error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: statusBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : Colors.white.withOpacity(0.82),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _ultimoTesteOk == null
                                  ? Icons.print_outlined
                                  : (_ultimoTesteOk!
                                      ? Icons.wifi_tethering_rounded
                                      : Icons.wifi_off_rounded),
                              color: statusColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  statusTitle,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _statusMsg ??
                                      'Use os botões abaixo para testar a rede e validar a impressão da etiqueta.',
                                  style: TextStyle(
                                    color: _muted(context),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          StatusPill(
                            label: _ultimoTesteOk == null
                                ? 'Pendente'
                                : (_ultimoTesteOk! ? 'Online' : 'Offline'),
                            color: statusColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: ConfigCard(
                              nomeCtrl: _nomeCtrl,
                              modeloCtrl: _modeloCtrl,
                              ipCtrl: _ipCtrl,
                              portaCtrl: _portaCtrl,
                              tipoConexao: _tipoConexao,
                              tamanhoEtiqueta: _tamanhoEtiqueta,
                              ativo: _ativo,
                              padrao: _padrao,
                              onTipoConexaoChanged: (v) {
                                if (v == null) return;
                                setState(() => _tipoConexao = v);
                              },
                              onTamanhoEtiquetaChanged: (v) {
                                if (v == null) return;
                                setState(() => _tamanhoEtiqueta = v);
                              },
                              onAtivoChanged: (v) => setState(() => _ativo = v),
                              onPadraoChanged: (v) => setState(() => _padrao = v),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 5,
                            child: ResumoCard(
                              modelo: _modeloCtrl.text,
                              tipoConexao: _tipoConexao,
                              ip: _ipCtrl.text,
                              porta: _portaCtrl.text,
                              tamanhoEtiqueta: _tamanhoEtiqueta,
                              ativo: _ativo,
                              statusColor: statusColor,
                              green: _green,
                              red: _red,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      ConfigCard(
                        nomeCtrl: _nomeCtrl,
                        modeloCtrl: _modeloCtrl,
                        ipCtrl: _ipCtrl,
                        portaCtrl: _portaCtrl,
                        tipoConexao: _tipoConexao,
                        tamanhoEtiqueta: _tamanhoEtiqueta,
                        ativo: _ativo,
                        padrao: _padrao,
                        onTipoConexaoChanged: (v) {
                          if (v == null) return;
                          setState(() => _tipoConexao = v);
                        },
                        onTamanhoEtiquetaChanged: (v) {
                          if (v == null) return;
                          setState(() => _tamanhoEtiqueta = v);
                        },
                        onAtivoChanged: (v) => setState(() => _ativo = v),
                        onPadraoChanged: (v) => setState(() => _padrao = v),
                      ),
                      const SizedBox(height: 16),
                      ResumoCard(
                      modelo: _modeloCtrl.text,
                      tipoConexao: _tipoConexao,
                      ip: _ipCtrl.text,
                      porta: _portaCtrl.text,
                      tamanhoEtiqueta: _tamanhoEtiqueta,
                      ativo: _ativo,
                      statusColor: statusColor,
                      green: _green,
                      red: _red,
                    ),
                    ],
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: isWide ? 220 : double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _testing ? null : _testarConexao,
                            icon: _testing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Icon(Icons.wifi_tethering_rounded, color: Colors.black,),
                            label: const Text("Testar conexão"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? _gold
                                  : const Color(0xFFF4D58D),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? 240 : double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _testingPrint ? null : _imprimirTeste,
                            icon: _testingPrint
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Icon(Icons.print_outlined, color: Colors.black, ),
                            label: const Text("Imprimir etiqueta teste"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFED7227),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? 210 : double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _testingAdvance ? null : _avancarEtiqueta,
                            icon: _testingAdvance
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Icon(Icons.skip_next_rounded, color: Colors.black,),
                            label: const Text("Avançar etiqueta"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDCEBFF),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? 180 : double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _salvar,
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined, color: Colors.black,),
                            label: const Text("Salvar"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF88BE8E),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


