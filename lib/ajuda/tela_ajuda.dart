import 'package:flutter/material.dart';

import 'conteudo_ajuda.dart';

/// Manual completo: todas as partes, com busca. Abre pelo "?" da
/// tela inicial.
class TelaAjuda extends StatefulWidget {
  const TelaAjuda({super.key});

  @override
  State<TelaAjuda> createState() => _TelaAjudaState();
}

class _TelaAjudaState extends State<TelaAjuda> {
  final _busca = TextEditingController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termo = semAcento(_busca.text.trim());
    final topicos = termo.isEmpty
        ? manualBombou
        : manualBombou.where((t) => t.textoBusca.contains(termo)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Manual do Bombou!')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              key: const Key('buscaAjuda'),
              controller: _busca,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar no manual (ex.: emoji, foto)',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _busca.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(_busca.clear),
                      ),
              ),
            ),
          ),
          if (topicos.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Nada encontrado para "${_busca.text.trim()}".',
                textAlign: TextAlign.center,
              ),
            ),
          for (final t in topicos)
            ListTile(
              key: Key('topico_${t.secao.name}'),
              leading: Icon(t.icone),
              title: Text(t.titulo),
              subtitle: Text(t.resumo),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    TelaTopicoAjuda(secao: t.secao, mostrarManual: false),
              )),
            ),
        ],
      ),
    );
  }
}

/// Uma parte do manual. É o que o "?" de cada tela abre.
class TelaTopicoAjuda extends StatelessWidget {
  final SecaoAjuda secao;

  /// Mostra o botão "Ver o manual completo" no fim (false quando já
  /// veio do manual).
  final bool mostrarManual;

  const TelaTopicoAjuda({
    super.key,
    required this.secao,
    this.mostrarManual = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = topicoAjuda(secao);
    return Scaffold(
      appBar: AppBar(title: Text(t.titulo)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          for (final b in t.blocos) _bloco(context, b),
          if (mostrarManual) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              key: const Key('verManualCompleto'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const TelaAjuda(),
              )),
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Ver o manual completo'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bloco(BuildContext context, BlocoAjuda b) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    return switch (b) {
      Paragrafo(:final texto) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextoAjuda(texto),
        ),
      Subtitulo(:final texto) => Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(texto,
              style: tema.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
      Passos(:final itens) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              for (var i = 0; i < itens.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: cores.primary,
                        foregroundColor: cores.onPrimary,
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: TextoAjuda(itens[i])),
                    ],
                  ),
                ),
            ],
          ),
        ),
      Itens(:final itens) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              for (final item in itens)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2, right: 8),
                        child: Text('•'),
                      ),
                      Expanded(child: TextoAjuda(item)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      Tabela(:final cabecalho, :final linhas) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Table(
            border: TableBorder.all(color: cores.outlineVariant),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration:
                    BoxDecoration(color: cores.surfaceContainerHighest),
                children: [
                  for (final c in cabecalho)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(c,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              for (final linha in linhas)
                TableRow(children: [
                  for (final c in linha)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextoAjuda(c),
                    ),
                ]),
            ],
          ),
        ),
      Dica(:final texto, :final atencao) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            margin: EdgeInsets.zero,
            color: atencao ? cores.errorContainer : cores.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    atencao ? Icons.warning_amber_rounded : Icons.lightbulb_outline,
                    color: atencao
                        ? cores.onErrorContainer
                        : cores.onSecondaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextoAjuda(
                      texto,
                      cor: atencao
                          ? cores.onErrorContainer
                          : cores.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    };
  }
}

/// Texto do manual com **negrito** marcado por dois asteriscos.
class TextoAjuda extends StatelessWidget {
  final String texto;
  final Color? cor;

  const TextoAjuda(this.texto, {super.key, this.cor});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyLarge?.copyWith(color: cor);
    final partes = texto.split('**');
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          // As partes ímpares ficam entre ** e **: negrito
          for (var i = 0; i < partes.length; i++)
            TextSpan(
              text: partes[i],
              style: i.isOdd ? const TextStyle(fontWeight: FontWeight.bold) : null,
            ),
        ],
      ),
    );
  }
}
