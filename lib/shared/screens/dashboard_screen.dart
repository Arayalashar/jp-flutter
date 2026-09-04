import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/auth/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Feature screens
import '../../features/spv/screens/pemeriksaan_screen.dart';
import '../../features/gudang/screens/packing_screen.dart';
import '../../features/admin/screens/buat_dokumen_screen.dart';
import '../../features/admin/screens/laporan_screen.dart';
import '../../features/admin/screens/riwayat_pemeriksaan_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/supir/screens/tugas_supir_screen.dart';

// Design system
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/section_header.dart';
import '../widgets/animated_background.dart';

// Network
import '../../core/network/api_client.dart';
import '../../core/config/api_config.dart';

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

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: AppColors.border),
        ),
        title: const Text("Keluar Aplikasi", style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        content: const Text("Apakah Anda yakin ingin keluar dari akun ini?", style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal", style: TextStyle(color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: const Text("Keluar", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await prefs.setBool('onboarding_seen', true);
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalizedRole = _getNormalizedRole();
    if (normalizedRole == 'admin') {
      return const AdminDashboardScreen();
    }
    final tabs = _buildTabs(normalizedRole);
    final navItems = _buildNavItems(normalizedRole);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: AppGlass.navbar(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              items: navItems,
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TAB BUILDERS PER ROLE
  // ============================================================
  List<Widget> _buildTabs(String role) {
    switch (role) {
      case 'admin':
        return [
          _buildHomeTab(),
          LaporanScreen(),
          const RiwayatPemeriksaanScreen(),
        ];
      case 'gudang':
        return [
          _buildHomeTab(),
          PackingScreen(idGudang: widget.idUser),
        ];
      case 'supir':
        return [
          _buildHomeTab(),
          TugasSupirScreen(idSupir: widget.idUser),
        ];
      case 'spv':
        return [
          _buildHomeTab(),
          PemeriksaanScreen(idSpv: widget.idUser),
        ];
      default:
        return [_buildHomeTab()];
    }
  }

  List<BottomNavigationBarItem> _buildNavItems(String role) {
    switch (role) {
      case 'admin':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Laporan'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Riwayat'),
        ];
      case 'gudang':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Packing'),
        ];
      case 'supir':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: 'Tugas'),
        ];
      case 'spv':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), label: 'Periksa'),
        ];
      default:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
        ];
    }
  }

  // ============================================================
  // HOME TAB — Universal Dashboard
  // ============================================================
  Widget _buildHomeTab() {
    return AnimatedBackground(
      child: RefreshIndicator(
        onRefresh: _fetchStats,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader()),
            // Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: _statsLoading
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                      ))
                    : _buildStatsGrid(),
              ),
            ),
            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  children: [
                    const SectionHeader(title: 'Aksi Cepat', icon: Icons.bolt_rounded),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
            // Spacer
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER CARD — Dark gradient
  // ============================================================
  Widget _buildHeader() {
    final roleLabel = _getRoleLabel();
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
      decoration: BoxDecoration(
        gradient: AppGradients.header,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.surfaceVariant,
                      child: Text(
                        widget.nama.isNotEmpty ? widget.nama[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${widget.nama.split(' ').first}! 👋',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          roleLabel,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Logout button
              Material(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: InkWell(
                  onTap: () => _logout(context),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.logout_rounded, color: AppColors.textTertiary, size: 22),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0, duration: 400.ms);
  }

  String _getRoleLabel() {
    final r = _getNormalizedRole();
    switch (r) {
      case 'admin': return '🛡️ ADMINISTRATOR';
      case 'gudang': return '📦 KARYAWAN GUDANG';
      case 'supir': return '🚛 SUPIR PENGIRIMAN';
      case 'spv': return '🔍 SUPERVISOR QC';
      default: return widget.role.toUpperCase();
    }
  }

  // ============================================================
  // STATS GRID — Role-specific
  // ============================================================
  Widget _buildStatsGrid() {
    final normalizedRole = _getNormalizedRole();
    switch (normalizedRole) {
      case 'admin':
        return _buildAdminStats();
      case 'gudang':
        return _buildGudangStats();
      case 'supir':
        return _buildSupirStats();
      case 'spv':
        return _buildSpvStats();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAdminStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: StatCard(
              label: 'Total Dokumen',
              value: '${_stats['total'] ?? 0}',
              icon: Icons.description_outlined,
              iconColor: AppColors.info,
            )),
            const SizedBox(width: 12),
            Expanded(child: StatCard(
              label: 'Selesai',
              value: '${_stats['selesai'] ?? 0}',
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppColors.success,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: StatCard(
              label: 'Pending',
              value: '${_stats['pending'] ?? 0}',
              icon: Icons.pending_outlined,
              iconColor: AppColors.warning,
            )),
            const SizedBox(width: 12),
            Expanded(child: StatCard(
              label: 'Dalam Perjalanan',
              value: '${_stats['dalam_perjalanan'] ?? 0}',
              icon: Icons.local_shipping_outlined,
              iconColor: const Color(0xFF818CF8),
            )),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildGudangStats() {
    return Row(
      children: [
        Expanded(child: StatCard(
          label: 'Antrean Packing',
          value: '${_stats['pending'] ?? 0}',
          icon: Icons.pending_actions_rounded,
          iconColor: AppColors.warning,
        )),
        const SizedBox(width: 12),
        Expanded(child: StatCard(
          label: 'Selesai Hari Ini',
          value: '${_stats['selesai_hari_ini'] ?? 0}',
          icon: Icons.task_alt_rounded,
          iconColor: AppColors.success,
        )),
        const SizedBox(width: 12),
        Expanded(child: StatCard(
          label: 'Total',
          value: '${_stats['total_packing'] ?? 0}',
          icon: Icons.inventory_rounded,
          iconColor: AppColors.info,
        )),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildSupirStats() {
    return Row(
      children: [
        Expanded(child: StatCard(
          label: 'Tugas Aktif',
          value: '${_stats['aktif'] ?? 0}',
          icon: Icons.local_shipping_outlined,
          iconColor: AppColors.warning,
        )),
        const SizedBox(width: 12),
        Expanded(child: StatCard(
          label: 'Selesai',
          value: '${_stats['selesai'] ?? 0}',
          icon: Icons.check_circle_outline_rounded,
          iconColor: AppColors.success,
        )),
        const SizedBox(width: 12),
        Expanded(child: StatCard(
          label: 'Total',
          value: '${_stats['total'] ?? 0}',
          icon: Icons.assignment_outlined,
          iconColor: AppColors.info,
        )),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildSpvStats() {
    return Row(
      children: [
        Expanded(child: StatCard(
          label: 'Menunggu',
          value: '${_stats['pending'] ?? 0}',
          icon: Icons.pending_outlined,
          iconColor: AppColors.warning,
        )),
        const SizedBox(width: 12),
        Expanded(child: StatCard(
          label: 'Hari Ini',
          value: '${_stats['hari_ini'] ?? 0}',
          icon: Icons.today_rounded,
          iconColor: AppColors.success,
        )),
        const SizedBox(width: 12),
        Expanded(child: StatCard(
          label: 'Total',
          value: '${_stats['total_periksa'] ?? 0}',
          icon: Icons.fact_check_outlined,
          iconColor: AppColors.info,
        )),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================
  Widget _buildQuickActions() {
    final normalizedRole = _getNormalizedRole();
    final actions = _getQuickActions(normalizedRole);

    return GridView.count(
      crossAxisCount: normalizedRole == 'admin' ? 3 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: actions,
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }

  List<Widget> _getQuickActions(String role) {
    switch (role) {
      case 'admin':
        return [
          _buildActionCard(
            icon: Icons.note_add_rounded,
            label: 'Buat\nDokumen',
            color: AppColors.primary,
            onTap: () => _navigateTo(BuatDokumenScreen(idAdmin: widget.idUser)),
          ),
          _buildActionCard(
            icon: Icons.bar_chart_rounded,
            label: 'Laporan\nOperasional',
            color: AppColors.info,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          _buildActionCard(
            icon: Icons.history_rounded,
            label: 'Riwayat\nSPV',
            color: const Color(0xFF818CF8),
            onTap: () => setState(() => _currentIndex = 2),
          ),
        ];
      case 'gudang':
        return [
          _buildActionCard(
            icon: Icons.inventory_2_outlined,
            label: 'Tugas\nPacking',
            color: AppColors.primary,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          _buildActionCard(
            icon: Icons.refresh_rounded,
            label: 'Refresh\nData',
            color: AppColors.info,
            onTap: _fetchStats,
          ),
        ];
      case 'supir':
        return [
          _buildActionCard(
            icon: Icons.local_shipping_outlined,
            label: 'Tugas\nPengiriman',
            color: AppColors.primary,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          _buildActionCard(
            icon: Icons.refresh_rounded,
            label: 'Refresh\nData',
            color: AppColors.info,
            onTap: _fetchStats,
          ),
        ];
      case 'spv':
        return [
          _buildActionCard(
            icon: Icons.fact_check_outlined,
            label: 'Antrean\nPeriksa',
            color: AppColors.primary,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          _buildActionCard(
            icon: Icons.refresh_rounded,
            label: 'Refresh\nData',
            color: AppColors.info,
            onTap: _fetchStats,
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashColor: color.withValues(alpha: 0.05),
        child: Container(
          decoration: AppGlass.elevatedCard(radius: AppRadius.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) => _fetchStats()); // refresh stats when returning
  }
}
