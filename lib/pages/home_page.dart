import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show pi, cos, sin;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Arah Kiblat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _deviceSupport,
        builder: (context, AsyncSnapshot<bool?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.data == true) {
            return FutureBuilder(
              future: _checkLocationPermission(),
              builder: (context, AsyncSnapshot<bool> permissionSnapshot) {
                if (permissionSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (permissionSnapshot.data == true) {
                  return const QiblahCompassWidget();
                } else {
                  return _buildPermissionRequest();
                }
              },
            );
          } else {
            return _buildDeviceNotSupported();
          }
        },
      ),
    );
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'Izin Lokasi Diperlukan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Aplikasi memerlukan akses lokasi untuk menentukan arah kiblat yang akurat.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await Geolocator.requestPermission();
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Berikan Izin'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceNotSupported() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'Perangkat Tidak Didukung',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Maaf, perangkat Anda tidak mendukung sensor kompas yang diperlukan.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

  class QiblahCompassWidget extends StatefulWidget {
  const QiblahCompassWidget({super.key});

  @override
  State<QiblahCompassWidget> createState() => _QiblahCompassWidgetState();
}

class _QiblahCompassWidgetState extends State<QiblahCompassWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Text('Menunggu data sensor...'),
          );
        }
        final qiblahDirection = snapshot.data!;
        final direction = qiblahDirection.direction; // Arah HP sekarang
        var qiblah = qiblahDirection.qiblah; // Arah kiblat sebenarnya (raw)

        // NORMALISASI qiblah ke rentang 0–360
        while (qiblah < 0) qiblah += 360;
        while (qiblah >= 360) qiblah -= 360;

        // NORMALISASI direction ke rentang 0–360
        var normalizedDirection = direction;
        while (normalizedDirection < 0) normalizedDirection += 360;
        while (normalizedDirection >= 360) normalizedDirection -= 360;

        // CEK apakah HP menghadap kiblat (rentang 290° - 300°)
        bool isFacingQiblah = (normalizedDirection >= 290 && normalizedDirection <= 300);

        // Hitung selisih untuk tampilan saja
        final offset = qiblahDirection.offset;
        final absOffset = offset.abs();

        // Debug: Print semua nilai
        print('=== QIBLAH DEBUG ===');
        print('Direction (HP): ${direction.toStringAsFixed(2)}°');
        print('Direction (Normalized): ${normalizedDirection.toStringAsFixed(2)}°');
        print('Qiblah (RAW): ${qiblahDirection.qiblah.toStringAsFixed(2)}°');
        print('Qiblah (NORMALIZED): ${qiblah.toStringAsFixed(2)}°');
        print('Calculated Offset: ${absOffset.toStringAsFixed(2)}°');
        print('Is Facing Qiblah: $isFacingQiblah');
        print('====================');

        return SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isFacingQiblah
                          ? Colors.green[700]
                          : Colors.orange[700],
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: (isFacingQiblah
                                  ? Colors.green[700]!
                                  : Colors.orange[700]!)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFacingQiblah ? Icons.check_circle : Icons.explore,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isFacingQiblah
                              ? 'Menghadap Kiblat'
                              : 'Cari Arah Kiblat',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Kompas
                  Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Kompas background (lingkaran dan garis) - BERPUTAR sesuai direction
                        Transform.rotate(
                          angle: (direction * (pi / 180) * -1),
                          child: const CompassRose(),
                        ),
                        // Panah KIBLAT (merah/hijau) - TETAP DI ATAS (tidak ikut rotasi direction)
                        // Hanya berputar sesuai qiblah (tapi karena qiblah = 0, maka tetap di atas)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 70,
                              decoration: BoxDecoration(
                                color: isFacingQiblah
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25),
                                  bottomLeft: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isFacingQiblah
                                            ? Colors.green[700]!
                                            : Colors.red[700]!)
                                        .withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mosque,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'KIBLAT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 7,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                        // Titik tengah
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[800],
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Info derajat HP (berubah saat HP diputar)
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${normalizedDirection.toStringAsFixed(1)}°',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: isFacingQiblah
                                ? Colors.green[700]
                                : Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isFacingQiblah
                              ? 'Sudah Menghadap Kiblat!'
                              : 'Arah HP Sekarang',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.phone_android,
                                      size: 14, color: Colors.blue[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'HP: ${normalizedDirection.toStringAsFixed(0)}°',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.mosque,
                                      size: 14, color: Colors.red[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Kiblat: ${qiblah.toStringAsFixed(0)}°',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Petunjuk
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isFacingQiblah ? Colors.green[50] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isFacingQiblah
                              ? Colors.green[300]!
                              : Colors.blue[200]!,
                          width: isFacingQiblah ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                            isFacingQiblah
                                ? Icons.check_circle
                                : Icons.info_outline,
                            color: isFacingQiblah
                                ? Colors.green[700]
                                : Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isFacingQiblah
                                ? '✓ Sempurna! HP sudah menghadap kiblat dengan benar (355° - 5°)'
                                : 'Putar HP hingga panah hijau KIBLAT sejajar dengan huruf U merah di atas',
                            style: TextStyle(
                              fontSize: 13,
                              color: isFacingQiblah
                                  ? Colors.green[900]
                                  : Colors.blue[900],
                              fontWeight: isFacingQiblah
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CompassRose extends StatelessWidget {
  const CompassRose({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        children: [
          // Lingkaran derajat
          CustomPaint(
            size: const Size(280, 280),
            painter: CompassPainter(),
          ),
          // Label arah mata angin
          ..._buildDirectionLabels(),
          // Label derajat
          ..._buildDegreeLabels(),
        ],
      ),
    );
  }

  List<Widget> _buildDirectionLabels() {
    final directions = [
      {'label': 'U', 'angle': 0.0, 'color': Colors.red},
      {'label': 'T', 'angle': 90.0, 'color': Colors.grey[700]},
      {'label': 'S', 'angle': 180.0, 'color': Colors.grey[700]},
      {'label': 'B', 'angle': 270.0, 'color': Colors.grey[700]},
    ];

    return directions.map((dir) {
      final angle = (dir['angle'] as double) * pi / 180;
      final radius = 105.0;

      return Positioned(
        left: 140 + radius * cos(angle - pi / 2) - 15,
        top: 140 + radius * sin(angle - pi / 2) - 15,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: (dir['label'] == 'U') ? Colors.red[700] : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              dir['label'] as String,
              style: TextStyle(
                color: (dir['label'] == 'U') ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildDegreeLabels() {
    final degrees = [0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330];

    return degrees.map((degree) {
      final angle = degree * pi / 180;
      final radius = 75.0;

      return Positioned(
        left: 140 + radius * cos(angle - pi / 2) - 12,
        top: 140 + radius * sin(angle - pi / 2) - 10,
        child: Text(
          '$degree°',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      );
    }).toList();
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Lingkaran luar
    final circlePaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, circlePaint);

    // Lingkaran tengah
    final middleCirclePaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.7, middleCirclePaint);

    // Garis derajat
    for (int i = 0; i < 360; i += 6) {
      final angle = i * pi / 180;
      final isMainDirection = i % 90 == 0;
      final isMidDirection = i % 30 == 0;

      final startRadius = isMainDirection
          ? radius - 25
          : isMidDirection
              ? radius - 18
              : radius - 12;

      final start = Offset(
        center.dx + startRadius * cos(angle - pi / 2),
        center.dy + startRadius * sin(angle - pi / 2),
      );

      final end = Offset(
        center.dx + radius * cos(angle - pi / 2),
        center.dy + radius * sin(angle - pi / 2),
      );

      final linePaint = Paint()
        ..color = isMainDirection
            ? Colors.red[700]!
            : isMidDirection
                ? Colors.grey[600]!
                : Colors.grey[400]!
        ..strokeWidth = isMainDirection
            ? 3
            : isMidDirection
                ? 2
                : 1;

      canvas.drawLine(start, end, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
