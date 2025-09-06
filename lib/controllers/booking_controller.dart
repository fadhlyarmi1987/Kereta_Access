import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        'user_id': 1,  // Pastikan user_id sesuai dengan user yang melakukan booking
        'trip_id': tripId,
        'departure_date': departureDate,
        'status': 'pending', // Status booking, sesuaikan jika perlu
        'seat_id': penumpangUtama['seat_id'], // Menggunakan seat_id dari penumpang utama
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
}
