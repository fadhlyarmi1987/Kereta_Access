import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.model.dart';
import '../routes/route.dart';
import '../constant/api_constant.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var user = Rxn<UserModel>();
  var token = ''.obs;

  Future<void> register(
    String name,
    String email,
    String password,
    String noTelp,
    String nik,
    String jenisKelamin,
    String tanggalLahir,
  ) async {
    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.register),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'no_telp': noTelp,
          'nik': nik,
          'jenis_kelamin': jenisKelamin,
          'tanggal_lahir': tanggalLahir,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        user.value = UserModel.fromJson(data['user']);
        token.value = data['token'] ?? ""; // kalau backend kirim token
        Get.snackbar("Success", "Register berhasil ✅");
        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.snackbar("Error", data['message'] ?? "Register gagal");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.login),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        user.value = UserModel.fromJson(data['user']);
        token.value = data['token'] ?? "";

        // simpan token ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token.value);
        await prefs.setString("role", user.value?.role ?? "user");
        await prefs.setString("name", user.value?.name ?? "");
        await prefs.setString("email", user.value?.email ?? "");
        await prefs.setString("nik", user.value?.nik ?? "");
        await prefs.setString("no_telp", user.value?.noTelp ?? "");
        await prefs.setString("tanggal_lahir", user.value?.tanggalLahir ?? "");
        await prefs.setString("jenis_kelamin", user.value?.jenisKelamin ?? "");

        Get.snackbar("Success", "Login berhasil ✅");

        // cek role
        if (user.value?.role == "admin") {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      } else {
        Get.snackbar("Error", data['message'] ?? "Login gagal");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
