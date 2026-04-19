import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'admin/buat_dokumen_screen.dart';
import 'admin/laporan_screen.dart';
import 'admin/riwayat_pemeriksaan_screen.dart';
import 'supir/tugas_supir_screen.dart';
import 'spv/pemeriksaan_screen.dart';
import 'gudang/packing_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String role;
  final String nama;
  final String idUser;

  const DashboardScreen({
    super.key,
    required this.role,
    required this.nama,
    required this.idUser,
  });

  List<Map<String, dynamic>> get _menuItems {
    switch (role) {
      case 'admin':
        return [
          {
            'icon': Icons.note_add_rounded,
            'title': 'Pembuatan\nDokumen',
            'desc': 'Buat & kelola dokumen',
            'color': const Color(0xFF059669),
            'bg': const Color(0xFFECFDF5),
          },
          {
            'icon': Icons.bar_chart_rounded,
            'title': 'Laporan\nOperasional',
            'desc': 'Statistik & analitik',
            'color': const Color(0xFF059669),
            'bg': const Color(0xFFECFDF5),
          },
          {
            'icon': Icons.fact_check_rounded,
            'title': 'Riwayat\nPemeriksaan',
            'desc': 'Rekap hasil cek barang',
            'color': const Color(0xFF059669),
            'bg': const Color(0xFFECFDF5),
          },
        ];
      case 'supervisor':
        return [
          {
            'icon': Icons.inventory_2_rounded,
            'title': 'Pemeriksaan\nBarang',
            'desc': 'Periksa kondisi barang',
            'color': const Color(0xFF059669),
            'bg': const Color(0xFFECFDF5),
          },
        ];
      case 'karyawan_gudang':
        return [
          {
            'icon': Icons.layers_rounded,
            'title': 'Sortir &\nPacking',
            'desc': 'Kelola barang gudang',
            'color': const Color(0xFF059669),
            'bg': const Color(0xFFECFDF5),
          },
        ];
      case 'supir':
        return [
          {
            'icon': Icons.local_shipping_rounded,
            'title': 'Tugas\nPengiriman',
            'desc': 'Lihat rute & muatan',
            'color': const Color(0xFF059669),
            'bg': const Color(0xFFECFDF5),
          },
        ];
      default:
        return [];
    }
  }

  List<Map<String, String>> get _stats {
    switch (role) {
      case 'admin':
        return [
          {'num': '24', 'label': 'Dokumen Aktif'},
          {'num': '8', 'label': 'Kirim Hari Ini'},
          {'num': '3', 'label': 'Menunggu Cek'},
        ];
      case 'supervisor':
        return [
          {'num': '5', 'label': 'Antrian Cek'},
          {'num': '12', 'label': 'Selesai'},
          {'num': '2', 'label': 'Tindak Lanjut'},
        ];
      case 'karyawan_gudang':
        return [
          {'num': '30', 'label': 'Disortir'},
          {'num': '15', 'label': 'Di-packing'},
          {'num': '4', 'label': 'Siap Kirim'},
        ];
      case 'supir':
        return [
          {'num': '3', 'label': 'Tugas Hari Ini'},
          {'num': '2', 'label': 'Berjalan'},
          {'num': '1', 'label': 'Selesai'},
        ];
      default:
        return [];
    }
  }

  void _navigate(BuildContext context, String title) {
    Widget? targetScreen;
    // Bersihkan newline (\n) dari title saat mencocokkan navigasi
    final cleanTitle = title.replaceAll('\n', ' ');

    switch (cleanTitle) {
      case 'Pembuatan Dokumen':
        targetScreen = const BuatDokumenScreen();
        break;
      case 'Laporan Operasional':
        targetScreen = const LaporanScreen();
        break;
      case 'Riwayat Pemeriksaan':
        targetScreen = const RiwayatPemeriksaanScreen();
        break;
      case 'Tugas Pengiriman':
        targetScreen = TugasSupirScreen(idSupir: idUser);
        break;
      case 'Pemeriksaan Barang':
        targetScreen = PemeriksaanScreen(idSpv: idUser);
        break;
      case 'Sortir & Packing':
        targetScreen = PackingScreen(idGudang: idUser);
        break;
    }

    if (targetScreen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => targetScreen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final menus = _menuItems;
    final stats = _stats;
    final paddingTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Warna background yang lebih modern (slate-50)
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header dengan Efek Melengkung & Gradien ─────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: paddingTop + 16,
                    left: 24,
                    right: 24,
                    bottom: stats.isNotEmpty ? 60 : 30, // Ruang ekstra untuk overlap stats
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF166534), Color(0xFF14532D)], // Gradien hijau elegan
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Bar Area
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PT Jakhi Pasaribawa',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Logistik Distribusi Navagreen',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                              tooltip: 'Keluar',
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Hero Greeting Area
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Text(
                              nama.isNotEmpty ? nama[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Color(0xFF166534),
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, $nama!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    role.replaceAll('_', ' ').toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                    ),
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

                // ─── Floating Stats Row (Overlap) ─────────────────────────
                if (stats.isNotEmpty)
                  Positioned(
                    bottom: -30, // Tarik ke bawah agar memotong batas header
                    left: 20,
                    right: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: stats.map((s) => _buildStatItem(s)).toList(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Spacing tambahan karena overlap stats
            SizedBox(height: stats.isNotEmpty ? 50 : 20),

            // ─── Menu Grid ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu Utama',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B), // Slate-800
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 24),
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95, // Disesuaikan agar proporsional
                    children: menus.map((m) => _buildMenuCard(context, m)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(Map<String, String> s) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            s['num']!,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF166534),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s['label']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B), // Slate-500
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, Map<String, dynamic> m) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Melengkung lebih ramah (Figma style)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          highlightColor: (m['color'] as Color).withOpacity(0.05),
          splashColor: (m['color'] as Color).withOpacity(0.1),
          onTap: () => _navigate(context, m['title']),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: m['bg'] as Color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    m['icon'] as IconData,
                    color: m['color'] as Color,
                    size: 26,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m['title'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      m['desc'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8), // Slate-400
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}