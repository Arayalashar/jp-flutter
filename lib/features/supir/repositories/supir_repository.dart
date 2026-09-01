import '../../../core/network/api_client.dart';
import '../../../core/config/api_config.dart';

class SupirRepository {
  Future<List<dynamic>> fetchTugas(String idSupir) async {
    final response = await ApiClient.get('${ApiConfig.tugasSupir}?id_supir=$idSupir');
    
    if (response['status'] == 'success') {
      return response['data'] ?? [];
    } else {
      throw Exception(response['message'] ?? 'Gagal memuat tugas supir');
    }
  }

  Future<Map<String, dynamic>> updateStatus(String idDokumen, String status, String keterangan) async {
    return await ApiClient.post(
      ApiConfig.updateStatus,
      body: {
        "id_dokumen": idDokumen,
        "status": status,
        "keterangan": keterangan,
      },
    );
  }
}
