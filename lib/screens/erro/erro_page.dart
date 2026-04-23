// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;
  final IconData icon;

  const ErrorPage({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.onGoHome,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFDF7ED);
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06);

    final titleColor = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final textColor =
        isDark ? Colors.white70 : const Color(0xFF5F5F5F);

    final primaryColor = const Color(0xFFED7227);
    final secondaryColor = const Color(0xFF88BE8E);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.22 : 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.12),
                      ),
                      child: Icon(
                        icon,
                        size: 44,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      title ?? 'Ops! Algo deu errado',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message ??
                          'Não foi possível concluir esta ação agora. '
                              'Você pode tentar novamente ou voltar para a página inicial.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: textColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (onRetry != null) {
                            onRetry!();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white,),
                        label: const Text('Recarregar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (onGoHome != null) {
                            onGoHome!();
                          } else {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.home_rounded, color: Color(0xFF88BE8E),),
                        label: const Text('Ir para início'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: secondaryColor,
                          side: BorderSide(
                            color: secondaryColor.withOpacity(0.55),
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
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