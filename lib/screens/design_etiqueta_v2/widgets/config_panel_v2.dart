// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_v2_model.dart';
import '../../../providers/design_etiqueta_v2_provider.dart';
import 'campo_config_tile_v2.dart';
import 'settings_card_v2.dart';
import 'switch_tile_v2.dart';

const _orange = Color(0xFFED7227);
const _gold = Color(0xFFD4AF37);

Widget buildConfigPanelV2({
  required BuildContext context,
  required bool isDark,
  required Color card,
  required Color text,
  required Color muted,
  required Color border,
  required DesignEtiquetaV2Model config,
  required DesignEtiquetaV2Provider designProvider,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (designProvider.validation != null &&
            !(designProvider.validation!.ok)) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    designProvider.validation!.message ??
                        'O layout não cabe neste tamanho.',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        Text(
          'Configurações da etiqueta',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: text,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Ative, ajuste e reordene os campos. O tamanho é definido acima.',
          style: TextStyle(fontSize: 13.5, color: muted),
        ),

        const SizedBox(height: 16),

        settingsCardV2(
          title: 'Elementos visuais',
          isDark: isDark,
          child: Column(
            children: [
              switchTileV2(
                isDark: isDark,
                value: config.destacarValidade,
                title: 'Destacar validade',
                onChanged: (v) => designProvider.setDestacarValidade(v),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: Text(
                'Campos da etiqueta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: text,
                ),
              ),
            ),
            Wrap(
              spacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: designProvider.loading
                      ? null
                      : () async {
                          await designProvider.resetAtual();
                        },
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Restaurar'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _orange,
                  ),
                  onPressed: designProvider.saving || !designProvider.canSave
                      ? null
                      : () async {
                          await designProvider.saveAtual();

                          final validation = designProvider.validation;

                          if (validation != null && !validation.ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(validation.message ?? ''),
                              ),
                            );
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Design salvo com sucesso.'),
                            ),
                          );
                        },
                  icon: designProvider.saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    designProvider.saving ? 'Salvando...' : 'Salvar',
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          'Arraste para mudar a ordem. Campos obrigatórios permanecem ativos.',
          style: TextStyle(fontSize: 12.8, color: muted),
        ),

        const SizedBox(height: 12),

        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: config.campos.length,
          onReorder: (oldIndex, newIndex) {
            designProvider.reorderCampos(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final campo = config.campos[index];

            final isFixo = campo.id == 'empresa' ||
                campo.id == 'produto' ||
                campo.tipo == CampoDesignV2Tipo.qrcode;
            
            final temTabelaNutricional = config.campos.any(
              (c) =>
                  c.visivel &&
                  (c.tipo == CampoDesignV2Tipo.tabelaNutricional ||
                      c.id == 'tabela_nutricional'),
            );

            return Padding(
              key: ValueKey(campo.id),
              padding: const EdgeInsets.only(bottom: 12),
              child: campoConfigTileV2(
                campo: campo,
                isDark: isDark,
                bloqueado: isFixo,
                temTabelaNutricional: temTabelaNutricional,
                dragHandle: isFixo
                    ? const SizedBox(width: 42)
                    : ReorderableDragStartListener(
                        index: index,
                        child: _dragHandle(isDark),
                      ),
                onToggle: campo.obrigatorio
                    ? null
                    : (v) => designProvider.toggleCampo(
                          campo.id,
                          v ?? false,
                        ),
                onBoldChanged: (v) =>
                    designProvider.setBold(campo.id, v),
                onAlignChanged: (v) {
                  if (v == null) return;
                  designProvider.setAlign(campo.id, v);
                },
              ),
            );
          },
        ),
      ],
    ),
  );
}

Widget _dragHandle(bool isDark) {
  return Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? _gold.withOpacity(0.10)
            : Colors.black.withOpacity(0.06),
      ),
    ),
    child: Icon(
      Icons.drag_indicator_rounded,
      color: isDark ? Colors.white70 : Colors.black54,
    ),
  );
}