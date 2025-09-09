import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constant/api_constant.dart';

class BookingController extends GetxController {
  // URL API endpoint untuk booking (sesuaikan base URL kamu)
  final String apiUrl = 'http://10.187.36.139:8000/api/pesan';

  // Fungsi untuk membuat booking
  Future<void> createBooking(
    BuildContext context, {
    required int tripId,
    required String departureDate,
    required Map<String, dynamic> penumpangUtama,
    required List<Map<String, dynamic>> tambahan,
  }) async {
    try {
      // Body data sesuai struktur request Laravel
      final Map<String, dynamic> data = {
        'user_id': 1,  
        'trip_id': tripId,
        'departure_date': departureDate,
        'status': 'PENDING', 
        'seat_id': penumpangUtama['seat_id'], 
        'passengers': [
          {
            'name': penumpangUtama['name'],
            'nik': penumpangUtama['nik'],
            'jenis_kelamin': penumpangUtama['jenis_kelamin'],
            'tanggal_lahir': penumpangUtama['tanggal_lahir'],
            'seat_id': penumpangUtama['seat_id'], // Menggunakan seat_id dari penumpang utama
          },
          // Menambahkan penumpang tambahan
          ...tambahan.map((penumpang) {
            return {
              'name': penumpang['name'],
              'nik': penumpang['nik'],
              'jenis_kelamin': penumpang['jenis_kelamin'],
              'tanggal_lahir': penumpang['tanggal_lahir'],
              'seat_id': penumpang['seat_id'], // Menggunakan seat_id dari penumpang tambahan
            };
          }).toList(),
        ],
      };

      // Kirim request POST ke Laravel
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN', // Ganti dengan token yang valid jika diperlukan
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Booking berhasil
        Get.snackbar("Sukses", "Booking berhasil dibuat!");
      } else {
        // Gagal
        final resBody = json.decode(response.body);
        print(response.body);
        Get.snackbar("Error", "Gagal membuat booking: ${resBody['message'] ?? response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
      print(e);
    }
  }

  Future<void> createBookingPending(
    BuildContext context, {
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
        final bookingId = resBody['data']?['id'];

        Get.snackbar("Sukses", "Pilih Kursi Telah Berhasil",
            backgroundColor: Colors.green);

        // ✅ Navigasi dikontrol dari controller
        Future.delayed(const Duration(seconds: 1), () {
          Get.back(result: {
            "bookingId": bookingId,
            "seat_id": penumpangUtama['seat_id'],
          });
        });
      } else {
        final resBody = json.decode(response.body);
        Get.snackbar("Error",
            "Gagal membuat booking: ${resBody['message'] ?? response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    }
  }
}
