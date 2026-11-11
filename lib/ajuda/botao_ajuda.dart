import 'package:flutter/material.dart';

import 'conteudo_ajuda.dart';
import 'tela_ajuda.dart';

export 'conteudo_ajuda.dart' show SecaoAjuda;

/// O "?" no topo das telas: abre a parte do manual daquela tela.
class BotaoAjuda extends StatelessWidget {
  final SecaoAjuda secao;

  /// Cor do ícone (null = a do tema).
  final Color? cor;

  const BotaoAjuda(this.secao, {super.key, this.cor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: Key('ajuda_${secao.name}'),
      tooltip: 'Ajuda',
      icon: Icon(Icons.help_outline_rounded, color: cor),
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TelaTopicoAjuda(secao: secao),
      )),
    );
  }
}

/// O "?" da tela inicial: abre o manual completo, com todas as partes.
class BotaoManual extends StatelessWidget {
  /// Cor do ícone (null = a do tema).
  final Color? cor;

  const BotaoManual({super.key, this.cor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('ajudaManual'),
      tooltip: 'Manual do app',
      icon: Icon(Icons.help_outline_rounded, color: cor),
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const TelaAjuda(),
      )),
    );
  }
}
