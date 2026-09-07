import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/auth/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Feature screens
import '../../features/spv/screens/pemeriksaan_screen.dart';
import '../../features/spv/screens/riwayat_spv_screen.dart';

import '../../features/gudang/screens/packing_screen.dart';


import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/supir/screens/tugas_supir_screen.dart';
import '../../features/auth/screens/profil_screen.dart';
import '../../features/admin/screens/notification_screen.dart';


// Design system (Light Theme style matching Admin)
import '../theme/light_theme.dart';

// Network
import 'package:provider/provider.dart';
import '../../features/admin/providers/notification_provider.dart';
import '../../features/spv/providers/spv_provider.dart';
import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';

class DashboardScreen extends StatefulWidget {
  final String role;
  final String nama;
  final String idUser;

  const DashboardScreen({
    super.key,
    required this.role,
    required this.nama,
    required this.idUser,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  Map<String, dynamic> _stats = {};
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _statsLoading = true);
    final roleParam = _getRoleParam();
    final response = await ApiClient.get(
      '${ApiConfig.dashboardStats}?role=$roleParam&id_user=${widget.idUser}',
    );
    if (mounted) {
      context.read<NotificationProvider>().fetchNotifications(widget.idUser);
      setState(() {
        _stats = response['data'] ?? {};
        _statsLoading = false;
      });
    }
  }

  String _getRoleParam() {
    final r = widget.role.toLowerCase();
    if (r == 'karyawan_gudang' || r == 'gudang') return 'karyawan_gudang';
    if (r == 'supervisor' || r == 'spv') return 'supervisor';
    return r;
  }

  String _getNormalizedRole() {
    final r = widget.role.toLowerCase();
    if (r == 'karyawan_gudang' || r == 'gudang') return 'gudang';
    if (r == 'supervisor' || r == 'spv') return 'spv';
    return r;
  }

    @override
  Widget build(BuildContext context) {
    final normalizedRole = _getNormalizedRole();
    if (normalizedRole == 'admin') {
      return const AdminDashboardScreen();
    }
    
    final tabs = _buildTabs(normalizedRole);
    final navItems = _buildNavData(normalizedRole);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: LightTheme.background,
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
        bottomNavigationBar: _FloatingNavbar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            if (index == 0) _fetchStats();
            if (index == 2 && _getNormalizedRole() == 'spv') {
              context.read<SpvProvider>().fetchRiwayat(widget.idUser);
            }
          },
          navData: navItems,
          onFabTap: _fetchStats,
        ),
      ),
    );
  }

  // ============================================================
  // TAB BUILDERS PER ROLE
  // ============================================================
    List<Widget> _buildTabs(String role) {
    switch (role) {
      case 'gudang':
        return [
          _buildHomeTab(),
          PackingScreen(idGudang: widget.idUser),
          ProfilScreen(nama: widget.nama, role: widget.role, stats: _stats),
        ];
      case 'supir':
        return [
          _buildHomeTab(),
          TugasSupirScreen(idSupir: widget.idUser),
          ProfilScreen(nama: widget.nama, role: widget.role, stats: _stats),
        ];
      case 'spv':
        return [
          _buildHomeTab(),
          PemeriksaanScreen(
            idSpv: widget.idUser, 
            stats: _stats,
            onTaskCompleted: () {
              _fetchStats();
              context.read<SpvProvider>().fetchRiwayat(widget.idUser);
            },
          ),
          RiwayatSpvScreen(idSpv: widget.idUser),
          ProfilScreen(nama: widget.nama, role: widget.role, stats: _stats),
        ];
      default:
        return [_buildHomeTab()];
    }
  }

    List<Map<String, dynamic>> _buildNavData(String role) {
    switch (role) {
      case 'gudang':
        return [
          {'icon': Icons.home_rounded, 'label': 'Beranda'},
          {'icon': Icons.inventory_2_rounded, 'label': 'Packing'},
          {'icon': Icons.person_rounded, 'label': 'Profil'},
        ];
      case 'supir':
        return [
          {'icon': Icons.home_rounded, 'label': 'Beranda'},
          {'icon': Icons.local_shipping_rounded, 'label': 'Tugas'},
          {'icon': Icons.person_rounded, 'label': 'Profil'},
        ];
      case 'spv':
        return [
          {'icon': Icons.home_rounded, 'label': 'Beranda'},
          {'icon': Icons.fact_check_rounded, 'label': 'Periksa'},
          {'icon': Icons.history_rounded, 'label': 'Riwayat'},
          {'icon': Icons.person_rounded, 'label': 'Profil'},
        ];
      default:
        return [
          {'icon': Icons.home_rounded, 'label': 'Beranda'},
          {'icon': Icons.person_rounded, 'label': 'Profil'},
        ];
    }
  }

  // ============================================================
  // HOME TAB — Universal Dashboard
  // ============================================================
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _fetchStats,
      color: LightTheme.primary,
      backgroundColor: LightTheme.surface,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _buildTopHeader(context),
            ).animate().fadeIn(duration: 400.ms),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _buildChart(context),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0),
          ),

                    SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _statsLoading
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: LightTheme.primary),
                    ))
                  : _BentoGrid(stats: _stats, role: _getNormalizedRole()),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05, end: 0),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _statsLoading ? const SizedBox.shrink() : _buildRiwayatTerakhir(),
            ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.05, end: 0),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    String nama = widget.nama;
    if (nama.isEmpty) nama = 'Pengguna';

    return SafeArea(
      bottom: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: LightTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    nama[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selamat datang,', style: TextStyle(fontSize: 13, color: LightTheme.textSecondary, fontWeight: FontWeight.w500)),
                  Text(
                    nama,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: LightTheme.textPrimary, letterSpacing: -0.5),
                  ),
                ],
              ),
            ],
          ),
          Consumer<NotificationProvider>(
            builder: (context, notifProvider, child) {
              final unread = notifProvider.unreadCount;
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                },
                child: Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: LightTheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: LightTheme.border),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.notifications_none_rounded, color: LightTheme.textPrimary, size: 22),
                    ),
                    if (unread > 0)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    String roleLabel = _getRoleLabel();
    String title = "Dashboard Utama";
    IconData icon = Icons.dashboard_rounded;
    final r = _getNormalizedRole();
    if (r == 'gudang') { title = "Kelola Packing"; icon = Icons.inventory_2_rounded; }
    else if (r == 'spv') { title = "Kelola Supervisi"; icon = Icons.fact_check_rounded; }
    else if (r == 'supir') { title = "Kelola Pengiriman"; icon = Icons.local_shipping_rounded; }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9A3C), Color(0xFFFF7A00)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(roleLabel, style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Aktif hari ini', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

    Widget _buildRiwayatTerakhir() {
    final riwayatList = _stats['riwayat_terbaru'] as List? ?? [];
    if (riwayatList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Riwayat Terakhir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: LightTheme.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...riwayatList.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LightTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LightTheme.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: LightTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.history_rounded, color: LightTheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LightTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text(item['subtitle'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: LightTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: LightTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
                child: Text(item['status'] ?? '', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: LightTheme.primary)),
              ),
            ],
          ),
        )),
      ],
    );
  }
  String _getRoleLabel() {
    final r = _getNormalizedRole();
    switch (r) {
      case 'gudang': return 'STAF GUDANG';
      case 'spv': return 'SUPERVISOR QC';
      case 'supir': return 'SUPIR PENGIRIMAN';
      default: return 'KARYAWAN';
    }
  }
}

// ============================================================
// BENTO GRID FOR SPV/GUDANG/SUPIR
// ============================================================
class _BentoGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  final String role;
  
  const _BentoGrid({required this.stats, required this.role});

  @override
  Widget build(BuildContext context) {
    final nWait = stats['menunggu']?.toString() ?? '0';
    final nToday = stats['hari_ini']?.toString() ?? '0';
    final nTotal = stats['total']?.toString() ?? stats['total_periksa']?.toString() ?? stats['total_packing']?.toString() ?? '0';

    return Column(
      children: [
        // Top full width card
        _buildBentoCard(
          title: "Ringkasan Mingguan",
          subtitle: "Total: $nTotal",
          isPrimary: true,
          child: _buildMockBarChart(),
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String subtitle,
    String? value,
    IconData? icon,
    Widget? child,
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? LightTheme.surface : LightTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LightTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPrimary) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: LightTheme.primary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: LightTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (child != null) child,
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: LightTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: LightTheme.primary, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(value ?? '0', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: LightTheme.textPrimary)),
            const SizedBox(height: 4),
            Text('$title\n$subtitle', style: const TextStyle(fontSize: 13, color: LightTheme.textSecondary, fontWeight: FontWeight.w600, height: 1.2)),
          ],
        ],
      ),
    );
  }

  Widget _buildMockBarChart() {
    final data = [4, 6, 3, 8, 5, 2, 1];
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final maxVal = 8;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final height = (data[i] / maxVal) * 60;
        final isToday = i == 0;
        return Column(
          children: [
            Container(
              width: 24,
              height: height,
              decoration: BoxDecoration(
                color: isToday ? LightTheme.primary : LightTheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[i],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: isToday ? LightTheme.primary : LightTheme.textTertiary,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ============================================================
// FLOATING PILL NAVBAR
// ============================================================
class _FloatingNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;
  final List<Map<String, dynamic>> navData;

  const _FloatingNavbar({
    required this.currentIndex, 
    required this.onTap,
    required this.navData,
    required this.onFabTap,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    
    // Distribute nav items around the center FAB
    for (int i = 0; i < navData.length; i++) {
      items.add(
        _NavItem(
          icon: navData[i]['icon'], 
          label: navData[i]['label'], 
          index: i, 
          currentIndex: currentIndex, 
          onTap: onTap
        )
      );
      
      // Insert FAB after the first item if there are exactly 2 items
      if (i == 0 && navData.length == 2) {
        items.add(_buildFab());
      }
    }
    
    // Fallback if there's only 1 item
    if (navData.length == 1) {
      items.add(_buildFab());
    }

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
            children: items,
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        onFabTap();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: LightTheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: LightTheme.primary, width: 2),
        ),
        child: const Icon(Icons.refresh_rounded, color: LightTheme.primary, size: 32),
      ),
    ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack);
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
