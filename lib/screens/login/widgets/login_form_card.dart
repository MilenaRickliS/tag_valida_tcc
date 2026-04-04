// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class LoginFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController senhaCtrl;

  final bool lembrar;
  final bool loading;
  final bool obscure;

  final ValueChanged<bool?> onToggleRemember;
  final VoidCallback onToggleObscure;
  final VoidCallback onEntrar;
  final VoidCallback onResetSenha;
  final VoidCallback onGoCadastro;

  const LoginFormCard({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.senhaCtrl,
    required this.lembrar,
    required this.loading,
    required this.obscure,
    required this.onToggleRemember,
    required this.onToggleObscure,
    required this.onEntrar,
    required this.onResetSenha,
    required this.onGoCadastro,
  });

  InputDecoration _decoration(
    BuildContext context, {
    required String label,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: onSurface.withOpacity(0.65)),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFFC29500),
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.white,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: onSurface.withOpacity(0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFC29500),
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Card(
      color: theme.cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              Text(
                "Login",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: onSurface),
                decoration: _decoration(
                  context,
                  label: "E-mail",
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: onSurface.withOpacity(0.75),
                  ),
                ),
                validator: (v) {
                  final s = (v ?? "").trim();
                  if (s.isEmpty) return "Informe o e-mail";
                  if (!s.contains("@")) return "E-mail inválido";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: senhaCtrl,
                obscureText: obscure,
                style: TextStyle(color: onSurface),
                decoration: _decoration(
                  context,
                  label: "Senha",
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: onSurface.withOpacity(0.75),
                  ),
                  suffixIcon: IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: onSurface.withOpacity(0.75),
                    ),
                  ),
                ),
                validator: (v) {
                  if ((v ?? "").isEmpty) return "Informe a senha";
                  if ((v ?? "").length < 6) {
                    return "Senha deve ter no mínimo 6 caracteres";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: lembrar,
                          activeColor: const Color(0xFFC29500),
                          checkColor: Colors.black,
                          onChanged: loading ? null : onToggleRemember,
                        ),
                        Flexible(
                          child: Text(
                            "Lembrar de mim",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: loading ? null : onResetSenha,
                    child: Text(
                      "Esqueci minha senha",
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: loading ? null : onEntrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC29500),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        "Entrar",
                        style: TextStyle(color: Colors.black),
                      ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: loading ? null : onGoCadastro,
                child: Text(
                  "Ainda não possui cadastro? Cadastre-se.",
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}