class UserModel {
  final String idUser;
  final String namaLengkap;
  final String role;

  UserModel({
    required this.idUser,
    required this.namaLengkap,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['id_user']?.toString() ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
