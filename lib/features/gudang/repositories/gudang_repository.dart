import '../../../core/network/api_client.dart';
import '../../../core/config/api_config.dart';
import '../models/gudang_model.dart';

class GudangRepository {
  Future<List<GudangModel>> fetchTugas() async {
    final response = await ApiClient.get(ApiConfig.tugasGudang);
    
    if (response['status'] == 'success') {
      final List data = response['data'] ?? [];
      return data.map((e) => GudangModel.fromJson(e)).toList();
    } else {
      throw Exception(response['message'] ?? 'Gagal memuat tugas packing');
    }
  }

  Future<Map<String, dynamic>> selesaikanPacking(String idDokumen, String idKaryawan) async {
    final response = await ApiClient.post(
      ApiConfig.selesaiPacking,
      body: {
        "id_dokumen": idDokumen,
        "id_karyawan": idKaryawan,
      },
    );

    return response;
  }
}
