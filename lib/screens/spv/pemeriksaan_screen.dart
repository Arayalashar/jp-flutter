import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PemeriksaanScreen extends StatefulWidget {
  final String idSpv;
  const PemeriksaanScreen({super.key, required this.idSpv});

  @override
  State<PemeriksaanScreen> createState() => _PemeriksaanScreenState();
}

class _PemeriksaanScreenState extends State<PemeriksaanScreen> {
  List _listAntrean = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAntrean();
  }

  Future<void> _fetchAntrean() async {
    setState(() => _isLoading = true);
    try {
      var url = Uri.parse('https://jpapi.alwaysdata.net/api_resi_pengambilan.php');
      var response = await http.get(url);

      if (!mounted) return;

      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _listAntrean = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showSnackBar(data['message'] ?? "Gagal memuat antrean.", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar("Gagal terhubung ke server. Periksa koneksi Anda.", isError: true);
    }
  }

  // FIX: Semua parameter sekarang diambil langsung dari argumen fungsi ini,
  // tidak lagi dari variabel yang tidak terdefinisi.
  Future<void> _simpanPemeriksaan(
    Map item,
    int bagus,
    int rusak,
    String status,
    String catatan,
  ) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      var url = Uri.parse('https://jpapi.alwaysdata.net/api_periksa_barang.php');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          // FIX: Ambil id_dokumen dan id_barang dari map `item` yang diterima
          "id_dokumen": item['id_dokumen'],
          "id_barang": item['id_barang'],
          // FIX: Gunakan widget.idSpv (sesuai nama field di widget)
          "id_spv": widget.idSpv,
          "jumlah_diharapkan": item['jumlah_diharapkan'],
          // FIX: Gunakan parameter bagus, rusak, catatan dari argumen fungsi
          "jumlah_bagus": bagus,
          "jumlah_rusak": rusak,
          "status_pemeriksaan": status,
          "catatan": catatan,
        }),
      );

      if (!mounted) return;

      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnackBar(data['message'], isError: false);
        _fetchAntrean();
      } else {
        _showSnackBar(data['message'], isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Gagal menyimpan hasil pemeriksaan.", isError: true);
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showPeriksaDialog(Map item) {
    TextEditingController bagusCtrl =
        TextEditingController(text: item['jumlah_diharapkan'].toString());
    TextEditingController rusakCtrl = TextEditingController(text: "0");
    TextEditingController catatanCtrl = TextEditingController();
    String status = "Lengkap";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Dialog
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.fact_check_outlined,
                              color: Color(0xFF166534),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              "Pemeriksaan Fisik",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Info Barang
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nama_barang'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Tercatat di Resi: ${item['jumlah_diharapkan']} Unit",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Inputs
                      Row(
                        children: [
                          Expanded(
                            child: _buildDialogTextField(
                              controller: bagusCtrl,
                              label: "Jml Bagus",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDialogTextField(
                              controller: rusakCtrl,
                              label: "Jml Rusak",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildDialogLabel("Status Keseluruhan"),
                      DropdownButtonFormField<String>(
                        value: status,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade400,
                        ),
                        items: ['Lengkap', 'Kurang', 'Rusak']
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) => setStateDialog(() => status = val!),
                        decoration: _dialogInputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      _buildDialogLabel("Catatan (Opsional)"),
                      TextField(
                        controller: catatanCtrl,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 14),
                        decoration:
                            _dialogInputDecoration(hint: "Tulis kendala jika ada..."),
                      ),

                      const SizedBox(height: 32),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "Batal",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                int bagus = int.tryParse(bagusCtrl.text) ?? 0;
                                int rusak = int.tryParse(rusakCtrl.text) ?? 0;
                                // FIX: Teruskan semua nilai yang benar ke fungsi simpan
                                _simpanPemeriksaan(
                                  item,
                                  bagus,
                                  rusak,
                                  status,
                                  catatanCtrl.text,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF166534),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "Simpan Hasil",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDialogLabel(label),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          decoration: _dialogInputDecoration(),
        ),
      ],
    );
  }

  InputDecoration _dialogInputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Antrean Pemeriksaan",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF166534),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF166534)))
          : RefreshIndicator(
              onRefresh: _fetchAntrean,
              color: const Color(0xFF166534),
              child: _listAntrean.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      itemCount: _listAntrean.length,
                      itemBuilder: (context, index) {
                        var item = _listAntrean[index];
                        return _buildAntreanCard(item);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada barang datang.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tarik ke bawah untuk mengecek kedatangan',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAntreanCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 20,
                  color: Color(0xFF166534),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['nomor_dokumen'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _buildInfoRow(Icons.inventory_2_outlined, "Barang:", item['nama_barang']),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.tag_rounded,
            "Jumlah di Resi:",
            "${item['jumlah_diharapkan']} Unit",
            isHighlight: true,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.local_shipping_outlined,
            "Supir Pengantar:",
            item['supir'] ?? '-',
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showPeriksaDialog(item),
              icon: const Icon(Icons.fact_check_outlined, color: Colors.white, size: 20),
              label: const Text(
                "Periksa Fisik",
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        ),
        const SizedBox(width: 8),
        Text(
          "$label ",
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isHighlight ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}