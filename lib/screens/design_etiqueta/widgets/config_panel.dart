// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/design_etiqueta_model.dart';
import '../../../providers/design_etiqueta_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/tipos_etiqueta_local_provider.dart';
import './settings_card.dart';
import './campo_config_tile.dart';
import './switch_tile.dart';

const _orange = Color(0xFFED7227);
const _gold = Color(0xFFD4AF37);

const double _minLarguraMm = 20;
const double _maxLarguraMm = 111;
const double _minAlturaMm = 8;
const double _maxAlturaMm = 2000;

double? parseMm(String text) {
  return double.tryParse(text.replaceAll(',', '.'));
}

double clampLargura(double value) {
  return value.clamp(_minLarguraMm, _maxLarguraMm).toDouble();
}

double clampAltura(double value) {
  return value.clamp(_minAlturaMm, _maxAlturaMm).toDouble();
}

String? validarLargura(String? value) {
  final largura = parseMm(value ?? '');
  if (largura == null) return 'Informe uma largura válida';
  if (largura < _minLarguraMm || largura > _maxLarguraMm) {
    return 'Largura entre ${_minLarguraMm.toInt()} e ${_maxLarguraMm.toInt()} mm';
  }
  return null;
}

String? validarAltura(String? value) {
  final altura = parseMm(value ?? '');
  if (altura == null) return 'Informe uma altura válida';
  if (altura < _minAlturaMm || altura > _maxAlturaMm) {
    return 'Altura entre ${_minAlturaMm.toInt()} e ${_maxAlturaMm.toInt()} mm';
  }
  return null;
}

Widget buildConfigPanel({
  required BuildContext context,
  required bool isDark,
  required Color card,
  required Color text,
  required Color muted,
  required Color border,
  required DesignEtiquetaModel config,
  required DesignEtiquetaProvider designProvider,
  required TextEditingController larguraController,
  required TextEditingController alturaController,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    designProvider.validation!.message ??
                        'As informações ultrapassam o limite da etiqueta.',
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
          'Ative, ajuste e reordene os campos. Produto, fabricação e validade permanecem obrigatórios no design.',
          style: TextStyle(
            fontSize: 13.5,
            color: muted,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            settingsCard(
              title: 'Tamanho da etiqueta',
              isDark: isDark,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: larguraController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: validarLargura,
                          decoration: inputDecoration(isDark).copyWith(
                            labelText: 'Largura (mm)',
                            hintText: '20 a 111',
                            helperText: 'Mín: 20 | Máx: 111',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: alturaController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: validarAltura,
                          decoration: inputDecoration(isDark).copyWith(
                            labelText: 'Altura (mm)',
                            hintText: '8 a 2000',
                            helperText: 'Mín: 8 | Máx: 2000',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _orange,
                      ),
                      onPressed: () async {
                        final largura = parseMm(larguraController.text);
                        final altura = parseMm(alturaController.text);

                        if (largura == null || altura == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Informe largura e altura válidas.'),
                            ),
                          );
                          return;
                        }

                        if (largura < _minLarguraMm || largura > _maxLarguraMm) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('A largura deve estar entre 20 mm e 111 mm.'),
                            ),
                          );
                          return;
                        }

                        if (altura < _minAlturaMm || altura > _maxAlturaMm) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('A altura deve estar entre 8 mm e 2000 mm.'),
                            ),
                          );
                          return;
                        }

                        final larguraFinal = clampLargura(largura);
                        final alturaFinal = clampAltura(altura);

                        context.read<DesignEtiquetaProvider>().setLarguraMm(larguraFinal);
                        context.read<DesignEtiquetaProvider>().setAlturaMm(alturaFinal);

                        final tipo = context.read<DesignEtiquetaProvider>().tipoSelecionado;
                        if (tipo != null) {
                          await context.read<TiposEtiquetaLocalProvider>().updateMedidas(
                            uid: context.read<AuthProvider>().user!.uid,
                            tipoId: tipo.id,
                            larguraMm: larguraFinal,
                            alturaMm: alturaFinal,
                          );
                        }

                        larguraController.text = larguraFinal.toStringAsFixed(0);
                        alturaController.text = alturaFinal.toStringAsFixed(0);

                      
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tamanho salvo com sucesso.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.straighten_rounded),
                      label: const Text('Salvar tamanho'),
                    ),
                  ),
                ],
              ),
            ),
            settingsCard(
              title: 'Elementos visuais',
              isDark: isDark,
              child: Column(
                children: [
                 switchTile(
                    isDark: isDark,
                    value: config.mostrarMarcaTagValida,
                    title: 'Mostrar "TagVálida"',
                    onChanged: (v) => context
                        .read<DesignEtiquetaProvider>()
                        .setMostrarMarcaTagValida(v),
                  ),
                  switchTile(
                    isDark: isDark,
                    value: config.destacarValidade,
                    title: 'Destacar validade',
                    onChanged: (v) => context
                        .read<DesignEtiquetaProvider>()
                        .setDestacarValidade(v),
                  ),
                ],
              ),
            ),
          ],
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
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: designProvider.loading
                      ? null
                      : () async {
                          await context.read<DesignEtiquetaProvider>().resetAtual();
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
                          await context.read<DesignEtiquetaProvider>().saveAtual();

                          final validation =
                              context.read<DesignEtiquetaProvider>().validation;
                          if (validation != null && !validation.ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  validation.message ??
                                      'O design ultrapassa o limite da etiqueta.',
                                ),
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
          'Arraste para mudar a ordem. Campos obrigatórios ficam sempre ativos.',
          style: TextStyle(
            fontSize: 12.8,
            color: muted,
          ),
        ),
        const SizedBox(height: 12),
        ReorderableListView.builder(
          shrinkWrap: true,
          buildDefaultDragHandles: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: config.campos.length,
         onReorder: (oldIndex, newIndex) {
          final campo = config.campos[oldIndex];
          final isEmpresa = campo.id == 'empresa';
          final isProduto = campo.id == 'produto';
          final isQrCode = campo.tipo == CampoDesignTipo.qrcode || campo.id == 'qrcode';
          final posicaoFixa = isEmpresa || isProduto || isQrCode;

         
          if (posicaoFixa) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Esse campo tem posição fixa na etiqueta'),
              ),
            );
            return; 
          }

          context.read<DesignEtiquetaProvider>().reorderCampos(
                oldIndex,
                newIndex,
              );
        },
          itemBuilder: (context, index) {
            final campo = config.campos[index];
            final isEmpresa = campo.id == 'empresa';
            final isProduto = campo.id == 'produto';
            final isQrCode = campo.tipo == CampoDesignTipo.qrcode || campo.id == 'qrcode';
            final posicaoFixa = isEmpresa || isProduto || isQrCode;

            return Padding(
              key: ValueKey(campo.id),
              padding: const EdgeInsets.only(bottom: 12),
              child: campoConfigTile(
                context: context,
                campo: campo,
                config: config,
                isDark: isDark,
                bloqueado: posicaoFixa, 
                ocultarControlesTexto: isQrCode,
                dragHandle: posicaoFixa
                  ? const SizedBox(width: 42)
                  : ReorderableDragStartListener(
                      index: index,
                      child:  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
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
                  ),
                ),
              onToggle: campo.obrigatorio
                ? null
                : (v) {
                    context.read<DesignEtiquetaProvider>().toggleCampo(
                          campo.id,
                          v ?? false,
                        );
                  },
             onFontChanged: isQrCode
                ? null
                : (value) {
                    context.read<DesignEtiquetaProvider>().setFontSize(campo.id, value);
                  },
            onBoldChanged: isQrCode
                ? null
                : (value) {
                    context.read<DesignEtiquetaProvider>().setBold(campo.id, value);
                  },
            onAlignChanged: isQrCode
                ? null
                : (value) {
                    if (value == null) return;
                    context.read<DesignEtiquetaProvider>().setAlign(campo.id, value);
                  },
              ),
            );
          },
        ),
      ],
    ),
  );
}