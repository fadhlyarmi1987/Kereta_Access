import 'package:get/get.dart';
import '../constant/api_constant.dart';

class StationService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = ApiConstant.stations; // contoh: http://10.187.36.139:8000/api
    httpClient.timeout = const Duration(seconds: 15);
    super.onInit();
  }

  // baseUrl sudah mengandung /api, jadi cukup 'stations' saja
  Future<Response> getStations() => get('stations');
}
