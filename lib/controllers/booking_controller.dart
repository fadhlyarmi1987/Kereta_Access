import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constant/api_constant.dart';

// ✅ Booking Controller
class BookingController extends GetxController {
  // ✅ 1. Buat booking dengan status PENDING (dipanggil di PilihSeatsPage)
  Future<Map<String, dynamic>?> createPendingBooking({
    required int tripId,
    required String departureDate,
    required int seatId,
    required Map<String, dynamic> penumpang,
  }) async {
    try {
      final url = ApiConstant.booking; // ✅ panggil dari ApiConstant
      final Map<String, dynamic> data = {
        'user_id': 1,
        'trip_id': tripId,
        'departure_date': departureDate,
        'status': 'PENDING',
        'seat_id': seatId,
        'passengers': [penumpang],
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      final resBody = json.decode(response.body);
      print("🔍 API Response: $resBody");

      if (response.statusCode == 201 || response.statusCode == 200) {
        // fleksibel: cek ada `booking` atau `data`
        if (resBody['booking'] != null) {
          return Map<String, dynamic>.from(resBody['booking']);
        } else if (resBody['data'] != null) {
          return Map<String, dynamic>.from(resBody['data']);
        } else {
          return Map<String, dynamic>.from(resBody);
        }
      } else {
        Get.snackbar(
          "Error",
          "Gagal membuat booking: ${resBody['message'] ?? response.body}",
        );
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
      return null;
    }
  }

  // ✅ 2. Update status booking (dipanggil di DetailPenumpangPage)
  Future<void> updateBookingStatusByUser(int userId, int tripId, String status) async {
    try {
      final url = "${ApiConstant.baseUrl}/bookings/user/$userId/status"; // ✅ pakai baseUrl

      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "status": status,
          "trip_id": tripId,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Booking dikonfirmasi!");
      } else {
        final resBody = json.decode(response.body);
        Get.snackbar(
          "Error",
          "Gagal update status booking: ${resBody['message'] ?? response.body}",
        );
        print(response.body);
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    }
  }
}
