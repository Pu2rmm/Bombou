import 'package:bombou/ajuda/botao_ajuda.dart';
import 'package:bombou/ajuda/conteudo_ajuda.dart';
import 'package:bombou/ajuda/tela_ajuda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cada seção tem uma parte no manual, sem repetir', () {
    for (final s in SecaoAjuda.values) {
      expect(manualBombou.where((t) => t.secao == s), hasLength(1),
          reason: s.name);
    }
  });

  test('toda tabela tem o mesmo número de colunas em todas as linhas', () {
    for (final t in manualBombou) {
      for (final b in t.blocos.whereType<Tabela>()) {
        for (final linha in b.linhas) {
          expect(linha.length, b.cabecalho.length, reason: t.titulo);
        }
      }
    }
  });

  test('a busca ignora acento, maiúscula e negrito', () {
    expect(semAcento('Proporção ÇÃO **Status**'), 'proporcao cao status');
    expect(topicoAjuda(SecaoAjuda.fundo).textoBusca, contains('proporcao'));
  });

  testWidgets('o manual lista as partes e a busca filtra', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TelaAjuda()));
    expect(find.text('Primeiros passos'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('buscaAjuda')), 'emoji');
    await tester.pump();
    expect(find.byKey(const Key('topico_emojis')), findsOneWidget);
    expect(find.byKey(const Key('topico_historico')), findsNothing);

    await tester.enterText(find.byKey(const Key('buscaAjuda')), 'xyzxyz');
    await tester.pump();
    expect(find.textContaining('Nada encontrado'), findsOneWidget);
  });

  testWidgets('o ? abre a parte certa, e todas as partes desenham',
      (tester) async {
    for (final s in SecaoAjuda.values) {
      // Chave nova a cada volta: começa do zero, sem a tela anterior aberta
      await tester.pumpWidget(MaterialApp(
        key: ValueKey(s),
        home: Scaffold(appBar: AppBar(actions: [BotaoAjuda(s)])),
      ));
      await tester.tap(find.byKey(Key('ajuda_${s.name}')));
      await tester.pumpAndSettle();

      expect(find.text(topicoAjuda(s).titulo), findsWidgets, reason: s.name);
      expect(tester.takeException(), isNull, reason: s.name);
    }
  });

  testWidgets('o ? da tela inicial abre o manual completo', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(appBar: AppBar(actions: const [BotaoManual()])),
    ));
    await tester.tap(find.byKey(const Key('ajudaManual')));
    await tester.pumpAndSettle();
    expect(find.text('Manual do Bombou!'), findsOneWidget);
    expect(find.byKey(const Key('topico_comecar')), findsOneWidget);
  });
}
