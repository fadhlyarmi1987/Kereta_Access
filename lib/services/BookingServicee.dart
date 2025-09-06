import 'package:dio/dio.dart';

class BookingService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8000/api"));

  Future<void> createBooking({
    required String token,
    required int tripId,
    required List<int> seats,
    required List<Map<String, String>> passengers,
  }) async {
    try {
      final response = await _dio.post(
        "/bookings",
        data: {
          "trip_id": tripId,
          "seats": seats,
          "passengers": passengers,
        },
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      print("Booking sukses: ${response.data}");
    } on DioException catch (e) {
      print("Booking gagal: ${e.response?.data}");
    }
  }
}
