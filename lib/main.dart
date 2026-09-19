import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const BombouApp());
}

// ---------------------------------------------------------------------
// Paleta própria do "Bombou!" — fundo bege quente tipo papel de parede
// do WhatsApp, com marca d'água da palavra "bombou" repetida.
// ---------------------------------------------------------------------
const Color corFundoApp = Color(0xFFEDE0D4); // bege quente
const Color corMarcaDagua = Color(0xFF8C6F5A); // marrom suave (usado com baixa opacidade)
const Color corTextoEscuro = Color(0xFF3A2E27); // texto/ícones fora do canvas
const Color corCoral = Color(0xFFFF4D6D); // destaque principal (CTA)
const Color corLimao = Color(0xFFC6FF3D); // destaque de seleção
const Color corTextoClaro = Color(0xFFF5F1EC); // texto claro, usado dentro do canvas

class BombouApp extends StatelessWidget {
  const BombouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bombou!',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: corFundoApp,
        colorScheme: const ColorScheme.light(
          primary: corCoral,
          secondary: corLimao,
          surface: corFundoApp,
        ),
      ),
      home: const EditorScreen(),
    );
  }
}

// ---------------------------------------------------------------------
// Fundos disponíveis — gradientes vibrantes com nome próprio, não cores
// isoladas genéricas.
// ---------------------------------------------------------------------
class OpcaoFundo {
  final String nome;
  final List<Color> cores;
  const OpcaoFundo(this.nome, this.cores);
}

const List<OpcaoFundo> fundos = [
  OpcaoFundo('Bombou', [Color(0xFFFF4D6D), Color(0xFFFF9B54)]),
  OpcaoFundo('Elétrico', [Color(0xFF7B5EA7), Color(0xFF3D8BFF)]),
  OpcaoFundo('Limão', [Color(0xFF14101B), Color(0xFFC6FF3D)]),
  OpcaoFundo('Pôr do sol', [Color(0xFFFF4D6D), Color(0xFF7B5EA7)]),
  OpcaoFundo('Noite', [Color(0xFF0B0714), Color(0xFF3D2C5A)]),
  OpcaoFundo('Menta', [Color(0xFF00C9A7), Color(0xFF14101B)]),
  OpcaoFundo('Fogo', [Color(0xFFFF4D6D), Color(0xFFFFD23F)]),
  OpcaoFundo('Oceano', [Color(0xFF0B0714), Color(0xFF00B4D8)]),
];

// Emojis disponíveis pra colar na imagem.
const List<String> emojisDisponiveis = [
  '🔥', '😂', '❤️', '😍', '💯', '👏', '😎', '🎉', '💀', '✨',
];

// ---------------------------------------------------------------------
// Fontes disponíveis pro texto — cada uma com uma personalidade
// diferente, usando Google Fonts (baixadas sob demanda).
// ---------------------------------------------------------------------
class OpcaoFonte {
  final String nome;
  final TextStyle Function({required double fontSize, required Color color})
      construtor;

  const OpcaoFonte(this.nome, this.construtor);
}

final List<OpcaoFonte> fontes = [
  OpcaoFonte(
    'Impacto',
    ({required fontSize, required color}) => GoogleFonts.anton(
      fontSize: fontSize,
      color: color,
      height: 1.15,
    ),
  ),
  OpcaoFonte(
    'Arredondada',
    ({required fontSize, required color}) => GoogleFonts.fredoka(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.w600,
      height: 1.15,
    ),
  ),
  OpcaoFonte(
    'Manuscrita',
    ({required fontSize, required color}) => GoogleFonts.pacifico(
      fontSize: fontSize,
      color: color,
      height: 1.15,
    ),
  ),
  OpcaoFonte(
    'Clássica',
    ({required fontSize, required color}) => GoogleFonts.poppins(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.w800,
      height: 1.15,
    ),
  ),
  OpcaoFonte(
    'Máquina',
    ({required fontSize, required color}) => GoogleFonts.spaceMono(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
      height: 1.15,
    ),
  ),
];

// Um emoji colado no canvas: guarda posição, tamanho e uma chave única
// (pra identificar qual remover/mover).
class StickerItem {
  final Key id;
  final String emoji;
  Offset posicao;
  double tamanho;

  StickerItem({
    required this.emoji,
    required this.posicao,
    this.tamanho = 48,
  }) : id = UniqueKey();
}

// ---------------------------------------------------------------------
// Papel de parede do app: a palavra "bombou" repetida na diagonal,
// baixa opacidade, tipo marca d'água — inspirado no wallpaper clássico
// do WhatsApp.
// ---------------------------------------------------------------------
class FundoBombouPainter extends CustomPainter {
  const FundoBombouPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    final corMarca = corMarcaDagua.withValues(alpha: 0.08);

    const espacamentoX = 140.0;
    const espacamentoY = 100.0;

    var linha = 0;
    for (double y = -espacamentoY; y < size.height + espacamentoY; y += espacamentoY) {
      final deslocamentoLinha = (linha.isOdd) ? espacamentoX / 2 : 0.0;
      linha++;

      for (double x = -espacamentoX; x < size.width + espacamentoX; x += espacamentoX) {
        final anguloJitter = (random.nextDouble() - 0.5) * 0.2;
        final tamanhoJitter = 20.0 + random.nextDouble() * 6;

        final textPainter = TextPainter(
          text: TextSpan(
            text: 'bombou',
            style: TextStyle(
              color: corMarca,
              fontSize: tamanhoJitter,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        canvas.save();
        canvas.translate(x + deslocamentoLinha, y);
        canvas.rotate(-0.35 + anguloJitter);
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant FundoBombouPainter oldDelegate) => false;
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  final TextEditingController _textoController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  OpcaoFundo? _fundoSelecionado = fundos[0];
  File? _fotoFundo;
  bool _textoClaro = true;
  double _tamanhoFonte = 32;
  bool _compartilhando = false;
  int _indiceFonteSelecionada = 0;

  Offset _posicaoTexto = Offset.zero;
  Size _tamanhoCanvas = Size.zero;

  final List<StickerItem> _stickers = [];

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  Future<void> _escolherFoto() async {
    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: corFundoApp,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Escolher foto de fundo',
                style: TextStyle(
                  color: corTextoEscuro,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_library, color: corCoral),
                title: const Text(
                  'Galeria',
                  style: TextStyle(color: corTextoEscuro),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: corCoral),
                title: const Text(
                  'Câmera',
                  style: TextStyle(color: corTextoEscuro),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (origem == null) return;

    final arquivo = await _imagePicker.pickImage(
      source: origem,
      imageQuality: 90,
    );
    if (arquivo == null) return;

    setState(() {
      _fotoFundo = File(arquivo.path);
      _fundoSelecionado = null;
    });
  }

  void _adicionarSticker(String emoji) {
    setState(() {
      final deslocamento = (_stickers.length % 5) * 14.0;
      _stickers.add(
        StickerItem(
          emoji: emoji,
          posicao: Offset(deslocamento - 28, deslocamento - 28),
        ),
      );
    });
  }

  void _removerSticker(StickerItem sticker) {
    setState(() => _stickers.remove(sticker));
  }

  Offset _clampNaArea(Offset posicao, double margem) {
    if (_tamanhoCanvas == Size.zero) return posicao;
    final limiteX = (_tamanhoCanvas.width / 2) - margem;
    final limiteY = (_tamanhoCanvas.height / 2) - margem;
    return Offset(
      posicao.dx.clamp(-limiteX, limiteX),
      posicao.dy.clamp(-limiteY, limiteY),
    );
  }

  void _aoArrastarTexto(DragUpdateDetails detalhes) {
    setState(() {
      _posicaoTexto = _clampNaArea(_posicaoTexto + detalhes.delta, 24);
    });
  }

  void _aoArrastarSticker(StickerItem sticker, DragUpdateDetails detalhes) {
    setState(() {
      sticker.posicao = _clampNaArea(sticker.posicao + detalhes.delta, 16);
    });
  }

  Future<void> _compartilhar() async {
    setState(() => _compartilhando = true);

    try {
      final boundary = _canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final imagem = await boundary.toImage(pixelRatio: 3.0);
      final bytesData =
          await imagem.toByteData(format: ui.ImageByteFormat.png);
      if (bytesData == null) return;

      final bytes = bytesData.buffer.asUint8List();
      final diretorio = await getTemporaryDirectory();
      final caminho =
          '${diretorio.path}/bombou_${DateTime.now().millisecondsSinceEpoch}.png';
      final arquivo = File(caminho);
      await arquivo.writeAsBytes(bytes);

      if (!mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(arquivo.path)],
          text: 'Feito com o Bombou! 🔥',
        ),
      );
    } finally {
      if (mounted) setState(() => _compartilhando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: const FundoBombouPainter()),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopo(),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: RepaintBoundary(
                        key: _canvasKey,
                        child: _buildCanvas(),
                      ),
                    ),
                  ),
                ),
                _buildControles(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          const Text(
            'Bombou!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: corTextoEscuro,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _textoClaro = !_textoClaro),
            icon: Icon(
              Icons.contrast,
              color: corTextoEscuro.withValues(alpha: 0.7),
            ),
            tooltip: 'Cor do texto',
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final tamanhoAtual =
              Size(constraints.maxWidth, constraints.maxHeight);
          if (_tamanhoCanvas != tamanhoAtual && mounted) {
            setState(() => _tamanhoCanvas = tamanhoAtual);
          }
        });

        final fonteAtual = fontes[_indiceFonteSelecionada];
        final corTexto = _textoClaro ? Colors.white : const Color(0xFF14101B);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: corTextoEscuro.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            gradient: _fotoFundo == null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _fundoSelecionado!.cores,
                  )
                : null,
            image: _fotoFundo != null
                ? DecorationImage(
                    image: FileImage(_fotoFundo!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Center(
                  child: Transform.translate(
                    offset: _posicaoTexto,
                    child: GestureDetector(
                      onPanUpdate: _aoArrastarTexto,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _textoController.text.isEmpty
                              ? 'Toque abaixo\ne escreva algo'
                              : _textoController.text,
                          textAlign: TextAlign.center,
                          style: fonteAtual
                              .construtor(
                                fontSize: _tamanhoFonte,
                                color: corTexto,
                              )
                              .copyWith(
                                shadows: _textoClaro
                                    ? [
                                        const Shadow(
                                          color: Colors.black26,
                                          blurRadius: 12,
                                          offset: Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                for (final sticker in _stickers)
                  Center(
                    key: sticker.id,
                    child: Transform.translate(
                      offset: sticker.posicao,
                      child: GestureDetector(
                        onPanUpdate: (detalhes) =>
                            _aoArrastarSticker(sticker, detalhes),
                        onLongPress: () => _removerSticker(sticker),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            sticker.emoji,
                            style: TextStyle(fontSize: sticker.tamanho),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 14,
                  bottom: 12,
                  child: Text(
                    'bombou!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: (_textoClaro ? Colors.white : Colors.black)
                          .withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControles() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: fundos.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final selecionado = _fotoFundo != null;
                  return GestureDetector(
                    onTap: _escolherFoto,
                    child: Container(
                      width: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: corTextoEscuro.withValues(alpha: 0.06),
                        image: _fotoFundo != null
                            ? DecorationImage(
                                image: FileImage(_fotoFundo!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        border: selecionado
                            ? Border.all(color: corCoral, width: 3)
                            : Border.all(
                                color: corTextoEscuro.withValues(alpha: 0.2),
                              ),
                      ),
                      child: _fotoFundo == null
                          ? const Icon(Icons.add_a_photo,
                              color: corTextoEscuro, size: 22)
                          : null,
                    ),
                  );
                }

                final fundo = fundos[index - 1];
                final selecionado =
                    _fotoFundo == null && fundo == _fundoSelecionado;
                return GestureDetector(
                  onTap: () => setState(() {
                    _fundoSelecionado = fundo;
                    _fotoFundo = null;
                  }),
                  child: Container(
                    width: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: fundo.cores),
                      border: selecionado
                          ? Border.all(color: corCoral, width: 3)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: emojisDisponiveis.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final emoji = emojisDisponiveis[index];
                return GestureDetector(
                  onTap: () => _adicionarSticker(emoji),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: corTextoEscuro.withValues(alpha: 0.06),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: fontes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final fonte = fontes[index];
                final selecionada = index == _indiceFonteSelecionada;
                return GestureDetector(
                  onTap: () => setState(() => _indiceFonteSelecionada = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: selecionada
                          ? corCoral.withValues(alpha: 0.15)
                          : corTextoEscuro.withValues(alpha: 0.06),
                      border: selecionada
                          ? Border.all(color: corCoral, width: 1.5)
                          : null,
                    ),
                    child: Text(
                      'Aa',
                      style: fonte.construtor(
                        fontSize: 18,
                        color: selecionada ? corCoral : corTextoEscuro,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _textoController,
            maxLines: 2,
            maxLength: 80,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: corTextoEscuro),
            decoration: InputDecoration(
              hintText: 'Escreva sua frase...',
              hintStyle: TextStyle(color: corTextoEscuro.withValues(alpha: 0.4)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.5),
              counterStyle: TextStyle(color: corTextoEscuro.withValues(alpha: 0.4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Tamanho', style: TextStyle(color: corTextoEscuro)),
              Expanded(
                child: Slider(
                  value: _tamanhoFonte,
                  min: 18,
                  max: 52,
                  activeColor: corCoral,
                  inactiveColor: corTextoEscuro.withValues(alpha: 0.15),
                  onChanged: (v) => setState(() => _tamanhoFonte = v),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _posicaoTexto = Offset.zero),
                icon: const Icon(Icons.center_focus_strong, size: 20),
                color: corTextoEscuro.withValues(alpha: 0.6),
                tooltip: 'Centralizar texto',
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: _compartilhando ? null : _compartilhar,
              style: FilledButton.styleFrom(
                backgroundColor: corCoral,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: _compartilhando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.ios_share),
              label: Text(
                _compartilhando ? 'Gerando...' : 'Compartilhar no Status',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}