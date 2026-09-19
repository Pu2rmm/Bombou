import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const BombouApp());
}

// ---------------------------------------------------------------------
// Paleta própria do "Bombou!" — nada de Material padrão genérico.
// ---------------------------------------------------------------------
const Color corFundoApp = Color(0xFF14101B); // roxo-ardósia bem escuro
const Color corCoral = Color(0xFFFF4D6D); // destaque principal (CTA)
const Color corLimao = Color(0xFFC6FF3D); // destaque de seleção
const Color corTextoClaro = Color(0xFFF5F1EC);

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
        colorScheme: const ColorScheme.dark(
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
                  color: corTextoClaro,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_library, color: corLimao),
                title: const Text(
                  'Galeria',
                  style: TextStyle(color: corTextoClaro),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: corLimao),
                title: const Text(
                  'Câmera',
                  style: TextStyle(color: corTextoClaro),
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
      body: SafeArea(
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
              color: corTextoClaro,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _textoClaro = !_textoClaro),
            icon: Icon(
              Icons.contrast,
              color: corTextoClaro.withValues(alpha: 0.7),
            ),
            tooltip: 'Cor do texto',
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Text(
                _textoController.text.isEmpty
                    ? 'Toque abaixo\ne escreva algo'
                    : _textoController.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _tamanhoFonte,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: _textoClaro ? Colors.white : const Color(0xFF14101B),
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
                        color: Colors.white.withValues(alpha: 0.08),
                        image: _fotoFundo != null
                            ? DecorationImage(
                                image: FileImage(_fotoFundo!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        border: selecionado
                            ? Border.all(color: corLimao, width: 3)
                            : Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                      ),
                      child: _fotoFundo == null
                          ? const Icon(Icons.add_a_photo,
                              color: corTextoClaro, size: 22)
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
                          ? Border.all(color: corLimao, width: 3)
                          : null,
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
            style: const TextStyle(color: corTextoClaro),
            decoration: InputDecoration(
              hintText: 'Escreva sua frase...',
              hintStyle: TextStyle(color: corTextoClaro.withValues(alpha: 0.4)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              counterStyle: TextStyle(color: corTextoClaro.withValues(alpha: 0.4)),
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
              const Text('Tamanho', style: TextStyle(color: corTextoClaro)),
              Expanded(
                child: Slider(
                  value: _tamanhoFonte,
                  min: 18,
                  max: 52,
                  activeColor: corLimao,
                  inactiveColor: Colors.white24,
                  onChanged: (v) => setState(() => _tamanhoFonte = v),
                ),
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