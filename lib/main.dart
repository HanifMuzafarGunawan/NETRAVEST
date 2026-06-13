import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Kunci orientasi ke Portrait karena desain ini khusus mobile portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aksesibilitas Tunanetra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(
          0xFF000000,
        ), // Background layar hitam pekat
        fontFamily: 'Roboto', // Font bersih dan mudah dibaca
      ),
      home: const DashboardScreen(),
    );
  }
}

// =========================================================================
// MEKANISME AKSESIBILITAS: RELEASE-TO-ACTIVATE (EXPLO RE-BY-TOUCH)
// =========================================================================
/// Widget utama yang menangkap semua gerakan sentuhan di layar secara global.
/// Widget ini mendeteksi koordinat jari dan mencocokkannya dengan tombol-tombol yang terdaftar.
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
  // Menyimpan data koordinat tombol yang terdaftar di layar
  final Map<String, RenderBoxHolder> _registry = {};

  // ID Tombol yang saat ini sedang di-hover oleh jari pengguna
  String? _currentlyHoveredId;
  // Mendaftarkan tombol ke dalam sistem deteksi sentuh
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

  // Menghapus tombol dari sistem deteksi saat widget dihapus
  void unregister(String id) {
    _registry.remove(id);
  }

  // Mengecek apakah tombol dengan ID tertentu sedang di-hover
  bool isHovered(String id) {
    return _currentlyHoveredId == id;
  }

  // Simulasi Text-To-Speech (TTS) dan Haptic Feedback
  void _triggerFeedback(String text) {
    // 1. Getaran halus (Haptic) saat jari berpindah ke tombol baru
    HapticFeedback.lightImpact();

    // 2. Simulasi suara (TTS)
    // Di aplikasi produksi, gunakan package 'flutter_tts' dengan: flutterTts.speak(text);
    debugPrint("TTS AUDIO: $text");

    // Tampilkan SnackBar di layar untuk menunjukkan suara yang sedang diucapkan
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(
          0xFFFFFF00,
        ), // Kuning kontras tinggi untuk low-vision
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Melacak posisi sentuhan saat jari pertama kali menyentuh layar
  void _handlePointerDown(PointerDownEvent event) {
    _checkHover(event.position);
  }

  // Melacak pergerakan jari secara real-time
  void _handlePointerMove(PointerMoveEvent event) {
    _checkHover(event.position);
  }

  // Mendeteksi saat jari dilepas (Release/Lift) untuk memicu aksi
  void _handlePointerUp(PointerUpEvent event) {
    if (_currentlyHoveredId != null) {
      final holder = _registry[_currentlyHoveredId];
      if (holder != null) {
        // Getaran kuat sebagai konfirmasi aktivasi
        HapticFeedback.heavyImpact();

        // Ucapkan konfirmasi aktivasi
        _triggerFeedback("Mengaktifkan ${holder.speakText}");

        // Jalankan aksi tombol
        holder.onReleaseAction();
      }
    }

    setState(() {
      _currentlyHoveredId = null;
    });
  }

  // Memeriksa koordinat jari terhadap koordinat (bounding box) setiap tombol
  void _checkHover(Offset globalPosition) {
    String? matchedId;

    for (var entry in _registry.entries) {
      final key = entry.value.key;
      final context = key.currentContext;
      if (context == null) continue;
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) continue;
      // Konversi koordinat global jari ke koordinat lokal di dalam area tombol
      final localPosition = renderBox.globalToLocal(globalPosition);
      final size = renderBox.size;

      // Jika koordinat jari berada di dalam batas (width & height) tombol
      if (localPosition.dx >= 0 &&
          localPosition.dx <= size.width &&
          localPosition.dy >= 0 &&
          localPosition.dy <= size.height) {
        matchedId = entry.key;
        break; // Ditemukan tombol yang di-hover, keluar dari loop
      }
    }
    // Jika jari berpindah ke tombol baru
    if (matchedId != _currentlyHoveredId) {
      setState(() {
        _currentlyHoveredId = matchedId;
      });
      if (matchedId != null) {
        final holder = _registry[matchedId];
        if (holder != null) {
          _triggerFeedback(holder.speakText);
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

// Model data penyimpan referensi koordinat tombol
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

/// Widget pembungkus untuk tombol-tombol agar terdaftar di detektor sentuh global.
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
  _AccessibleButtonState createState() => _AccessibleButtonState();
}

class _AccessibleButtonState extends State<AccessibleButton> {
  final GlobalKey _key = GlobalKey();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Daftarkan tombol saat widget dibuat
    AccessibleGestureDetector.of(
      context,
    )?.register(widget.id, _key, widget.speakText, widget.onRelease);
  }

  @override
  void dispose() {
    // Hapus pendaftaran saat widget dibuang
    AccessibleGestureDetector.of(context)?.unregister(widget.id);
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
// TAMPILAN DASHBOARD (MENIRU EXACTLY SCREENSHOT USER)
// =========================================================================
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  // Aksi yang dipicu saat tombol dilepas
  void _handleAction(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Aksi Berhasil",
          style: TextStyle(color: Colors.white),
        ),
        content: Text("Memicu fungsi dari: $title"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tutup",
              style: TextStyle(color: Color(0xFFFF5400)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double paddingVal = 12.0;
    return Scaffold(
      body: SafeArea(
        child: AccessibleGestureDetector(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: paddingVal,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                // ---------------------------------------------------------
                // KARTU LOKASI & PETA (ATAS)
                // ---------------------------------------------------------
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5400), // Warna orange kontras
                    borderRadius: BorderRadius.circular(28.0),
                  ),
                  child: Row(
                    children: [
                      // Informasi Lokasi
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Lokasi Anda",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Expanded(
                                child: Text(
                                  "Jln. Lorem Ipsum No 013, Kec. Dolor SitAmet",
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      // Peta Mini
                      Expanded(
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400', // Gambar peta placeholder berkualitas tinggi
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: const [
                              Center(
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                // ---------------------------------------------------------
                // GRID UTAMA (SOS & PANEL KANAN)
                // ---------------------------------------------------------
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // KOLOM KIRI: SOS & KONDISI ALAT
                      Expanded(
                        flex: 11,
                        child: Column(
                          children: [
                            // Tombol SOS
                            Expanded(
                              flex: 4,
                              child: AccessibleButton(
                                id: 'sos_btn',
                                speakText:
                                    'Tombol S O S, lepas untuk mengirim bantuan darurat!',
                                onRelease: () =>
                                    _handleAction(context, "PANGGILAN S O S"),
                                builder: (context, isHovered) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    decoration: BoxDecoration(
                                      color: isHovered
                                          ? const Color(
                                              0xFFFF5252,
                                            ) // Warna saat disentuh
                                          : const Color(
                                              0xFFFF0D0D,
                                            ), // Warna merah menyala
                                      borderRadius: BorderRadius.circular(36.0),
                                      border: Border.all(
                                        color: isHovered
                                            ? Colors.white
                                            : Colors.transparent,
                                        width: 4.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons
                                                .emergency, // Menggantikan tanda bintang/SOS
                                            size: 72.0,
                                            color: Colors.black,
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            "sos",
                                            style: TextStyle(
                                              fontSize: 32.0,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black,
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
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D0D0D),
                                  borderRadius: BorderRadius.circular(28.0),
                                  border: Border.all(
                                    color: Colors.grey.shade900,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Kondisi Alat",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    // Status Baterai
                                    _buildStatusIndicator(
                                      "Baterai",
                                      "80%",
                                      const Color(0xFF76FF03),
                                    ),
                                    // Status Sensor
                                    _buildStatusIndicatorWithIcon(
                                      "Sensor",
                                      "Baik",
                                      const Color(0xFF76FF03),
                                      Icons.check_circle_outline,
                                    ),
                                    // Status Kamera
                                    _buildStatusIndicatorWithIcon(
                                      "Kamera",
                                      "Rusak",
                                      const Color(0xFFFF1744),
                                      Icons.cancel_outlined,
                                    ),
                                    // Tombol Kalibrasi
                                    AccessibleButton(
                                      id: 'calib_btn',
                                      speakText:
                                          'Tombol Kalibrasi Alat, lepas untuk memulai kalibrasi.',
                                      onRelease: () => _handleAction(
                                        context,
                                        "Kalibrasi Alat",
                                      ),
                                      builder: (context, isHovered) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isHovered
                                                ? const Color(0xFFFF7D40)
                                                : const Color(0xFFFF5400),
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.sync,
                                                color: Colors.white,
                                                size: 18.0,
                                              ),
                                              SizedBox(width: 6.0),
                                              Text(
                                                "Kalibrasi",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12.0),

                      // KOLOM KANAN: JAM, PENGATURAN, CALL CENTER, TOMBOL CALL
                      Expanded(
                        flex: 9,
                        child: Column(
                          children: [
                            // Baris Jam
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D0D0D),
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: const Center(
                                child: Text(
                                  "19:20",
                                  style: TextStyle(
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            // Baris Tombol Pengaturan Cepat & Periksa Perangkat
                            Row(
                              children: [
                                // Tombol Pengaturan Cepat (Orange)
                                Expanded(
                                  flex: 2,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: AccessibleButton(
                                      id: 'quick_settings_btn',
                                      speakText: 'Tombol Pengaturan Cepat.',
                                      onRelease: () => _handleAction(
                                        context,
                                        "Pengaturan Cepat",
                                      ),
                                      builder: (context, isHovered) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: isHovered
                                                ? const Color(0xFFFF7D40)
                                                : const Color(0xFFFF5400),
                                            borderRadius: BorderRadius.circular(
                                              18.0,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.settings,
                                            color: Colors.white,
                                            size: 28.0,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                // Tombol Periksa Perangkat Lain (Hitam)
                                Expanded(
                                  flex: 3,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: AccessibleButton(
                                      id: 'check_device_btn',
                                      speakText:
                                          'Tombol Periksa Perangkat Lain.',
                                      onRelease: () => _handleAction(
                                        context,
                                        "Periksa Perangkat Lain",
                                      ),
                                      builder: (context, isHovered) {
                                        return Container(
                                          padding: const EdgeInsets.all(6.0),
                                          decoration: BoxDecoration(
                                            color: isHovered
                                                ? Colors.grey.shade800
                                                : const Color(0xFF0D0D0D),
                                            borderRadius: BorderRadius.circular(
                                              18.0,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.layers,
                                                color: Colors.white,
                                                size: 28.0,
                                              ),
                                              SizedBox(height: 4.0),
                                              Text(
                                                "Periksa\nPerangkat Lain",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 9.0,
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            // Tombol Call Center
                            AccessibleButton(
                              id: 'call_center_btn',
                              speakText:
                                  'Tombol Call Center, lepas untuk melakukan panggilan ke pusat bantuan.',
                              onRelease: () => _handleAction(
                                context,
                                "Panggilan Call Center",
                              ),
                              builder: (context, isHovered) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 16.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isHovered
                                        ? Colors.grey.shade800
                                        : const Color(0xFF0D0D0D),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.phone_in_talk,
                                        color: Colors.white,
                                        size: 24.0,
                                      ),
                                      SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          "Call Center",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8.0),
                            // Tombol CALL (Besar Orange)
                            Expanded(
                              child: AccessibleButton(
                                id: 'big_call_btn',
                                speakText:
                                    'Tombol Panggilan Utama, lepas untuk melakukan panggilan keluar.',
                                onRelease: () => _handleAction(
                                  context,
                                  "Panggilan Telepon Utama",
                                ),
                                builder: (context, isHovered) {
                                  return Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: isHovered
                                          ? const Color(0xFFFF7D40)
                                          : const Color(0xFFFF5400),
                                      borderRadius: BorderRadius.circular(32.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.phone,
                                          size: 54.0,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          "CALL",
                                          style: TextStyle(
                                            fontSize: 22.0,
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
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                // ---------------------------------------------------------
                // BARIS BAWAH: SETTINGS & AKUN PENGGUNA
                // ---------------------------------------------------------
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5400),
                    borderRadius: BorderRadius.circular(28.0),
                  ),
                  child: Row(
                    children: [
                      // Tombol Pengaturan Bawah (Bulat Putih)
                      AccessibleButton(
                        id: 'bottom_settings_btn',
                        speakText: 'Tombol Pengaturan Aplikasi.',
                        onRelease: () =>
                            _handleAction(context, "Pengaturan Utama"),
                        builder: (context, isHovered) {
                          return Container(
                            width: 68.0,
                            height: 68.0,
                            decoration: BoxDecoration(
                              color: isHovered
                                  ? Colors.grey.shade200
                                  : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.settings_outlined,
                              color: Colors.black,
                              size: 36.0,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8.0),
                      // Tombol Akun Pengguna (Pill Putih)
                      Expanded(
                        child: AccessibleButton(
                          id: 'user_account_btn',
                          speakText: 'Tombol Akun Pengguna.',
                          onRelease: () =>
                              _handleAction(context, "Akun Pengguna"),
                          builder: (context, isHovered) {
                            return Container(
                              height: 68.0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              decoration: BoxDecoration(
                                color: isHovered
                                    ? Colors.grey.shade200
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(34.0),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.person_outline,
                                    color: Colors.black,
                                    size: 36.0,
                                  ),
                                  SizedBox(width: 12.0),
                                  Text(
                                    "Akun\nPengguna",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // HELPER METODE UNTUK UI KONDISI ALAT
  // =========================================================================
  Widget _buildStatusIndicator(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10.0, color: Colors.white70),
        ),
        const SizedBox(height: 2.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Stack(
            children: [
              // Bar Progress
              FractionallySizedBox(
                widthFactor: 0.8, // 80% baterai
                child: Container(
                  height: 18.0,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
              // Teks Persentase
              Center(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10.0, color: Colors.white70),
        ),
        const SizedBox(height: 2.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Icon(icon, color: Colors.black, size: 16.0),
            ],
          ),
        ),
      ],
    );
  }
}
