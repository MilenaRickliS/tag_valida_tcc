
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../widgets/menu.dart';
import './widgets/action_button.dart';
import './widgets/info_box.dart';
import './widgets/status_card.dart';
import '../../data/local/app_db.dart';
import '../../data/sync/sync_service.dart';
import '../../data/sync/backup_service.dart';

class BackupScreen extends StatefulWidget {
  final String uid;
  final SyncService syncService;

  const BackupScreen({
    super.key,
    required this.uid,
    required this.syncService,
  });

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _loadingBackup = false;
  bool _loadingRestore = false;
  bool _loadingSync = false;

  String? _lastBackupPath;
  String? _dbPath;

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _bg(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0F0F0F) : const Color(0xFFFDF7ED);

  Color _card(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  Color _text(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF2B2B2B);

  Color _muted(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFFD6D6D6)
          : Colors.black.withOpacity(0.60);

  Color _border(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFFD4AF37).withOpacity(0.16)
          : Colors.black.withOpacity(0.07);

  final Color _brand = const Color(0xFFED7227);
  final Color _success = const Color(0xFF2E7D32);
  final Color _danger = const Color(0xFFC62828);
  final Color _info = const Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();
    _loadPaths();
  }

  Future<void> _loadPaths() async {
    final db = await AppDb.instance.db;
    final docs = await getApplicationDocumentsDirectory();

    setState(() {
      _dbPath = db.path;
      _lastBackupPath = '${docs.path}/backup_tagvalida.db';
    });
  }

  Future<void> _fazerBackup() async {
    setState(() => _loadingBackup = true);

    try {
      final file = await BackupService.exportBackup();
      if (!mounted) return;

      setState(() {
        _lastBackupPath = file.path;
      });

      _showSnack(
        'Backup criado com sucesso em:\n${file.path}',
        color: _success,
      );
    } catch (e) {
      _showSnack('Erro ao criar backup: $e', color: _danger);
    } finally {
      if (mounted) setState(() => _loadingBackup = false);
    }
  }

  Future<void> _restaurarBackup() async {
    setState(() => _loadingRestore = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result == null || result.files.single.path == null) {
        if (mounted) {
          _showSnack('Restauração cancelada.', color: _info);
        }
        return;
      }

      final backupPath = result.files.single.path!;
      await BackupService.restoreBackup(backupPath);

      if (!mounted) return;
      _showSnack(
        'Backup restaurado com sucesso. Reinicie a tela/app para recarregar os dados.',
        color: _success,
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/erro',
        arguments: {
          'title': 'Erro ao restaurar backup',
          'message': 'Não foi possível restaurar os dados. Arquivo inválido ou corrompido.',
        },
      );
    } finally {
      if (mounted) setState(() => _loadingRestore = false);
    }
  }

  Future<void> _sincronizarAgora() async {
    setState(() => _loadingSync = true);

    try {
      await widget.syncService.syncNow(widget.uid);

      if (!mounted) return;
      _showSnack('Sincronização concluída com sucesso.', color: _success);
    } catch (e) {
      _showSnack('Erro ao sincronizar: $e', color: _danger);
    } finally {
      if (mounted) setState(() => _loadingSync = false);
    }
  }

  void _showSnack(String msg, {Color? color}) {
    final isDark = _isDark(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color ?? (isDark ? const Color(0xFF1E1E1E) : null),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final compact = w < 835;

    final bg = _bg(context);
    final card = _card(context);
    final text = _text(context);
    final muted = _muted(context);
    final border = _border(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        toolbarHeight: compact ? 160 : 100,
        centerTitle: true,
        title: compact
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo6.png', height: 78),
                  const SizedBox(height: 10),
                  const TopMenu(),
                ],
              )
            : Row(
                children: [
                  Image.asset('assets/logo6.png', height: 92),
                  const Spacer(),
                  const TopMenu(),
                ],
              ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isDark(context) ? 0.18 : 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Backup de dados",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Salve, restaure e sincronize as informações do sistema com segurança.",
                    style: TextStyle(color: muted),
                  ),
                  const SizedBox(height: 20),

                  statusCard(
                    context,
                    icon: Icons.cloud_done_outlined,
                    title: "Backup automático em nuvem",
                    subtitle:
                        "Seu projeto já possui sincronização entre SQLite local e Firebase.",
                    color: _success,
                  ),

                  const SizedBox(height: 14),

                  infoBox(
                    context,
                    title: "Banco local",
                    value: _dbPath ?? "Carregando...",
                  ),

                  const SizedBox(height: 12),

                  infoBox(
                    context,
                    title: "Último caminho de backup",
                    value: _lastBackupPath ?? "Nenhum backup gerado ainda",
                  ),

                  const SizedBox(height: 22),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      actionButton(
                        context,
                        icon: Icons.save_alt_outlined,
                        label: _loadingBackup
                            ? "Gerando backup..."
                            : "Fazer backup agora",
                        color: _brand,
                        onTap: _loadingBackup ? null : _fazerBackup,
                      ),
                      actionButton(
                        context,
                        icon: Icons.restore_outlined,
                        label: _loadingRestore
                            ? "Restaurando..."
                            : "Restaurar backup",
                        color: _danger,
                        onTap: _loadingRestore ? null : _restaurarBackup,
                      ),
                      actionButton(
                        context,
                        icon: Icons.sync_outlined,
                        label: _loadingSync
                            ? "Sincronizando..."
                            : "Sincronizar com nuvem",
                        color: _info,
                        onTap: _loadingSync ? null : _sincronizarAgora,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _isDark(context)
                          ? Colors.white.withOpacity(0.03)
                          : const Color(0xFFF8F8F8),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Como funciona",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: text,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "• Fazer backup agora: cria uma cópia do banco local.\n"
                          "• Restaurar backup: substitui os dados atuais pelo arquivo selecionado.\n"
                          "• Sincronizar com nuvem: envia e baixa dados entre SQLite e Firebase.",
                          style: TextStyle(
                            color: muted,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                   const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}  