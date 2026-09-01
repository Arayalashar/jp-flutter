class MasterDataModel {
  final List<dynamic> supirList;
  final List<dynamic> barangList;

  MasterDataModel({required this.supirList, required this.barangList});

  factory MasterDataModel.fromJson(Map<String, dynamic> json) {
    return MasterDataModel(
      supirList: json['data_supir'] ?? [],
      barangList: json['data_barang'] ?? [],
    );
  }
}
