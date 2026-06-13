import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const BentoDragReleaseDashboard(),
    );
  }
}

class BentoDragReleaseDashboard extends StatefulWidget {
  const BentoDragReleaseDashboard({super.key});

  @override
  State<BentoDragReleaseDashboard> createState() =>
      _BentoDragReleaseDashboardState();
}

class _BentoDragReleaseDashboardState extends State<BentoDragReleaseDashboard> {
  // Menyimpan GlobalKey untuk melacak posisi koordinat masing-masing tombol
  final GlobalKey _sosKey = GlobalKey();
  final GlobalKey _callKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();

  // Menyimpan status nama tombol yang sedang disentuh jari saat ini
  String _currentlyHoveredButton = "";

  // Fungsi untuk memeriksa apakah koordinat jari berada di dalam area suatu komponen/tombol
  bool _isPointerInsideWidget(Offset globalPosition, GlobalKey key) {
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;

    // Mendapatkan posisi absolut tombol di layar
    final Offset boxPosition = renderBox.localToGlobal(Offset.zero);
    // Mendapatkan ukuran lebar dan tinggi tombol
    final Size boxSize = renderBox.size;

    // Memeriksa apakah koordinat X dan Y jari berada di dalam batas kotak tombol
    return globalPosition.dx >= boxPosition.dx &&
        globalPosition.dx <= boxPosition.dx + boxSize.width &&
        globalPosition.dy >= boxPosition.dy &&
        globalPosition.dy <= boxPosition.dy + boxSize.height;
  }

  // Fungsi yang dijalankan secara real-time saat jari bergeser di layar
  void _checkIntersections(Offset globalPosition) {
    String detectedButton = "";

    if (_isPointerInsideWidget(globalPosition, _sosKey)) {
      detectedButton = "SOS";
    } else if (_isPointerInsideWidget(globalPosition, _callKey)) {
      detectedButton = "CALL";
    } else if (_isPointerInsideWidget(globalPosition, _settingsKey)) {
      detectedButton = "PENGATURAN";
    }

    // Jika jari berpindah ke tombol baru, picu getaran ringan
    if (detectedButton != _currentlyHoveredButton) {
      setState(() {
        _currentlyHoveredButton = detectedButton;
      });

      if (_currentlyHoveredButton.isNotEmpty) {
        // Getaran ketukan tipis penanda jari masuk ke area tombol baru
        HapticFeedback.lightImpact();
        print("Jari melewati tombol: $_currentlyHoveredButton");
      }
    }
  }

  // Fungsi yang dijalankan saat jari resmi diangkat/dilepas dari layar
  void _executeSelectedAction() {
    if (_currentlyHoveredButton.isEmpty) return;

    // Picu getaran tegas penanda aksi berhasil dieksekusi
    HapticFeedback.heavyImpact();

    // Jalankan logika sesuai tombol terakhir yang dipilih
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aksi $_currentlyHoveredButton Berhasil Diaktifkan!'),
        duration: const Duration(seconds: 1),
      ),
    );

    // Reset status setelah tombol dieksekusi
    setState(() {
      _currentlyHoveredButton = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        // GestureDetector utama untuk mendeteksi seluruh pergerakan jari di layar
        child: GestureDetector(
          onPanStart: (details) => _checkIntersections(details.globalPosition),
          onPanUpdate: (details) => _checkIntersections(details.globalPosition),
          onPanEnd: (_) => _executeSelectedAction(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Indikator teks status di bagian atas layar untuk mempermudah debugging kamu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: const Color.fromARGB(255, 255, 255, 255),
                  child: Text(
                    _currentlyHoveredButton.isEmpty
                        ? "Jelajahi layar: Tempel & geser jarimu di sini"
                        : "Jari berada di: $_currentlyHoveredButton (Lepas untuk memilih)",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Area Grid Tombol Dashboard
                Expanded(
                  child: Row(
                    children: [
                      // Tombol Kiri: SOS
                      Expanded(
                        child: Container(
                          key: _sosKey, // Pasang kunci pelacak koordinat
                          decoration: BoxDecoration(
                            color: _currentlyHoveredButton == "SOS"
                                ? const Color.fromARGB(255, 255, 0, 0)
                                : Colors.red,
                            borderRadius: BorderRadius.circular(32),
                            border: _currentlyHoveredButton == "SOS"
                                ? Border.all(color: Colors.white, width: 4)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.emergency,
                                color: Colors.black,
                                size: 64,
                              ),
                              Text(
                                'SOS',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Tombol Kanan: Gabungan Atas (Settings) & Bawah (Call)
                      Expanded(
                        child: Column(
                          children: [
                            // Tombol Kecil Pengaturan
                            Expanded(
                              flex: 4,
                              child: Container(
                                key:
                                    _settingsKey, // Pasang kunci pelacak koordinat
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: _currentlyHoveredButton == "PENGATURAN"
                                      ? const Color.fromARGB(255, 234, 140, 0)
                                      : Colors.orange,
                                  borderRadius: BorderRadius.circular(24),
                                  border:
                                      _currentlyHoveredButton == "PENGATURAN"
                                      ? Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        )
                                      : null,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Tombol Besar CALL
                            Expanded(
                              flex: 6,
                              child: Container(
                                key: _callKey, // Pasang kunci pelacak koordinat
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: _currentlyHoveredButton == "CALL"
                                      ? const Color.fromARGB(255, 234, 140, 0)
                                      : Colors.orange,
                                  borderRadius: BorderRadius.circular(32),
                                  border: _currentlyHoveredButton == "CALL"
                                      ? Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        )
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'CALL',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
}
