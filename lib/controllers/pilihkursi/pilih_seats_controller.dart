import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constant/api_constant.dart';

class PilihSeatsController extends GetxController {
  var isLoading = true.obs;
  var carriages = <dynamic>[].obs;
  var selectedCarriageIndex = 0.obs;
  var selectedSeatLabel = RxnString();
  var selectedSeatId = RxnInt();

  /// Ambil data kursi berdasarkan trainId
  Future<void> fetchSeats(int trainId) async {
    final url = ApiConstant.seats(trainId);

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          carriages.assignAll(data['data'] ?? []);
        } else {
          Get.snackbar('Error', data['message'] ?? 'Gagal memuat kursi');
        }
      } else {
        Get.snackbar('Error', 'Kode Status: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pilih kursi
  void selectSeat(String label, int id, int carriageIndex) {
    selectedCarriageIndex.value = carriageIndex;
    selectedSeatLabel.value = label;
    selectedSeatId.value = id;
  }

  /// Buat booking pending
  Future<bool> createBookingPending({
    required int tripId,
    required String departureDate,
    required Map<String, dynamic> penumpangUtama,
    required List<Map<String, dynamic>> tambahan,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("id") ?? 0;
      final Map<String, dynamic> data = {
        'user_id': userId,
        'trip_id': tripId,
        'departure_date': departureDate,
        'status': 'pending',
        'seat_id': penumpangUtama['seat_id'],
        'passengers': [
          {
            'name': penumpangUtama['name'],
            'nik': penumpangUtama['nik'],
            'jenis_kelamin': penumpangUtama['jenis_kelamin'],
            'tanggal_lahir': penumpangUtama['tanggal_lahir'],
            'seat_id': penumpangUtama['seat_id'],
          },
          ...tambahan,
        ],
      };

      final response = await http.post(
        Uri.parse('${ApiConstant.baseUrl}/pesan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final resBody = json.decode(response.body);
        Get.snackbar("Sukses", resBody['message'] ?? "Pilih Kursi Berhasil",
            backgroundColor: Colors.green);

        return true;
      } else {
        final resBody = json.decode(response.body);
        Get.snackbar("Error", "Gagal booking: ${resBody['message'] ?? '-'}");
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    }
    return false;
  }
}
