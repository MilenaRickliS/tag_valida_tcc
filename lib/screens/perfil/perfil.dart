// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart'; 
import '../../widgets/menu.dart';
import './widgets/editar_perfil_modal.dart';
import './widgets/header_card.dart';
import './widgets/info_card.dart';
import './widgets/info_row.dart';

class PerfilScreen extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onLogout;

  const PerfilScreen({
    super.key,
    this.onEdit,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = Theme.of(context);
  

    final bg = theme.scaffoldBackgroundColor;

    if (user == null) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final w = MediaQuery.of(context).size.width;
    final compact = w < 835;

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
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                compact ? 14 : 20,
                14,
                compact ? 14 : 20,
                22,
              ),
              children: [
                HeaderCard(
                  user: user,
                  compact: compact,
                  onEdit: onEdit ?? () => _defaultEdit(context),
                  onLogout: onLogout ?? () => _defaultLogout(context),
                ),
                const SizedBox(height: 14),

                
                InfoCard(
                  title: "Contato",
                  icon: Icons.call_rounded,
                  rows: [
                    InfoRow(label: "E-mail", value: user.email),
                    InfoRow(label: "Telefone", value: user.telefone),
                    InfoRow(label: "Responsável", value: user.responsavel),
                  ],
                ),
                const SizedBox(height: 12),
                InfoCard(
                  title: "Empresa",
                  icon: Icons.storefront_rounded,
                  rows: [
                    InfoRow(label: "CNPJ", value: user.cnpj),
                    InfoRow(label: "CEP", value: user.cep),
                  ],
                ),
                const SizedBox(height: 12),
                InfoCard(
                  title: "Endereço",
                  icon: Icons.location_on_rounded,
                  rows: [
                    InfoRow(label: "Rua", value: user.rua),
                    InfoRow(label: "Número", value: user.numero),
                    InfoRow(label: "Bairro", value: user.bairro),
                    InfoRow(label: "Complemento", value: user.complemento),
                    InfoRow(
                      label: "Cidade/UF",
                      value: "${user.cidade} - ${user.estado}",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _defaultEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EditarPerfilModal(),
    );
  }

  void _defaultLogout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dialogBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF2B2B2B);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.red),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Sair",
                style: TextStyle(fontWeight: FontWeight.w900, color: titleColor,),
              ),
            ),
          ],
        ),
        content: Text(
          "Deseja sair da sua conta agora?",
          style: TextStyle(
            color: isDark ? const Color(0xFFD6D6D6) : const Color(0xFF2B2B2B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700,)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              Navigator.pop(context);

              try {
                await context.read<AuthProvider>().logout();

               
              } catch (_) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Erro ao sair. Tente novamente.")),
                );
              }
            },
            child: const Text("Sair"),
          ),
        ],
      ),
    );
  }
}
