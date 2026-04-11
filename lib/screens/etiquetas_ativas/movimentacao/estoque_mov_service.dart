import 'dart:math' as math;
import 'package:uuid/uuid.dart';

import '../../../models/etiqueta_model.dart';
import '../../../models/estoque_mov_model.dart';
import '../../../data/local/repos/etiquetas_local_repo.dart';
import '../../../data/local/repos/estoque_mov_local_repo.dart';
import 'movimentar_estoque_modal.dart';

class EstoqueMovService {
  final EtiquetasLocalRepo etiquetasRepo;
  final EstoqueMovLocalRepo movRepo;

  EstoqueMovService({
    required this.etiquetasRepo,
    required this.movRepo,
  });

  Future<void> salvarMovimentacao({
    required String uid,
    required EtiquetaModel etiqueta,
    required MovimentacaoEstoqueData data,
  }) async {
    final agora = DateTime.now();

    final atual = await etiquetasRepo.getById(
      uid: uid,
      id: etiqueta.id,
    );

    if (atual == null) {
      throw Exception('Etiqueta não encontrada para movimentação.');
    }

    final quantidadeAtual = atual.quantidadeRestante;
    final quantidadeInformada = data.quantidade;

    if (quantidadeInformada == 0) {
      throw Exception('A quantidade não pode ser zero.');
    }

    String tipoMov;
    num quantidadeMov;
    String? motivo = data.observacao.trim().isEmpty ? null : data.observacao.trim();

    num novoRestante = quantidadeAtual;
    String novoStatusEstoque = atual.statusEstoque.trim().isEmpty
        ? 'ativo'
        : atual.statusEstoque.trim();

    switch (data.tipo) {
      case MovimentoEstoqueTipo.venda:
        if (quantidadeInformada <= 0) {
          throw Exception('A quantidade da venda deve ser maior que zero.');
        }
        if (quantidadeInformada > quantidadeAtual) {
          throw Exception('Quantidade maior que o estoque restante.');
        }

        tipoMov = EstoqueMovModel.tipoVenda;
        quantidadeMov = quantidadeInformada;
        novoRestante = quantidadeAtual - quantidadeInformada;

        if (novoRestante <= 0) {
          novoRestante = 0;
          novoStatusEstoque = 'vendido';
        }
        break;

      case MovimentoEstoqueTipo.uso:
        if (quantidadeInformada <= 0) {
          throw Exception('A quantidade de uso deve ser maior que zero.');
        }
        if (quantidadeInformada > quantidadeAtual) {
          throw Exception('Quantidade maior que o estoque restante.');
        }

        tipoMov = EstoqueMovModel.tipoAjusteSaida;
        quantidadeMov = quantidadeInformada;
        novoRestante = quantidadeAtual - quantidadeInformada;
        motivo = _joinMotivo('Uso interno', motivo);

        if (novoRestante <= 0) {
          novoRestante = 0;
          novoStatusEstoque = 'vendido';
        }
        break;

      case MovimentoEstoqueTipo.descarte:
        if (quantidadeInformada <= 0) {
          throw Exception('A quantidade de descarte deve ser maior que zero.');
        }
        if (quantidadeInformada > quantidadeAtual) {
          throw Exception('Quantidade maior que o estoque restante.');
        }

        tipoMov = EstoqueMovModel.tipoAjusteSaida;
        quantidadeMov = quantidadeInformada;
        novoRestante = quantidadeAtual - quantidadeInformada;
        motivo = _joinMotivo('Descarte', motivo);

        if (novoRestante <= 0) {
          novoRestante = 0;
          novoStatusEstoque = 'vendido';
        }
        break;

      case MovimentoEstoqueTipo.ajuste:
        if (quantidadeInformada > 0) {
          tipoMov = EstoqueMovModel.tipoAjusteEntrada;
          quantidadeMov = quantidadeInformada;
          novoRestante = quantidadeAtual + quantidadeInformada;
          novoStatusEstoque = 'ativo';
        } else {
          final qtdSaida = quantidadeInformada.abs();
          if (qtdSaida > quantidadeAtual) {
            throw Exception('Ajuste de saída maior que o estoque restante.');
          }

          tipoMov = EstoqueMovModel.tipoAjusteSaida;
          quantidadeMov = qtdSaida;
          novoRestante = quantidadeAtual - qtdSaida;

          if (novoRestante <= 0) {
            novoRestante = 0;
            novoStatusEstoque = 'vendido';
          }
        }
        break;

      case MovimentoEstoqueTipo.cancelamento:
        if (quantidadeAtual <= 0) {
          throw Exception('Não há saldo restante para cancelar.');
        }

        tipoMov = EstoqueMovModel.tipoCancelamento;
        quantidadeMov = quantidadeAtual;
        novoRestante = 0;
        novoStatusEstoque = 'cancelado';
        motivo = _joinMotivo('Cancelamento da etiqueta', motivo);
        break;
    }

    novoRestante = math.max(0, novoRestante);

    final mov = EstoqueMovModel(
      id: const Uuid().v4(),
      etiquetaId: atual.id,
      produtoNome: atual.produtoNome,
      tipo: tipoMov,
      quantidade: quantidadeMov,
      motivo: motivo,
      createdAt: agora,
      updatedAt: agora,
    );

    final etiquetaAtualizada = atual.copyWith(
        quantidadeRestante: novoRestante,
        statusEstoque: novoStatusEstoque,
        soldAt: novoStatusEstoque == 'vendido' ? agora : atual.soldAt,
      );

      await movRepo.insert(uid, mov);

      await etiquetasRepo.update(uid, etiquetaAtualizada);
    }

  String _joinMotivo(String prefixo, String? motivo) {
    if (motivo == null || motivo.trim().isEmpty) return prefixo;
    return '$prefixo - ${motivo.trim()}';
  }
}