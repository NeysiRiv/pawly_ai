import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class FindBuddyScreen extends StatefulWidget {
  final String dogImage;

  const FindBuddyScreen({super.key, required this.dogImage});

  @override
  State<FindBuddyScreen> createState() => _FindBuddyScreenState();
}

class _FindBuddyScreenState extends State<FindBuddyScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isReady = false;
  bool _isWalking = false;
  String _error = '';

  // PASOS
  int _steps = 0;
  int _initialSteps = 0;
  late Stream<StepCount> _stepCountStream;

  // ANIMACIÓN PERRO
  late AnimationController _animController;
  late Animation<double> _bounceAnim;

  // VIDEO PERRO
  VideoPlayerController? _dogVideoController;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'No camera found');
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      // Inicializar video del perro
      // Usá el archivo correcto según plataforma:
      //   Android → assets/dog_loop.webm  (soporta alpha nativo)
      //   iOS     → assets/dog_loop.mov   (soporta alpha nativo)
      // Si usás fondo negro, cualquier formato funciona con BlendMode.screen
      // _dogVideoController = VideoPlayerController.asset('assets/Hund_video.mp4');
     // await _dogVideoController!.initialize();
     // _dogVideoController!.setLooping(true);
      //_dogVideoController!.play();

      if (mounted) {
        setState(() {
          _isReady = true;
          _videoReady = true;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _startWalking() async {
    if (await Permission.activityRecognition.request().isGranted) {
      setState(() => _isWalking = true);

      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(
            (StepCount event) {
          if (_initialSteps == 0) {
            _initialSteps = event.steps;
          }
          if (mounted) {
            setState(() => _steps = event.steps - _initialSteps);
          }
        },
        onError: (error) {
          if (mounted)
            setState(() => _error = 'Step counter not available: $error');
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity permission required!')),
      );
    }
  }

  void _stopWalking() {
    setState(() {
      _isWalking = false;
      _initialSteps = 0;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animController.dispose();
    _dogVideoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          // ── CAPA 1: CÁMARA REAL DE FONDO ──────────────────────────────
          if (_isReady && _controller != null)
            Positioned.fill(
              child: CameraPreview(_controller!),
            )
          else if (_error.isNotEmpty)
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            const Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF4CAF50)),
                    SizedBox(height: 16),
                    Text('Starting camera...',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

          // ── CAPA 2: PERRO ANIMADO (video o imagen fallback) ───────────
          if (_isReady)
            Positioned(
              bottom: 180,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _bounceAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_bounceAnim.value),
                    child: child,
                  );
                },
                child: _videoReady && _dogVideoController != null
                    ? SizedBox(
                  height: 220,
                  child: AspectRatio(
                    aspectRatio: _dogVideoController!.value.aspectRatio,
                    // Si el video tiene fondo negro, descomentá el
                    // ColorFiltered de abajo para hacerlo transparente:
                    //
                    // child: ColorFiltered(
                    //   colorFilter: const ColorFilter.mode(
                    //     Colors.black,
                    //     BlendMode.multiply,
                    //   ),
                    //   child: VideoPlayer(_dogVideoController!),
                    // ),
                    child: VideoPlayer(_dogVideoController!),
                  ),
                )
                // Fallback: imagen estática si el video no cargó
                    : Image.asset(
                  widget.dogImage,
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // ── ESQUINAS AR ────────────────────────────────────────────────
          if (_isReady) ...[
            _arCorner(top: 40, left: 20),
            _arCorner(top: 40, right: 20, flipH: true),
            _arCorner(bottom: 220, left: 20, flipV: true),
            _arCorner(bottom: 220, right: 20, flipH: true, flipV: true),
          ],

          // ── STATS ARRIBA ───────────────────────────────────────────────
          if (_isReady)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Pawly AI 🐾',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    _miniStat('HUNGER', 0.85, const Color(0xFFE53935)),
                    _miniStat('HAPPINESS', 0.92, const Color(0xFF43A047)),
                    _miniStat('ENERGY', 0.74, const Color(0xFFFFA000)),
                  ],
                ),
              ),
            ),

          // ── CONTADOR DE PASOS (solo cuando está caminando) ─────────────
          if (_isReady && _isWalking)
            Positioned(
              bottom: 160,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.directions_walk,
                        color: Color(0xFF4CAF50), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'STEPS: ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$_steps',
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── BOTONES ABAJO ──────────────────────────────────────────────
          if (_isReady)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                children: [

                  // BOTÓN WALK WITH PAWLY
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isWalking ? _stopWalking : _startWalking,
                      icon: Icon(
                        _isWalking ? Icons.stop : Icons.directions_walk,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isWalking ? 'Stop Walk' : 'Walk with Pawly 🐾',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isWalking
                            ? const Color(0xFFEF5350)
                            : const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // BOTÓN VOLVER
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: const Color(0xFFF0F0F0),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('${(value * 100).toInt()}%',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }

  Widget _arCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    bool flipH = false,
    bool flipV = false,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.scale(
        scaleX: flipH ? -1 : 1,
        scaleY: flipV ? -1 : 1,
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFF4CAF50), width: 3),
              left: BorderSide(color: Color(0xFF4CAF50), width: 3),
            ),
          ),
        ),
      ),
    );
  }
}