import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/admin_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/theme/light_theme.dart';
import 'laporan_screen.dart';
import 'riwayat_pemeriksaan_screen.dart';
import 'buat_dokumen_screen.dart';
import '../providers/notification_provider.dart';
import '../../auth/screens/edit_profile_screen.dart';
import 'notification_screen.dart';

// ============================================================
// ADMIN DASHBOARD — Main Shell
// ============================================================
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardPage(),
    LaporanScreen(),
    RiwayatPemeriksaanScreen(),
    _ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, // Dark status bar icons for light bg
      child: Scaffold(
        backgroundColor: LightTheme.background,
        extendBody: true, // Allow content to scroll behind the floating navbar
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: _FloatingNavbar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}

// ============================================================
// FLOATING PILL NAVBAR
// ============================================================
class _FloatingNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavbar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A), // Dark floating pill
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Beranda', index: 0, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.inventory_2_rounded, label: 'Laporan', index: 1, currentIndex: currentIndex, onTap: onTap),
              
              // Floating FAB in the center
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  final idAdmin = context.read<AuthProvider>().currentUser?.idUser ?? '';
                  Navigator.push(context, MaterialPageRoute(builder: (_) => BuatDokumenScreen(idAdmin: idAdmin)));
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: LightTheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: LightTheme.primary, width: 2),
                  ),
                  child: const Icon(Icons.add_rounded, color: LightTheme.primary, size: 32),
                ),
              ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),

              _NavItem(icon: Icons.history_rounded, label: 'Lacak', index: 2, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.person_rounded, label: 'Profil', index: 3, currentIndex: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? LightTheme.surface : LightTheme.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? LightTheme.surface : LightTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD PAGE
// ============================================================
class _DashboardPage extends StatefulWidget {
  const _DashboardPage();

  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      provider.fetchLaporan('Semua');
      provider.fetchRiwayat();

      final notifProvider = context.read<NotificationProvider>();
      final idUser = context.read<AuthProvider>().currentUser?.idUser ?? '';
      if (idUser.isNotEmpty) {
        notifProvider.fetchNotifications(idUser);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            final p = context.read<AdminProvider>();
            await Future.wait([p.fetchLaporan('Semua'), p.fetchRiwayat()]);
          },
          color: LightTheme.primary,
          backgroundColor: LightTheme.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // Search & Header Area
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: _buildTopHeader(context),
                ).animate().fadeIn(duration: 400.ms),
              ),

              // Weekly Chart (formerly Search Bar)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: _buildChart(context),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0),
              ),

              // Bento Grid (New Delivery / Track Package)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: _BentoGrid(),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05, end: 0),
              ),

              // Laporan Operasional Terakhir (Current Shipment)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: _RecentLaporanSection(),
                ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.05, end: 0),
              ),

              // Riwayat Supervisor Terakhir (Recent Shipment)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: _RecentRiwayatSection(),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.05, end: 0),
              ),

              // Bottom padding for floating navbar
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final nama = auth.currentUser?.namaLengkap ?? 'Admin';
        final initials = nama.trim().split(' ').take(2).map((e) => e.isEmpty ? '' : e[0].toUpperCase()).join();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Profile avatar — orange gradient
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9A3C), Color(0xFFFF7A00)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: LightTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials.isEmpty ? 'A' : initials,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selamat datang,', style: TextStyle(fontSize: 12, color: LightTheme.textSecondary, fontWeight: FontWeight.w500)),
                        Text(nama, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
                      ],
                    ),
                  ],
                ),
                // Notification bell — orange badge
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: LightTheme.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_rounded, color: LightTheme.textPrimary, size: 22),
                        Consumer<NotificationProvider>(
                          builder: (context, notif, _) {
                            if (notif.unreadCount == 0) return const SizedBox();
                            return Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: LightTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Orange summary banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF9A3C), Color(0xFFFF7A00), Color(0xFFE05D00)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: LightTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dashboard Admin', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        const Text('Kelola Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Aktif hari ini', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 32,
                      height: 32,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChart(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final summary = provider.laporanData?['summary'] as Map<String, dynamic>? ?? {};
        final total = int.tryParse(summary['total']?.toString() ?? '0') ?? 0;

        // Weekly data (mock)
        final weekData = [
          {'day': 'Sen', 'val': 4},
          {'day': 'Sel', 'val': 7},
          {'day': 'Rab', 'val': 5},
          {'day': 'Kam', 'val': 9},
          {'day': 'Jum', 'val': 6},
          {'day': 'Sab', 'val': 3},
          {'day': 'Min', 'val': 2},
        ];
        final maxVal = weekData.map((e) => e['val'] as int).reduce((a, b) => a > b ? a : b);
        final todayIdx = DateTime.now().weekday - 1;

        return Container(
          decoration: LightTheme.cardDecoration(radius: 20),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Orange header strip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF9A3C), Color(0xFFFF7A00)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ringkasan Mingguan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Total: $total', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: weekData.asMap().entries.map((e) {
                      final day = e.value['day'] as String;
                      final val = e.value['val'] as int;
                      final ratio = maxVal > 0 ? val / maxVal : 0.0;
                      final isToday = e.key == todayIdx;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 500 + e.key * 80),
                            curve: Curves.easeOutCubic,
                            width: 24,
                            height: (60 * ratio).clamp(4.0, 60.0),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? LightTheme.primary
                                  : LightTheme.primary.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            day,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                              color: isToday ? LightTheme.primary : LightTheme.textTertiary,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// BENTO GRID HERO SECTION
// ============================================================
class _BentoGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Large Card (Buat Dokumen)
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: () {
              final idAdmin = context.read<AuthProvider>().currentUser?.idUser ?? '';
              Navigator.push(context, MaterialPageRoute(builder: (_) => BuatDokumenScreen(idAdmin: idAdmin)));
            },
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF9A3C), Color(0xFFFF7A00), Color(0xFFE05D00)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: LightTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('BARU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Pengiriman\nBaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2)),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_shipping_rounded, size: 56, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Right Stacked Cards
        Expanded(
          flex: 4,
          child: SizedBox(
            height: 200,
            child: Column(
              children: [
                // Top Right Card (Track Package / Riwayat)
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatPemeriksaanScreen())),
                    child: Container(
                      width: double.infinity,
                      decoration: LightTheme.cardDecoration(radius: 20),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text('Lacak\nPaket', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LightTheme.textPrimary, height: 1.2)),
                          ),
                          // Icon instead of watermarked illustration
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: LightTheme.warning.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.inventory_2_rounded, size: 28, color: LightTheme.warning),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Bottom Right Card (Laporan)
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporanScreen())),
                    child: Container(
                      width: double.infinity,
                      decoration: LightTheme.cardDecoration(radius: 20),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text('Laporan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LightTheme.textPrimary)),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: LightTheme.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long_rounded, size: 18, color: LightTheme.primary),
                          ),
                        ],
                      ),
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
}

// ============================================================
// RECENT LAPORAN (CURRENT SHIPMENT)
// ============================================================
class _RecentLaporanSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final listDokumen = (provider.laporanData?['data'] as List? ?? []).take(2).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pengiriman Saat Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: LightTheme.textPrimary)),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporanScreen())),
                  child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.textTertiary)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (provider.isLoading && listDokumen.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: LightTheme.primary)))
            else if (listDokumen.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: LightTheme.cardDecoration(),
                child: const EmptyStateWidget(icon: Icons.local_shipping_outlined, title: 'Tidak ada pengiriman aktif', subtitle: 'Pengiriman akan muncul di sini'),
              )
            else
              ...listDokumen.map((doc) => _CurrentShipmentCard(doc: doc as Map<String, dynamic>)),
          ],
        );
      },
    );
  }
}

class _CurrentShipmentCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _CurrentShipmentCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final status = doc['status_pengiriman'] ?? 'Process';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: LightTheme.cardDecoration(radius: 24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: LightTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: LightTheme.primary.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.description_rounded, color: LightTheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${doc['nomor_dokumen'] ?? '-'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: LightTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text(doc['nama_supir'] ?? 'Belum ditugaskan', style: const TextStyle(fontSize: 12, color: LightTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: LightTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: LightTheme.primary.withValues(alpha: 0.2)),
                ),
                child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: LightTheme.primary)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Timeline indicator
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: LightTheme.primary, size: 18),
              Expanded(child: Container(height: 2, color: LightTheme.primary.withValues(alpha: 0.3))),
              const Icon(Icons.check_circle_rounded, color: LightTheme.primary, size: 18),
              Expanded(child: Container(height: 2, color: LightTheme.border)),
              const Icon(Icons.radio_button_unchecked_rounded, color: LightTheme.border, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          
          // Locations
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc['tanggal'] ?? 'Hari Ini', style: const TextStyle(fontSize: 10, color: LightTheme.textTertiary)),
                  const SizedBox(height: 2),
                  const Text('Gudang Utama', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.textPrimary)),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Estimasi', style: TextStyle(fontSize: 10, color: LightTheme.textTertiary)),
                  SizedBox(height: 2),
                  Text('Tujuan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.textPrimary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// RECENT RIWAYAT (RECENT SHIPMENT)
// ============================================================
class _RecentRiwayatSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final list = provider.riwayatList.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Riwayat Pengiriman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: LightTheme.textPrimary)),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatPemeriksaanScreen())),
                  child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LightTheme.textTertiary)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (provider.isLoading && list.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: LightTheme.primary)))
            else if (list.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: LightTheme.cardDecoration(),
                child: const EmptyStateWidget(icon: Icons.history_rounded, title: 'Tidak ada riwayat pengiriman', subtitle: 'Item yang selesai akan muncul di sini'),
              )
            else
              ...list.map((item) => _RecentShipmentCard(item: item as Map<String, dynamic>)),
          ],
        );
      },
    );
  }
}

class _RecentShipmentCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _RecentShipmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final status = item['status_pemeriksaan'] ?? 'Delivered';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: LightTheme.cardDecoration(radius: 20),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: LightTheme.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LightTheme.warning.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: LightTheme.warning),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${item['kode_barang'] ?? '-'}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LightTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(item['nama_barang'] ?? '-', style: const TextStyle(fontSize: 12, color: LightTheme.textSecondary), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: LightTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: LightTheme.success.withValues(alpha: 0.25)),
            ),
            child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: LightTheme.success)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFIL PAGE (Light Mode Adaptation)
// ============================================================
class _ProfilPage extends StatelessWidget {
  const _ProfilPage();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final nama = auth.currentUser?.namaLengkap ?? 'Admin';
        final role = auth.currentUser?.role ?? 'admin';
        final initials = nama.trim().split(' ').take(2).map((e) => e.isEmpty ? '' : e[0].toUpperCase()).join();

        return Scaffold(
          backgroundColor: LightTheme.background,
          appBar: AppBar(
            title: const Text('Profil', style: TextStyle(color: LightTheme.textPrimary, fontWeight: FontWeight.w700)),
            backgroundColor: LightTheme.background,
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Avatar — orange gradient
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF9A3C), Color(0xFFFF7A00)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: LightTheme.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials.isEmpty ? 'A' : initials,
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ).animate().scale(begin: const Offset(0.7, 0.7), duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 16),
                Text(nama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: LightTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: LightTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: LightTheme.primary, letterSpacing: 1.2),
                  ),
                ),
                const SizedBox(height: 32),

                // Info card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: LightTheme.cardDecoration(radius: 24),
                  child: Column(
                    children: [
                      _ProfilRow(icon: Icons.person_rounded, label: 'Nama Lengkap', value: nama),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: LightTheme.border, height: 1),
                      ),
                      _ProfilRow(icon: Icons.shield_rounded, label: 'Peran', value: role.toUpperCase()),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                const SizedBox(height: 24),

                // Edit Profil button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                    icon: const Icon(Icons.edit_rounded, color: LightTheme.primary, size: 20),
                    label: const Text('Edit Profil', style: TextStyle(color: LightTheme.primary, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: LightTheme.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)), // Pill button
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
                const SizedBox(height: 16),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: LightTheme.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          title: const Text('Keluar', style: TextStyle(color: LightTheme.textPrimary, fontWeight: FontWeight.w700)),
                          content: const Text('Apakah Anda yakin ingin keluar?', style: TextStyle(color: LightTheme.textSecondary)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: LightTheme.textSecondary))),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Keluar', style: TextStyle(color: Color(0xFFEF4444)))),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                    label: const Text('Keluar', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF2F2), // Light red bg
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)), // Pill button
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfilRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfilRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: LightTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: LightTheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: LightTheme.textSecondary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, color: LightTheme.textPrimary, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}
