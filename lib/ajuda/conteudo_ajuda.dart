/// O manual do Bombou! dentro do app. O "?" do editor abre o manual
/// completo; o de Minhas criações abre a parte dele.
/// Tudo fica no próprio app: funciona sem internet.
///
/// Pra mudar o texto, é só mexer aqui. Dá pra marcar **negrito** com
/// dois asteriscos de cada lado.
library;

import 'package:flutter/material.dart';

/// As partes do manual.
enum SecaoAjuda {
  comecar,
  fundo,
  texto,
  emojis,
  compartilhar,
  historico,
  duvidas,
}

/// Um pedaço do texto de uma parte do manual.
sealed class BlocoAjuda {
  const BlocoAjuda();

  /// Todo o texto do bloco, usado na busca.
  String get textoBusca;
}

/// Um parágrafo comum.
class Paragrafo extends BlocoAjuda {
  final String texto;
  const Paragrafo(this.texto);

  @override
  String get textoBusca => texto;
}

/// Um título pequeno dentro da parte.
class Subtitulo extends BlocoAjuda {
  final String texto;
  const Subtitulo(this.texto);

  @override
  String get textoBusca => texto;
}

/// Passo a passo numerado.
class Passos extends BlocoAjuda {
  final List<String> itens;
  const Passos(this.itens);

  @override
  String get textoBusca => itens.join(' ');
}

/// Lista com marcadores (sem ordem).
class Itens extends BlocoAjuda {
  final List<String> itens;
  const Itens(this.itens);

  @override
  String get textoBusca => itens.join(' ');
}

/// Tabela pequena: a primeira lista é o cabeçalho.
class Tabela extends BlocoAjuda {
  final List<String> cabecalho;
  final List<List<String>> linhas;
  const Tabela(this.cabecalho, this.linhas);

  @override
  String get textoBusca =>
      [...cabecalho, for (final l in linhas) ...l].join(' ');
}

/// Caixinha de destaque: dica ou atenção.
class Dica extends BlocoAjuda {
  final String texto;

  /// true = atenção (cor de alerta); false = dica.
  final bool atencao;
  const Dica(this.texto, {this.atencao = false});

  @override
  String get textoBusca => texto;
}

/// Uma parte do manual.
class TopicoAjuda {
  final SecaoAjuda secao;
  final String titulo;

  /// Uma linha que aparece embaixo do título na lista.
  final String resumo;
  final IconData icone;
  final List<BlocoAjuda> blocos;

  const TopicoAjuda({
    required this.secao,
    required this.titulo,
    required this.resumo,
    required this.icone,
    required this.blocos,
  });

  /// Tudo o que dá pra buscar nesta parte, sem acento e minúsculo.
  String get textoBusca => semAcento(
      [titulo, resumo, for (final b in blocos) b.textoBusca].join(' '));
}

/// A parte do manual de uma seção.
TopicoAjuda topicoAjuda(SecaoAjuda secao) =>
    manualBombou.firstWhere((t) => t.secao == secao);

/// Tira acento, os asteriscos do negrito e deixa minúsculo, pra busca
/// achar "proporcao" em "Proporção".
String semAcento(String texto) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  const para = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';
  final b = StringBuffer();
  for (final ch in texto.replaceAll('**', '').split('')) {
    final i = de.indexOf(ch);
    b.write(i >= 0 ? para[i] : ch);
  }
  return b.toString().toLowerCase();
}


/// O manual completo, na ordem em que aparece na lista.
const manualBombou = <TopicoAjuda>[
  // ---------------------------------------------------------------
  TopicoAjuda(
    secao: SecaoAjuda.comecar,
    titulo: 'Primeiros passos',
    resumo: 'Do zero ao Status em quatro passos',
    icone: Icons.flag_outlined,
    blocos: [
      Paragrafo(
          'O Bombou! cria figurinhas e memes para o Status do WhatsApp: um '
          'fundo colorido ou uma foto, a sua frase por cima e emojis. Tudo '
          'na mesma tela.'),
      Passos([
        'Escolha a **proporção** e o **fundo** (um degradê ou uma foto sua).',
        'Escreva a sua frase no campo embaixo da imagem.',
        'Ajuste a fonte, o tamanho e as cores, e cole emojis se quiser.',
        'Toque em **Compartilhar no Status**.',
      ]),
      Subtitulo('Botões do topo'),
      Itens([
        '**Grade (Minhas criações):** tudo o que você já compartilhou.',
        '**?:** este manual.',
      ]),
    ],
  ),
  // ---------------------------------------------------------------
  TopicoAjuda(
    secao: SecaoAjuda.fundo,
    titulo: 'Proporção e fundo',
    resumo: 'Formato da imagem, degradês e foto',
    icone: Icons.wallpaper_outlined,
    blocos: [
      Subtitulo('Proporção'),
      Paragrafo('Na primeira fileira de botões, escolha o formato:'),
      Tabela([
        'Proporção',
        'Melhor para'
      ], [
        ['Status (9:16)', 'Status do WhatsApp, tela cheia'],
        ['Quadrado (1:1)', 'Posts e figurinhas'],
        ['Retrato (4:5)', 'Posts em pé'],
        ['Paisagem (16:9)', 'Imagens deitadas'],
      ]),
      Subtitulo('Fundo'),
      Paragrafo(
          'Na fileira de bolinhas, toque em um degradê: Bombou, Elétrico, '
          'Limão, Pôr do sol, Noite, Menta, Fogo ou Oceano. Arraste para o '
          'lado para ver todos.'),
      Paragrafo(
          '**Foto sua:** toque na primeira bolinha e escolha Galeria ou '
          'Câmera. A foto vira o fundo da imagem.'),
    ],
  ),
  // ---------------------------------------------------------------
  TopicoAjuda(
    secao: SecaoAjuda.texto,
    titulo: 'Texto',
    resumo: 'Fonte, tamanho, cores, mover e girar',
    icone: Icons.text_fields,
    blocos: [
      Paragrafo(
          'Escreva a frase no campo **Escreva sua frase...**. Ela aparece por '
          'cima da imagem na hora.'),
      Subtitulo('Fonte e tamanho'),
      Paragrafo(
          'Toque em um dos botões **Aa** para escolher a fonte: Impacto, '
          'Arredondada, Manuscrita, Clássica ou Máquina. Use a barra '
          '**Tamanho** para aumentar ou diminuir as letras.'),
      Subtitulo('Cores'),
      Itens([
        'Toque em uma cor da paleta para pintar o texto todo.',
        '**Uma palavra de outra cor:** com mais de uma palavra, aparecem '
            'botõezinhos com cada palavra. Toque na palavra e depois na cor.',
        'Para voltar a palavra à cor padrão, segure o dedo no botão dela. '
            'Toque de novo na palavra marcada para voltar a pintar o texto '
            'todo.',
      ]),
      Subtitulo('Mover e girar'),
      Itens([
        '**Mover:** arraste o texto com um dedo.',
        '**Girar:** torça com dois dedos em cima do texto.',
        '**Centralizar:** o botão de centralizar volta o texto para o meio, '
            'sem rotação.',
      ]),
      Dica('A sombra do texto muda sozinha conforme a cor, para a frase '
          'aparecer em qualquer fundo.'),
    ],
  ),
  // ---------------------------------------------------------------
  TopicoAjuda(
    secao: SecaoAjuda.emojis,
    titulo: 'Emojis',
    resumo: 'Colar, mover, aumentar e tirar',
    icone: Icons.emoji_emotions_outlined,
    blocos: [
      Itens([
        '**Colar:** toque em um emoji da fileira (🔥 😂 ❤️ 😍 💯 👏 😎 🎉 💀 '
            '✨). Ele aparece na imagem. Dá para colar quantos quiser.',
        '**Mover:** arraste o emoji com um dedo.',
        '**Aumentar ou diminuir:** abra ou feche dois dedos em cima dele '
            '(pinça).',
        '**Tirar:** segure o dedo em cima do emoji.',
      ]),
    ],
  ),
  // ---------------------------------------------------------------
  TopicoAjuda(
    secao: SecaoAjuda.compartilhar,
    titulo: 'Compartilhar no Status',
    resumo: 'Enviar, galeria e histórico',
    icone: Icons.ios_share,
    blocos: [
      Paragrafo(
          'Toque em **Compartilhar no Status**. Espere o "Gerando..." e '
          'escolha o WhatsApp (ou outro app) na janela do celular.'),
      Paragrafo('Ao compartilhar, o Bombou! também:'),
      Itens([
        'guarda uma cópia em **Minhas criações**, dentro do app;',
        'tenta salvar a imagem na galeria do celular, no álbum **Bombou**.',
      ]),
      Dica('Se a galeria não deixar salvar, a criação continua guardada em '
          'Minhas criações.'),
    ],
  ),
  // ---------------------------------------------------------------
  TopicoAjuda(
    secao: SecaoAjuda.historico,
    titulo: 'Minhas criações',
    resumo: 'Rever, compartilhar de novo ou excluir',
    icone: Icons.grid_view_rounded,
    blocos: [
      Paragrafo(
          'Toque no ícone de grade, no topo do editor. Aparecem todas as '
          'imagens que você já compartilhou.'),
      Itens([
        'Toque em uma imagem para abrir grande.',
        'Toque no botão de compartilhar para mandar de novo.',
        'Toque na lixeira para excluir do app.',
      ]),
    ],
  ),
  // ---------------------------------------------------------------
  TopicoAjuda(
    secao: SecaoAjuda.duvidas,
    titulo: 'Perguntas frequentes',
    resumo: 'As dúvidas mais comuns',
    icone: Icons.quiz_outlined,
    blocos: [
      Subtitulo('A fonte demorou para aparecer.'),
      Paragrafo(
          'Na primeira vez, cada fonte é baixada da internet. Depois disso, '
          'ela fica no celular.'),
      Subtitulo('A imagem não foi para a galeria.'),
      Paragrafo(
          'Confira se o app tem permissão para fotos nas configurações do '
          'Android. A criação continua em Minhas criações.'),
      Subtitulo('Não consigo mexer no texto.'),
      Paragrafo(
          'Toque e arraste em cima das letras. Para girar, use dois dedos ao '
          'mesmo tempo em cima do texto.'),
      Subtitulo('Preciso de internet?'),
      Paragrafo(
          'Só para baixar as fontes na primeira vez e para mandar no '
          'WhatsApp. Criar e editar funcionam sem internet.'),
    ],
  ),
];
