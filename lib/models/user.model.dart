class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String nik;
  final String noTelp;
  final String tanggalLahir;
  final String jenisKelamin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.nik,
    required this.noTelp,
    required this.tanggalLahir,
    required this.jenisKelamin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      nik: json['nik'],
      noTelp: json['no_telp'],
      tanggalLahir: json['tanggal_lahir'],
      jenisKelamin: json['jenis_kelamin'],
      role: json['role'] ?? 'user', // default user kalau null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "nik": nik,
      "no_telp": noTelp,
      "tanggal_lahir": tanggalLahir,
      "role": role,
    };
  }
}
