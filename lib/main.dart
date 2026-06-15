import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Kunci orientasi ke Portrait karena desain ini khusus mobile portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

// Global Notifier untuk Mode Low Vision (Kontras Tinggi)
final ValueNotifier<bool> isLowVisionNotifier = ValueNotifier<bool>(false);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLowVisionNotifier,
      builder: (context, isLowVision, child) {
        return MaterialApp(
          title: 'Netravest Aksesibilitas',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: isLowVision ? Colors.black : const Color(0xFF07080F),
            fontFamily: 'Roboto',
          ),
          builder: (context, child) {
            // Mengatur skala ukuran font secara global saat mode Low Vision aktif
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: isLowVision ? 1.6 : 1.0,
              ),
              child: child!,
            );
          },
          home: const DashboardScreen(),
        );
      },
    );
  }
}

// =========================================================================
// WIDGET STYLING: LIQUID GLASS & HIGH CONTRAST CARD
// =========================================================================
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final bool isHovered;
  final Color glowColor;
  final double borderRadius;
  final Color? customBgColor;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.isHovered = false,
    this.glowColor = const Color(0xFFFF5400),
    this.borderRadius = 24.0,
    this.customBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLowVisionNotifier,
      builder: (context, isLowVision, _) {
        if (isLowVision) {
          // Desain Kontras Tinggi Ekstrim untuk Penyandang Gangguan Penglihatan (Low-Vision)
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isHovered ? const Color(0xFFFFFF00) : Colors.black,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: const Color(0xFFFFFF00),
                width: isHovered ? 6.0 : 4.0,
              ),
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: isHovered ? Colors.black : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
              child: child,
            ),
          );
        }

        // Desain Liquid Glassmorphism Premium untuk Pengguna Umum
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: glowColor.withOpacity(0.45),
                      blurRadius: 28,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: -2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: -4,
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: isHovered
                        ? glowColor.withOpacity(0.9)
                        : Colors.white.withOpacity(0.12),
                    width: isHovered ? 2.5 : 1.2,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isHovered
                        ? [
                            glowColor.withOpacity(0.28),
                            glowColor.withOpacity(0.08),
                          ]
                        : [
                            customBgColor ?? Colors.white.withOpacity(0.06),
                            customBgColor?.withOpacity(0.2) ?? Colors.white.withOpacity(0.02),
                          ],
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

// =========================================================================
// BACKGROUND ANIMASI: FLUID LIQUID BLOBS
// =========================================================================
class LiquidBackground extends StatefulWidget {
  const LiquidBackground({super.key});

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLowVisionNotifier,
      builder: (context, isLowVision, _) {
        if (isLowVision) {
          // Background hitam pekat tanpa animasi di mode kontras tinggi
          return Container(color: Colors.black);
        }

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value;
            return Stack(
              children: [
                // Base Background
                Container(color: const Color(0xFF06070D)),
                // Blob Kiri Atas (Pink/Ungu)
                Positioned(
                  top: 50 + 90 * math.sin(progress * 2 * math.pi),
                  left: -60 + 80 * math.cos(progress * 2 * math.pi),
                  child: _buildBlob(200, const Color(0x1FFF1493)),
                ),
                // Blob Kanan Tengah (Oranye/Kuning)
                Positioned(
                  top: 300 + 100 * math.cos(progress * 2 * math.pi + 1),
                  right: -90 + 70 * math.sin(progress * 2 * math.pi + 1),
                  child: _buildBlob(260, const Color(0x1AFF5400)),
                ),
                // Blob Tengah Kiri (Biru/Cyan)
                Positioned(
                  bottom: 200 + 80 * math.sin(progress * 2 * math.pi - 1),
                  left: -40 + 90 * math.cos(progress * 2 * math.pi - 1),
                  child: _buildBlob(220, const Color(0x1F00E5FF)),
                ),
                // Blob Kanan Bawah (Ungu Tua)
                Positioned(
                  bottom: 50 + 70 * math.cos(progress * 2 * math.pi + 2),
                  right: 30 + 80 * math.sin(progress * 2 * math.pi + 2),
                  child: _buildBlob(190, const Color(0x1F8A2BE2)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: size * 0.8,
            spreadRadius: size * 0.2,
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// VECTOR NEON RADAR WIDGET (PENGGANTI PETAplaceholder)
// =========================================================================
class RadarMapWidget extends StatefulWidget {
  const RadarMapWidget({super.key});

  @override
  State<RadarMapWidget> createState() => _RadarMapWidgetState();
}

class _RadarMapWidgetState extends State<RadarMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLowVisionNotifier,
      builder: (context, isLowVision, _) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: RadarPainter(_controller.value, isLowVision),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.radar,
                      color: isLowVision ? const Color(0xFFFFFF00) : const Color(0xFF00FFCC),
                      size: isLowVision ? 44 : 36,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "NAV-RADAR",
                      style: TextStyle(
                        fontSize: isLowVision ? 12 : 9,
                        fontWeight: FontWeight.bold,
                        color: isLowVision ? const Color(0xFFFFFF00) : const Color(0xFF00FFCC),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class RadarPainter extends CustomPainter {
  final double sweepAngle;
  final bool isLowVision;

  RadarPainter(this.sweepAngle, this.isLowVision);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw background
    final bgPaint = Paint()..color = isLowVision ? Colors.black : const Color(0xFF0A0F1D).withOpacity(0.4);
    canvas.drawCircle(center, radius, bgPaint);

    final accentColor = isLowVision ? const Color(0xFFFFFF00) : const Color(0xFF00FFCC);

    final gridPaint = Paint()
      ..color = accentColor.withOpacity(isLowVision ? 0.6 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isLowVision ? 2.0 : 1.0;

    // Draw concentric circles
    canvas.drawCircle(center, radius, gridPaint);
    canvas.drawCircle(center, radius * 0.66, gridPaint);
    canvas.drawCircle(center, radius * 0.33, gridPaint);

    // Draw crosshairs
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), gridPaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), gridPaint);

    if (!isLowVision) {
      // Draw sweep gradient inside the radar scanner
      final sweepShader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: math.pi * 2,
        colors: const [
          Color(0x0000FFCC),
          Color(0x7700FFCC),
        ],
        transform: GradientRotation(sweepAngle * math.pi * 2 - math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      final sweepAreaPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = sweepShader;

      canvas.drawCircle(center, radius, sweepAreaPaint);
    } else {
      // Simple sweeping line for higher visibility in Low Vision mode
      final sweepLinePaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      final angle = sweepAngle * math.pi * 2 - math.pi / 2;
      final edge = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      canvas.drawLine(center, edge, sweepLinePaint);
    }

    // Draw blips (targets) representing obstacles
    final blipPaint = Paint()
      ..color = isLowVision ? const Color(0xFFFFFF00) : const Color(0xFFFF5400)
      ..style = PaintingStyle.fill;

    final blip1 = Offset(
      center.dx + radius * 0.55 * math.cos(1.2),
      center.dy + radius * 0.55 * math.sin(1.2),
    );
    canvas.drawCircle(blip1, isLowVision ? 7 : 4, blipPaint);

    final blip2 = Offset(
      center.dx + radius * 0.75 * math.cos(3.8),
      center.dy + radius * 0.75 * math.sin(3.8),
    );
    canvas.drawCircle(blip2, isLowVision ? 6 : 3, blipPaint);

    // Draw outer border
    final borderPaint = Paint()
      ..color = accentColor.withOpacity(isLowVision ? 1.0 : 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isLowVision ? 3.0 : 2.0;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle || oldDelegate.isLowVision != isLowVision;
  }
}

// =========================================================================
// VOICE COMMAND dialog: ANIMASI VISUALIZER GELOMBANG SUARA FLUIDA
// =========================================================================
class VoiceWaveVisualizer extends StatefulWidget {
  const VoiceWaveVisualizer({super.key});

  @override
  State<VoiceWaveVisualizer> createState() => _VoiceWaveVisualizerState();
}

class _VoiceWaveVisualizerState extends State<VoiceWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLowVisionNotifier,
      builder: (context, isLowVision, _) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(double.infinity, 90),
              painter: WavePainter(_controller.value, isLowVision),
            );
          },
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double value;
  final bool isLowVision;

  WavePainter(this.value, this.isLowVision);

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final width = size.width;

    if (isLowVision) {
      // 1 single thick high-contrast line for visually impaired users
      final paint = Paint()
        ..color = const Color(0xFFFFFF00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0;

      final path = Path();
      path.moveTo(0, midY);

      const amplitude = 35.0;
      const frequency = 0.035;
      final phase = value * 2 * math.pi;

      for (double x = 0; x <= width; x += 3) {
        final y = midY + amplitude * math.sin(x * frequency + phase);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    } else {
      // 3 overlapping beautiful colored translucent waves for liquid theme
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      for (int i = 0; i < 3; i++) {
        final path = Path();
        path.moveTo(0, midY);

        final color = i == 0
            ? const Color(0xFF00FFCC)
            : i == 1
                ? const Color(0xFFFF5400)
                : const Color(0xFFBF5AE2);
        paint.color = color.withOpacity(0.65 - i * 0.15);

        final amplitude = 30.0 - i * 7.0;
        final frequency = 0.02 + i * 0.007;
        final phase = value * 2 * math.pi * (i + 1.2) / 2;

        for (double x = 0; x <= width; x += 2) {
          final y = midY + amplitude * math.sin(x * frequency + phase);
          path.lineTo(x, y);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.isLowVision != isLowVision;
  }
}

// =========================================================================
// REAL-TIME DIGITAL CLOCK WIDGET
// =========================================================================
class RealTimeClockWidget extends StatefulWidget {
  const RealTimeClockWidget({super.key});

  @override
  State<RealTimeClockWidget> createState() => _RealTimeClockWidgetState();
}

class _RealTimeClockWidgetState extends State<RealTimeClockWidget> {
  Timer? _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (mounted) {
          setState(() {
            _now = DateTime.now();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hourStr = _now.hour.toString().padLeft(2, '0');
    final minuteStr = _now.minute.toString().padLeft(2, '0');
    return ValueListenableBuilder<bool>(
      valueListenable: isLowVisionNotifier,
      builder: (context, isLowVision, _) {
        return Text(
          "$hourStr:$minuteStr",
          style: TextStyle(
            fontSize: isLowVision ? 36.0 : 32.0,
            fontWeight: FontWeight.w900,
            color: isLowVision ? const Color(0xFFFFFF00) : Colors.white,
          ),
        );
      },
    );
  }
}

// =========================================================================
// MEKANISME AKSESIBILITAS: EXPLO RE-BY-TOUCH & RELEASE-TO-ACTIVATE
// =========================================================================
class AccessibleGestureDetector extends StatefulWidget {
  final Widget child;
  const AccessibleGestureDetector({super.key, required this.child});

  static AccessibleGestureDetectorState? of(BuildContext context) {
    return context.findAncestorStateOfType<AccessibleGestureDetectorState>();
  }

  @override
  AccessibleGestureDetectorState createState() =>
      AccessibleGestureDetectorState();
}

class AccessibleGestureDetectorState extends State<AccessibleGestureDetector> {
  final Map<String, RenderBoxHolder> _registry = {};
  String? _currentlyHoveredId;

  void register(
    String id,
    GlobalKey key,
    String speakText,
    VoidCallback onReleaseAction,
  ) {
    _registry[id] = RenderBoxHolder(
      key: key,
      speakText: speakText,
      onReleaseAction: onReleaseAction,
    );
  }

  void unregister(String id) {
    _registry.remove(id);
  }

  bool isHovered(String id) {
    return _currentlyHoveredId == id;
  }

  // Memicu feedback suara TTS visual dan haptic vibrasi
  void triggerFeedback(String text) {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);

    debugPrint("TTS AUDIO: $text");

    // Pastikan pemanggilan ScaffoldMessenger aman setelah siklus frame saat ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isLowVisionNotifier.value ? const Color(0xFFFFFF00) : Colors.white24,
              width: 2,
            ),
          ),
          content: ValueListenableBuilder<bool>(
            valueListenable: isLowVisionNotifier,
            builder: (context, isLowVision, _) {
              return Text(
                text,
                style: TextStyle(
                  fontSize: isLowVision ? 24.0 : 18.0,
                  fontWeight: FontWeight.w900,
                  color: isLowVision ? Colors.black : Colors.white,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          backgroundColor: isLowVisionNotifier.value ? const Color(0xFFFFFF00) : const Color(0xEE0B0E17),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  void _handlePointerDown(PointerDownEvent event) {
    _checkHover(event.position);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    _checkHover(event.position);
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_currentlyHoveredId != null) {
      final holder = _registry[_currentlyHoveredId];
      if (holder != null) {
        HapticFeedback.heavyImpact();
        triggerFeedback("Mengaktifkan ${holder.speakText}");
        holder.onReleaseAction();
      }
    }

    setState(() {
      _currentlyHoveredId = null;
    });
  }

  void _checkHover(Offset globalPosition) {
    String? matchedId;

    for (var entry in _registry.entries) {
      final key = entry.value.key;
      final context = key.currentContext;
      if (context == null) continue;
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) continue;
      
      final localPosition = renderBox.globalToLocal(globalPosition);
      final size = renderBox.size;

      if (localPosition.dx >= 0 &&
          localPosition.dx <= size.width &&
          localPosition.dy >= 0 &&
          localPosition.dy <= size.height) {
        matchedId = entry.key;
        break;
      }
    }

    if (matchedId != _currentlyHoveredId) {
      setState(() {
        _currentlyHoveredId = matchedId;
      });
      if (matchedId != null) {
        final holder = _registry[matchedId];
        if (holder != null) {
          triggerFeedback(holder.speakText);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}

class RenderBoxHolder {
  final GlobalKey key;
  final String speakText;
  final VoidCallback onReleaseAction;
  RenderBoxHolder({
    required this.key,
    required this.speakText,
    required this.onReleaseAction,
  });
}

class AccessibleButton extends StatefulWidget {
  final String id;
  final String speakText;
  final VoidCallback onRelease;
  final Widget Function(BuildContext context, bool isHovered) builder;

  const AccessibleButton({
    super.key,
    required this.id,
    required this.speakText,
    required this.onRelease,
    required this.builder,
  });

  @override
  State<AccessibleButton> createState() => _AccessibleButtonState();
}

class _AccessibleButtonState extends State<AccessibleButton> {
  final GlobalKey _key = GlobalKey();
  AccessibleGestureDetectorState? _detectorState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detectorState = AccessibleGestureDetector.of(context);
    _detectorState?.register(widget.id, _key, widget.speakText, widget.onRelease);
  }

  @override
  void dispose() {
    _detectorState?.unregister(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detector = AccessibleGestureDetector.of(context);
    final isHovered = detector?.isHovered(widget.id) ?? false;
    return KeyedSubtree(key: _key, child: widget.builder(context, isHovered));
  }
}

// =========================================================================
// TAMPILAN UTAMA (DASHBOARD SCREEN)
// =========================================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isVoiceAssistantOpen = false;
  bool _isQuickSettingsOpen = false;

  void _handleAction(BuildContext context, String title) {
    HapticFeedback.vibrate();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F121F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        title: const Text(
          "Aksi Berhasil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Memicu fungsi dari: $title",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tutup",
              style: TextStyle(color: Color(0xFFFF5400), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _speakTutorial() {
    AccessibleGestureDetector.of(context)?.triggerFeedback(
      "Selamat datang di Netravest. Gunakan satu jari Anda untuk meraba layar secara perlahan. Saat jari Anda berada di atas tombol, Anda akan mendengar penjelasan fungsinya. Lepaskan jari Anda untuk mengaktifkannya. Anda juga dapat menggunakan pintasan asisten suara dengan mengetuk tombol di kanan atas."
    );
  }

  Timer? _tutorialTimer;

  @override
  void initState() {
    super.initState();
    // Memutar panduan tutorial audio setelah tampilan dimuat pertama kali
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !Platform.environment.containsKey('FLUTTER_TEST')) {
        _tutorialTimer = Timer(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _speakTutorial();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tutorialTimer?.cancel();
    super.dispose();
  }

  String _getClockSpeakText() {
    final now = DateTime.now();
    final minuteStr = now.minute.toString().padLeft(2, '0');
    return "Jam saat ini menunjukkan pukul ${now.hour} lewat $minuteStr menit.";
  }

  @override
  Widget build(BuildContext context) {
    const double paddingVal = 14.0;

    return Scaffold(
      body: SafeArea(
        child: AccessibleGestureDetector(
          child: Stack(
            children: [
              // Background Animasi Liquid / Hitam Kontras Tinggi
              const LiquidBackground(),

              // Konten Utama Dashboard
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: paddingVal,
                  vertical: 10.0,
                ),
                child: Column(
                  children: [
                    // ---------------------------------------------------------
                    // KARTU LOKASI & PETA VECTOR (ATAS)
                    // ---------------------------------------------------------
                    AccessibleButton(
                      id: 'location_card_btn',
                      speakText: "Informasi lokasi Anda sekarang di Jalan Lorem Ipsum Nomor nol satu tiga, Kecamatan Dolor Sit Amet.",
                      onRelease: () {
                        AccessibleGestureDetector.of(context)?.triggerFeedback("Lokasi terverifikasi di Jalan Lorem Ipsum.");
                      },
                      builder: (context, isHovered) {
                        return GlassmorphicCard(
                          isHovered: isHovered,
                          borderRadius: 28.0,
                          glowColor: const Color(0xFFFF5400),
                          customBgColor: const Color(0xFFFF5400).withOpacity(0.12),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                // Teks Informasi Lokasi
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(20.0),
                                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                                    ),
                                    child: const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "LOKASI ANDA",
                                          style: TextStyle(
                                            fontSize: 11.0,
                                            color: Color(0xFFFF9E00),
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        SizedBox(height: 6.0),
                                        Expanded(
                                          child: Text(
                                            "Jln. Lorem Ipsum No 013, Kec. Dolor SitAmet",
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              height: 1.25,
                                            ),
                                            overflow: TextOverflow.fade,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                // Mini Radar Scanner (CustomPainter)
                                const Expanded(
                                  child: SizedBox(
                                    height: 120,
                                    child: RadarMapWidget(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12.0),

                    // ---------------------------------------------------------
                    // GRID UTAMA (SOS & PANEL KANAN)
                    // ---------------------------------------------------------
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // KOLOM KIRI: TOMBOL SOS & PANEL KONDISI ALAT
                          Expanded(
                            flex: 11,
                            child: Column(
                              children: [
                                // Tombol SOS (Merah Glowing)
                                Expanded(
                                  flex: 4,
                                  child: AccessibleButton(
                                    id: 'sos_btn',
                                    speakText: 'Tombol SOS darurat. Lepaskan sentuhan jari Anda untuk mengirim sinyal bantuan darurat segera.',
                                    onRelease: () => _handleAction(context, "PANGGILAN S O S"),
                                    builder: (context, isHovered) {
                                      return GlassmorphicCard(
                                        isHovered: isHovered,
                                        borderRadius: 36.0,
                                        glowColor: const Color(0xFFFF0D0D),
                                        customBgColor: const Color(0xFFFF0D0D).withOpacity(0.1),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.emergency,
                                                size: isHovered ? 80.0 : 72.0,
                                                color: const Color(0xFFFF3333),
                                              ),
                                              const SizedBox(height: 6.0),
                                              const Text(
                                                "SOS",
                                                style: TextStyle(
                                                  fontSize: 34.0,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12.0),
                                // Informasi Kondisi Alat
                                Expanded(
                                  flex: 5,
                                  child: GlassmorphicCard(
                                    isHovered: false,
                                    borderRadius: 28.0,
                                    glowColor: const Color(0xFF00FFCC),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Kondisi Alat",
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          // Status Baterai
                                          AccessibleButton(
                                            id: 'battery_status_btn',
                                            speakText: 'Status Baterai Alat saat ini adalah delapan puluh persen.',
                                            onRelease: () {},
                                            builder: (context, isHovered) {
                                              return AnimatedContainer(
                                                duration: const Duration(milliseconds: 150),
                                                padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                                                decoration: BoxDecoration(
                                                  color: isHovered ? Colors.white.withOpacity(0.08) : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  border: Border.all(
                                                    color: isHovered ? const Color(0xFF76FF03) : Colors.transparent,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: _buildStatusIndicator("Baterai", "80%", const Color(0xFF76FF03)),
                                              );
                                            },
                                          ),
                                          // Status Sensor
                                          AccessibleButton(
                                            id: 'sensor_status_btn',
                                            speakText: 'Status Sensor Navigasi, kondisi baik dan siap digunakan.',
                                            onRelease: () {},
                                            builder: (context, isHovered) {
                                              return AnimatedContainer(
                                                duration: const Duration(milliseconds: 150),
                                                padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                                                decoration: BoxDecoration(
                                                  color: isHovered ? Colors.white.withOpacity(0.08) : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  border: Border.all(
                                                    color: isHovered ? const Color(0xFF76FF03) : Colors.transparent,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: _buildStatusIndicatorWithIcon(
                                                  "Sensor",
                                                  "Baik",
                                                  const Color(0xFF76FF03),
                                                  Icons.check_circle_outline,
                                                ),
                                              );
                                            },
                                          ),
                                          // Status Kamera
                                          AccessibleButton(
                                            id: 'camera_status_btn',
                                            speakText: 'Status Kamera, kondisi rusak atau tidak terhubung.',
                                            onRelease: () {},
                                            builder: (context, isHovered) {
                                              return AnimatedContainer(
                                                duration: const Duration(milliseconds: 150),
                                                padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                                                decoration: BoxDecoration(
                                                  color: isHovered ? Colors.white.withOpacity(0.08) : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  border: Border.all(
                                                    color: isHovered ? const Color(0xFFFF1744) : Colors.transparent,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: _buildStatusIndicatorWithIcon(
                                                  "Kamera",
                                                  "Rusak",
                                                  const Color(0xFFFF1744),
                                                  Icons.cancel_outlined,
                                                ),
                                              );
                                            },
                                          ),
                                          // Tombol Kalibrasi
                                          AccessibleButton(
                                            id: 'calib_btn',
                                            speakText: 'Tombol Kalibrasi Alat. Lepaskan sentuhan jari untuk memulai kalibrasi sensor navigasi.',
                                            onRelease: () => _handleAction(context, "Kalibrasi Alat"),
                                            builder: (context, isHovered) {
                                              return GlassmorphicCard(
                                                isHovered: isHovered,
                                                borderRadius: 14.0,
                                                glowColor: const Color(0xFFFF5400),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                  alignment: Alignment.center,
                                                  child: const Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.sync, color: Colors.white, size: 14.0),
                                                      SizedBox(width: 4.0),
                                                      Text(
                                                        "Kalibrasi",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 12.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12.0),

                          // KOLOM KANAN: JAM, PENGATURAN KONTRAST, ALAT LAIN, CALL CENTER, BIG CALL
                          Expanded(
                            flex: 9,
                            child: Column(
                              children: [
                                // Box Jam Digital
                                AccessibleButton(
                                  id: 'clock_btn',
                                  speakText: _getClockSpeakText(),
                                  onRelease: () {},
                                  builder: (context, isHovered) {
                                    return GlassmorphicCard(
                                      isHovered: isHovered,
                                      borderRadius: 20.0,
                                      glowColor: const Color(0xFF8A2BE2),
                                      child: const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 6.0),
                                          child: RealTimeClockWidget(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 6.0),

                                // Baris Tombol Pengaturan & Periksa Perangkat
                                SizedBox(
                                  height: 50.0, // Reduced from 60.0 to 50.0
                                  child: Row(
                                    children: [
                                      // Tombol Buka Mode Aksesibilitas
                                      Expanded(
                                        flex: 2,
                                        child: AccessibleButton(
                                          id: 'quick_settings_btn',
                                          speakText: 'Tombol Pengaturan Aksesibilitas. Lepaskan sentuhan jari untuk membuka menu aksesibilitas dan kontras tinggi.',
                                          onRelease: () {
                                            setState(() {
                                              _isQuickSettingsOpen = true;
                                            });
                                          },
                                          builder: (context, isHovered) {
                                            return GlassmorphicCard(
                                              isHovered: isHovered,
                                              borderRadius: 14.0,
                                              glowColor: const Color(0xFF8A2BE2),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.accessibility_new,
                                                  color: Colors.white,
                                                  size: 24.0,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 6.0),
                                      // Tombol Cek Perangkat
                                      Expanded(
                                        flex: 3,
                                        child: AccessibleButton(
                                          id: 'check_device_btn',
                                          speakText: 'Tombol Periksa Perangkat Lain. Lepas jari Anda untuk memindai perangkat pendukung sekitar.',
                                          onRelease: () => _handleAction(context, "Periksa Perangkat Lain"),
                                          builder: (context, isHovered) {
                                            return GlassmorphicCard(
                                              isHovered: isHovered,
                                              borderRadius: 14.0,
                                              glowColor: const Color(0xFF00E5FF),
                                              child: const Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.layers, color: Colors.white, size: 18.0),
                                                  SizedBox(width: 4.0),
                                                  Text(
                                                    "Cek Alat",
                                                    style: TextStyle(
                                                      fontSize: 10.0,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6.0),

                                // Tombol Call Center (Glassmorphic)
                                AccessibleButton(
                                  id: 'call_center_btn',
                                  speakText: 'Tombol Panggilan Hubungi Call Center. Lepas jari Anda untuk menghubungi pusat layanan bantuan Netravest.',
                                  onRelease: () => _handleAction(context, "Panggilan Call Center"),
                                  builder: (context, isHovered) {
                                    return GlassmorphicCard(
                                      isHovered: isHovered,
                                      borderRadius: 20.0,
                                      glowColor: const Color(0xFF00FFCC),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0), // Reduced vertical padding from 8.0 to 6.0
                                        child: Row(
                                          children: [
                                            Icon(Icons.phone_in_talk, color: Colors.white, size: 18.0),
                                            SizedBox(width: 6.0),
                                            Expanded(
                                              child: Text(
                                                "Call Center",
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 6.0),

                                // Tombol Panggilan Utama (CALL) Besar
                                Expanded(
                                  child: AccessibleButton(
                                    id: 'big_call_btn',
                                    speakText: 'Tombol Panggilan Telepon Utama. Lepas jari Anda untuk melakukan panggilan suara ke pendamping utama Anda.',
                                    onRelease: () => _handleAction(context, "Panggilan Telepon Utama"),
                                    builder: (context, isHovered) {
                                      return GlassmorphicCard(
                                        isHovered: isHovered,
                                        borderRadius: 28.0,
                                        glowColor: const Color(0xFF00FF00),
                                        customBgColor: const Color(0xFF76FF03).withOpacity(0.08),
                                        child: Center(
                                          child: SingleChildScrollView( // Added scroll view to ensure Column never overflows internally!
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.phone,
                                                  size: isHovered ? 48.0 : 42.0, // Reduced icon sizes slightly
                                                  color: const Color(0xFF00FF00),
                                                ),
                                                const SizedBox(height: 4.0),
                                                const Text(
                                                  "CALL",
                                                  style: TextStyle(
                                                    fontSize: 20.0, // Reduced font size slightly
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // ---------------------------------------------------------
                    // BARIS BAWAH: SETTINGS, AKUN PENGGUNA & ASISTEN SUARA
                    // ---------------------------------------------------------
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isLowVisionNotifier.value ? Colors.transparent : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(28.0),
                        border: Border.all(
                          color: isLowVisionNotifier.value
                              ? const Color(0xFFFFFF00)
                              : Colors.white.withOpacity(0.08),
                          width: isLowVisionNotifier.value ? 4.0 : 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Tombol Pengaturan Bawah
                          AccessibleButton(
                            id: 'bottom_settings_btn',
                            speakText: 'Tombol Pengaturan Aplikasi. Lepaskan sentuhan jari untuk masuk ke menu setelan utama.',
                            onRelease: () => _handleAction(context, "Pengaturan Utama"),
                            builder: (context, isHovered) {
                              return GlassmorphicCard(
                                isHovered: isHovered,
                                borderRadius: 100.0,
                                glowColor: Colors.white,
                                child: const SizedBox(
                                  width: 60.0,
                                  height: 60.0,
                                  child: Icon(Icons.settings_outlined, color: Colors.white, size: 32.0),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8.0),

                          // Tombol Asisten Suara (Tengah - Microfon)
                          Expanded(
                            flex: 2,
                            child: AccessibleButton(
                              id: 'voice_assistant_btn',
                              speakText: 'Tombol Asisten Suara Netravest. Lepas jari Anda untuk membuka asisten bantuan berbasis perintah suara.',
                              onRelease: () {
                                setState(() {
                                  _isVoiceAssistantOpen = true;
                                });
                              },
                              builder: (context, isHovered) {
                                return GlassmorphicCard(
                                  isHovered: isHovered,
                                  borderRadius: 30.0,
                                  glowColor: const Color(0xFF00FFCC),
                                  customBgColor: const Color(0xFF00FFCC).withOpacity(0.08),
                                  child: SizedBox(
                                    height: 60.0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.mic,
                                          color: isHovered ? const Color(0xFF00FFCC) : Colors.white,
                                          size: 28.0,
                                        ),
                                        const SizedBox(width: 6.0),
                                        const Text(
                                          "ASISTEN SUARA",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8.0),

                          // Tombol Akun Pengguna
                          Expanded(
                            flex: 2,
                            child: AccessibleButton(
                              id: 'user_account_btn',
                              speakText: 'Tombol Profil Pengguna. Lepaskan jari Anda untuk melihat detail akun terdaftar.',
                              onRelease: () => _handleAction(context, "Akun Pengguna"),
                              builder: (context, isHovered) {
                                return GlassmorphicCard(
                                  isHovered: isHovered,
                                  borderRadius: 30.0,
                                  glowColor: Colors.white,
                                  child: const SizedBox(
                                    height: 60.0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person_outline, color: Colors.white, size: 28.0),
                                        SizedBox(width: 6.0),
                                        Text(
                                          "AKUN",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Overlay Dialog Asisten Suara
              if (_isVoiceAssistantOpen)
                Positioned.fill(
                  child: _buildVoiceAssistantOverlay(context),
                ),

              // Overlay Dialog Pengaturan Aksesibilitas
              if (_isQuickSettingsOpen)
                Positioned.fill(
                  child: _buildQuickSettingsOverlay(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // VOICE ASSISTANT INTERACTION OVERLAY
  // =========================================================================
  Widget _buildVoiceAssistantOverlay(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          color: Colors.black.withOpacity(0.88),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mic, color: Color(0xFF00FFCC), size: 64),
              const SizedBox(height: 12),
              const Text(
                "Asisten Suara Netravest",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                "Raba dan lepas pada salah satu pilihan simulasi perintah suara di bawah ini:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white60),
              ),
              const SizedBox(height: 20),
              // Gelombang Suara Teranimasi
              const VoiceWaveVisualizer(),
              const SizedBox(height: 20),
              // Grid Perintah Cepat
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.1,
                  children: [
                    _buildSimulatedVoiceCommandButton(
                      context,
                      id: 'voice_cmd_sos',
                      label: "🚨 Darurat SOS",
                      speakText: "Katakan SOS untuk mengirim sinyal darurat.",
                      command: "SOS",
                      actionText: "Mengaktifkan pemicu SOS darurat. Menghubungi kontak darurat dan mengirim lokasi Anda sekarang.",
                    ),
                    _buildSimulatedVoiceCommandButton(
                      context,
                      id: 'voice_cmd_battery',
                      label: "🔋 Cek Baterai",
                      speakText: "Tanyakan kondisi baterai alat.",
                      command: "Baterai",
                      actionText: "Status daya baterai alat tersisa delapan puluh persen.",
                    ),
                    _buildSimulatedVoiceCommandButton(
                      context,
                      id: 'voice_cmd_sensor',
                      label: "📡 Cek Sensor",
                      speakText: "Tanyakan kondisi sensor navigasi.",
                      command: "Sensor",
                      actionText: "Sensor ultrasonik dan inframerah dalam kondisi baik.",
                    ),
                    _buildSimulatedVoiceCommandButton(
                      context,
                      id: 'voice_cmd_camera',
                      label: "📷 Cek Kamera",
                      speakText: "Tanyakan kondisi kamera detektor.",
                      command: "Kamera",
                      actionText: "Peringatan! Kamera navigasi terdeteksi mengalami kegagalan sistem.",
                    ),
                    _buildSimulatedVoiceCommandButton(
                      context,
                      id: 'voice_cmd_calibrate',
                      label: "⚙️ Kalibrasi",
                      speakText: "Jalankan perintah kalibrasi alat.",
                      command: "Kalibrasi",
                      actionText: "Melakukan sinkronisasi dan kalibrasi alat... Kalibrasi sukses.",
                    ),
                    _buildSimulatedVoiceCommandButton(
                      context,
                      id: 'voice_cmd_location',
                      label: "📍 Cek Lokasi",
                      speakText: "Tanyakan alamat Anda saat ini.",
                      command: "Lokasi",
                      actionText: "Anda sedang berada di Jalan Lorem Ipsum Nomor nol satu tiga.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Tombol Kembali
              AccessibleButton(
                id: 'voice_close_btn',
                speakText: "Tombol Tutup Asisten Suara. Lepas jari untuk kembali ke Dashboard utama.",
                onRelease: () {
                  setState(() {
                    _isVoiceAssistantOpen = false;
                  });
                },
                builder: (context, isHovered) {
                  return GlassmorphicCard(
                    isHovered: isHovered,
                    glowColor: Colors.white,
                    borderRadius: 18.0,
                    customBgColor: Colors.white.withOpacity(0.12),
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      child: const Text(
                        "Kembali ke Menu Utama",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimulatedVoiceCommandButton(
    BuildContext context, {
    required String id,
    required String label,
    required String speakText,
    required String command,
    required String actionText,
  }) {
    return AccessibleButton(
      id: id,
      speakText: speakText,
      onRelease: () {
        final detector = AccessibleGestureDetector.of(context);
        detector?.triggerFeedback("Mengucapkan: $command");
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (mounted && _isVoiceAssistantOpen) {
            detector?.triggerFeedback(actionText);
          }
        });
      },
      builder: (context, isHovered) {
        return GlassmorphicCard(
          isHovered: isHovered,
          glowColor: const Color(0xFF00FFCC),
          borderRadius: 16.0,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // QUICK ACCESSIBILITY SETTINGS OVERLAY
  // =========================================================================
  Widget _buildQuickSettingsOverlay(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          color: Colors.black.withOpacity(0.88),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.accessibility_new, color: Color(0xFF8A2BE2), size: 64),
              const SizedBox(height: 12),
              const Text(
                "Pengaturan Aksesibilitas",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 24),

              // Button 1: Toggle Low Vision (Kontras Tinggi)
              ValueListenableBuilder<bool>(
                valueListenable: isLowVisionNotifier,
                builder: (context, isLowVision, _) {
                  return AccessibleButton(
                    id: 'toggle_low_vision_btn',
                    speakText: isLowVision
                        ? "Matikan Mode Kontras Tinggi. Lepas untuk kembali ke tampilan normal."
                        : "Aktifkan Mode Kontras Tinggi. Lepas untuk memperbesar tulisan dan mengubah warna menjadi hitam dan kuning kontras tinggi.",
                    onRelease: () {
                      isLowVisionNotifier.value = !isLowVision;
                      AccessibleGestureDetector.of(context)?.triggerFeedback(
                        isLowVisionNotifier.value
                            ? "Mode Kontras Tinggi diaktifkan. Tulisan diperbesar."
                            : "Mode Kontras Tinggi dimatikan.",
                      );
                    },
                    builder: (context, isHovered) {
                      return GlassmorphicCard(
                        isHovered: isHovered,
                        glowColor: const Color(0xFF8A2BE2),
                        borderRadius: 16.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.visibility, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text(
                                    "Mode Low-Vision",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                  ),
                                ],
                              ),
                              Switch(
                                value: isLowVision,
                                activeColor: const Color(0xFF8A2BE2),
                                onChanged: (val) {
                                  isLowVisionNotifier.value = val;
                                  AccessibleGestureDetector.of(context)?.triggerFeedback(
                                    val ? "Mode Kontras Tinggi diaktifkan." : "Mode Kontras Tinggi dimatikan."
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Button 2: Putar Ulang Panduan Suara
              AccessibleButton(
                id: 'repeat_guide_btn',
                speakText: "Tombol Putar Ulang Panduan Suara. Lepas untuk mendengarkan tutorial cara penggunaan aplikasi.",
                onRelease: () {
                  _speakTutorial();
                },
                builder: (context, isHovered) {
                  return GlassmorphicCard(
                    isHovered: isHovered,
                    glowColor: const Color(0xFF8A2BE2),
                    borderRadius: 16.0,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.volume_up, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            "Putar Ulang Panduan Suara",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Tombol Kembali
              AccessibleButton(
                id: 'settings_close_btn',
                speakText: "Tombol Tutup Pengaturan. Lepas untuk kembali ke Dashboard utama.",
                onRelease: () {
                  setState(() {
                    _isQuickSettingsOpen = false;
                  });
                },
                builder: (context, isHovered) {
                  return GlassmorphicCard(
                    isHovered: isHovered,
                    glowColor: Colors.white,
                    borderRadius: 18.0,
                    customBgColor: Colors.white.withOpacity(0.12),
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      child: const Text(
                        "Kembali ke Menu Utama",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // METODE HELPER UNTUK TAMPILAN STATUS DETAIL
  // =========================================================================
  Widget _buildStatusIndicator(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10.0, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Container(
            height: 14.0,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Stack(
              children: [
                // Battery Level Fill
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Container(
                    height: 14.0,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicatorWithIcon(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10.0, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(width: 4.0),
            Icon(icon, color: color, size: 14.0),
          ],
        ),
      ],
    );
  }
}
