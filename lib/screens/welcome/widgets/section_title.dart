// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

 Widget buildSectionTitle(
    BuildContext context,
    String title,
    String subtitle, {
    bool center = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Text(
            subtitle,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              height: 1.7,
              color: theme.colorScheme.onSurface.withOpacity(0.78),
            ),
          ),
        ),
      ],
    );
  }

  

