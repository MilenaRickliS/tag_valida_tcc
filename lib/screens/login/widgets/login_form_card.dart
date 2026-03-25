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

  InputDecoration _decoration({
    required String label,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFFC29500),
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFC29500), width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
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
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration(
                  label: "E-mail",
                  prefixIcon: const Icon(Icons.email_outlined),
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
                decoration: _decoration(
                  label: "Senha",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off
                          : Icons.visibility,
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
                  Row(
                    children: [
                      Checkbox(
                        value: lembrar,
                        activeColor: const Color(0xFFC29500),
                        checkColor: Colors.black,
                        onChanged: loading ? null : onToggleRemember,
                      ),
                      const Text(
                        "Lembrar de mim",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: loading ? null : onResetSenha,
                    child: const Text(
                      "Esqueci minha senha",
                      style: TextStyle(
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Entrar"),
              ),

              const SizedBox(height: 12),

            
              TextButton(
                onPressed: loading ? null : onGoCadastro,
                child: const Text(
                  "Ainda não possui cadastro? Cadastre-se.",
                  style: TextStyle(
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