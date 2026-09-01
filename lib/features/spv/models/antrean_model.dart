class AntreanModel {
  final int idDokumen;
  final String nomorDokumen;
  final int idBarang;
  final String namaBarang;
  final int jumlahDiharapkan;
  final String? supir;

  AntreanModel({
    required this.idDokumen,
    required this.nomorDokumen,
    required this.idBarang,
    required this.namaBarang,
    required this.jumlahDiharapkan,
    this.supir,
  });

  factory AntreanModel.fromJson(Map<String, dynamic> json) {
    return AntreanModel(
      idDokumen: int.tryParse(json['id_dokumen']?.toString() ?? '0') ?? 0,
      nomorDokumen: json['nomor_dokumen'] ?? '',
      idBarang: int.tryParse(json['id_barang']?.toString() ?? '0') ?? 0,
      namaBarang: json['nama_barang'] ?? '',
      jumlahDiharapkan: int.tryParse(json['jumlah_diharapkan']?.toString() ?? '0') ?? 0,
      supir: json['supir'],
    );
  }
}
