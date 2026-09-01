import '../../../core/network/api_client.dart';
import '../../../core/config/api_config.dart';
import '../models/master_data_model.dart';

class AdminRepository {
  Future<MasterDataModel> fetchMasterData() async {
    final response = await ApiClient.get(ApiConfig.masterData);
    
    if (response['status'] == 'success') {
      return MasterDataModel.fromJson(response);
    } else {
      throw Exception(response['message'] ?? 'Gagal memuat master data');
    }
  }

  Future<Map<String, dynamic>> buatDokumen({
    required String jenisDokumen,
    required String nomorDokumen,
    required String tujuan,
    required String idSupir,
    required String idBarang,
    required String jumlah,
    required String idAdmin,
  }) async {
    return await ApiClient.post(
      ApiConfig.buatDokumen,
      body: {
        "jenis_dokumen": jenisDokumen,
        "nomor_dokumen": nomorDokumen,
        "tujuan": tujuan,
        "id_supir": idSupir,
        "id_barang": idBarang,
        "jumlah": jumlah,
        "id_admin": idAdmin,
      },
    );
  }

  Future<Map<String, dynamic>> fetchLaporan(String filter) async {
    return await ApiClient.get('${ApiConfig.laporan}?filter=$filter');
  }

  Future<Map<String, dynamic>> fetchRiwayatPemeriksaan() async {
    return await ApiClient.get(ApiConfig.riwayatPemeriksaan);
  }

  Future<Map<String, dynamic>> tambahBarang(String namaBarang, String kategori) async {
    return await ApiClient.post(
      ApiConfig.tambahBarang,
      body: {
        "nama_barang": namaBarang,
        "kategori": kategori,
      },
    );
  }
}
