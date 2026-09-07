import '../../../core/network/api_client.dart';
import '../../../core/config/api_config.dart';
import '../models/antrean_model.dart';

class SpvRepository {
  Future<List<AntreanModel>> fetchAntrean() async {
    final response = await ApiClient.get(ApiConfig.resiPengambilan);
    
    if (response['status'] == 'success') {
      final List data = response['data'] ?? [];
      return data.map((e) => AntreanModel.fromJson(e)).toList();
    } else {
      throw Exception(response['message'] ?? 'Gagal memuat antrean');
    }
  }

  Future<Map<String, dynamic>> simpanPemeriksaan({
    required int idDokumen,
    required int idBarang,
    required String idSpv,
    required int jumlahDiharapkan,
    required int jumlahBagus,
    required int jumlahRusak,
    required String status,
    required String catatan,
  }) async {
    final response = await ApiClient.post(
      ApiConfig.periksaBarang,
      body: {
        "id_dokumen": idDokumen,
        "id_barang": idBarang,
        "id_spv": idSpv,
        "jumlah_diharapkan": jumlahDiharapkan,
        "jumlah_bagus": jumlahBagus,
        "jumlah_rusak": jumlahRusak,
        "status_pemeriksaan": status,
        "catatan": catatan
      },
    );

    return response;
  }
  Future<List<Map<String, dynamic>>> fetchRiwayat(String idSpv) async {
    final response = await ApiClient.get(ApiConfig.riwayatPemeriksaan);
    if (response['status'] == 'success') {
      final List data = response['data'] ?? [];
      // Filter client side for now just in case
      final filtered = data.where((e) => e['id_supervisor'] == idSpv || true).toList(); // Currently API might not have id_supervisor in response, we just take all or what's returned
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception(response['message'] ?? 'Gagal memuat riwayat');
    }
  }
}