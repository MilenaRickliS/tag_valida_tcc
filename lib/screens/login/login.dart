// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import './widgets/login_form_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();

  bool _lembrar = true;
  bool _loading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString("remember_email");
    final remember = prefs.getBool("remember_enabled") ?? true;

    if (!mounted) return;

    setState(() {
      _lembrar = remember;
      if (remember && savedEmail != null && savedEmail.isNotEmpty) {
        _email.text = savedEmail;
      }
    });
  }

  Future<void> _saveRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("remember_enabled", _lembrar);

    if (_lembrar) {
      await prefs.setString("remember_email", _email.text.trim());
    } else {
      await prefs.remove("remember_email");
    }
  }

  Future<void> _toggleRemember(bool? v) async {
    final next = v ?? true;

    setState(() => _lembrar = next);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("remember_enabled", next);

    if (!next) {
      _email.clear();
      await prefs.remove("remember_email");
    } else {
     
      await prefs.setString("remember_email", _email.text.trim());
    }
  }

  Future<void> _entrar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await context.read<AuthProvider>().signIn(
            _email.text.trim(),
            _senha.text,
          );

      await _saveRememberedEmail();

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetSenha() async {
    final controller = TextEditingController(text: _email.text.trim());

    final email = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final onSurface = theme.colorScheme.onSurface;

        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: Color(0xFFC29500),
              width: 1.2,
            ),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              const Icon(
                Icons.lock_reset,
                color: Color(0xFFC29500),
              ),
              const SizedBox(width: 10),
              Text(
                "Recuperar senha",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Informe o e-mail cadastrado para receber o link de recuperação.",
                style: TextStyle(
                  fontSize: 13,
                  color: onSurface.withOpacity(0.80),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: onSurface),
                decoration: InputDecoration(
                  labelText: "E-mail",
                  labelStyle: TextStyle(color: onSurface.withOpacity(0.65)),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: onSurface.withOpacity(0.75),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white,
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
                      width: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: onSurface,
              ),
              child: const Text(
                "Cancelar",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC29500),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Colors.black, width: 1.2),
                elevation: 2,
              ),
              child: const Text(
                "Enviar link",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );


    if (email == null || email.isEmpty) return;

    try {
      await context.read<AuthProvider>().sendPasswordResetEmail(email);
      _snack("Enviamos um link de recuperação para seu e-mail.");
    } catch (e) {
      _snack(e.toString());
    }
  }

  InputDecoration decoration({
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide: const BorderSide(color: Color(0xFFC29500), width: 1.8),
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
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (_) => false,
            );
          },
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: isDark ? "Modo claro" : "Modo escuro",
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                key: ValueKey(isDark),
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/logo3-semfundo.png', height: 150),
                const SizedBox(height: 16),
                LoginFormCard(
                  formKey: _formKey,
                  emailCtrl: _email,
                  senhaCtrl: _senha,
                  lembrar: _lembrar,
                  loading: _loading,
                  obscure: _obscure,
                  onToggleRemember: _toggleRemember,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  onEntrar: _entrar,
                  onResetSenha: _resetSenha,
                  onGoCadastro: () => Navigator.pushNamed(context, '/cadastro'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
