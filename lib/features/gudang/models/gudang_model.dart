class GudangModel {
  final int idDokumen;
  final String nomorDokumen;
  final String statusPengiriman;
  final String kodeBarang;
  final String namaBarang;
  final int jumlahPacking;
  final String tujuanPengiriman;
  final String? namaSupir;

  GudangModel({
    required this.idDokumen,
    required this.nomorDokumen,
    required this.statusPengiriman,
    required this.kodeBarang,
    required this.namaBarang,
    required this.jumlahPacking,
    required this.tujuanPengiriman,
    this.namaSupir,
  });

  factory GudangModel.fromJson(Map<String, dynamic> json) {
    return GudangModel(
      idDokumen: int.tryParse(json['id_dokumen']?.toString() ?? '0') ?? 0,
      nomorDokumen: json['nomor_dokumen'] ?? '',
      statusPengiriman: json['status_pengiriman'] ?? '',
      kodeBarang: json['kode_barang'] ?? '',
      namaBarang: json['nama_barang'] ?? '',
      jumlahPacking: int.tryParse(json['jumlah_packing']?.toString() ?? '0') ?? 0,
      tujuanPengiriman: json['tujuan_pengiriman'] ?? '',
      namaSupir: json['nama_supir'],
    );
  }
}
