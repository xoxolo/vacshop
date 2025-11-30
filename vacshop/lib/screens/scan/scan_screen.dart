import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../config/theme.dart';
import '../../services/vlm_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isScanning = false;
  final _vlmService = VLMService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      
      if (_cameras!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune caméra disponible'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('❌ Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      // Prendre la photo
      final XFile image = await _cameraController!.takePicture();
      
      // Analyser avec le VLM
      if (_vlmService.isReady) {
        final result = await _vlmService.scanImage(image.path);
        
        if (mounted) {
          // Naviguer vers l'écran de résultat
          // TODO: Créer ScanResultScreen et naviguer
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Prix détecté: ${result.amount} ${result.currency} (${(result.confidence * 100).toStringAsFixed(1)}%)',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Le modèle VLM n\'est pas encore chargé'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la prise de photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _cameraController == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),
          
          // Overlay avec cadre de scan
          Positioned.fill(
            child: CustomPaint(
              painter: ScanOverlayPainter(),
            ),
          ),
          
          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flash_off, color: Colors.white, size: 28),
                    onPressed: () {
                      // TODO: Toggle flash
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.15,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Positionnez le prix dans le cadre',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Bouton de capture
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: _isScanning 
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.3),
                  ),
                  child: _isScanning
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 40,
                        ),
                ),
              ),
            ),
          ),
          
          // Conseils en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 140,
            child: Column(
              children: [
                _ScanTip(
                  icon: Icons.wb_sunny_outlined,
                  text: 'Utilisez un bon éclairage',
                ),
                const SizedBox(height: 8),
                _ScanTip(
                  icon: Icons.center_focus_strong,
                  text: 'Cadrez bien le prix',
                ),
                const SizedBox(height: 8),
                _ScanTip(
                  icon: Icons.photo_camera,
                  text: 'Tenez l\'appareil stable',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Zone de scan (carré au centre)
    final scanWidth = size.width * 0.7;
    final scanHeight = scanWidth * 0.6;
    final scanLeft = (size.width - scanWidth) / 2;
    final scanTop = size.height * 0.35;

    final scanRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(scanLeft, scanTop, scanWidth, scanHeight),
      const Radius.circular(20),
    );

    path.addRRect(scanRect);
    path.fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Bordure du cadre de scan
    final borderPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(scanRect, borderPaint);

    // Coins du cadre
    final cornerPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final cornerLength = 30.0;

    // Coin supérieur gauche
    canvas.drawLine(
      Offset(scanLeft, scanTop + cornerLength),
      Offset(scanLeft, scanTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanLeft, scanTop),
      Offset(scanLeft + cornerLength, scanTop),
      cornerPaint,
    );

    // Coin supérieur droit
    canvas.drawLine(
      Offset(scanLeft + scanWidth - cornerLength, scanTop),
      Offset(scanLeft + scanWidth, scanTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanLeft + scanWidth, scanTop),
      Offset(scanLeft + scanWidth, scanTop + cornerLength),
      cornerPaint,
    );

    // Coin inférieur gauche
    canvas.drawLine(
      Offset(scanLeft, scanTop + scanHeight - cornerLength),
      Offset(scanLeft, scanTop + scanHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanLeft, scanTop + scanHeight),
      Offset(scanLeft + cornerLength, scanTop + scanHeight),
      cornerPaint,
    );

    // Coin inférieur droit
    canvas.drawLine(
      Offset(scanLeft + scanWidth - cornerLength, scanTop + scanHeight),
      Offset(scanLeft + scanWidth, scanTop + scanHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanLeft + scanWidth, scanTop + scanHeight - cornerLength),
      Offset(scanLeft + scanWidth, scanTop + scanHeight),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanTip extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const _ScanTip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.secondary, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
