import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:kereta_access/constant/api_constant.dart';

class StationController extends GetxController {
  var stations = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStations();
  }

  Future<void> fetchStations() async {
  try {
    isLoading.value = true;
    final response = await Dio().get(ApiConstant.stations);
    
    // Log respons dari API
    print('API Response: ${response.data}');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data["data"];
      print('Data Stations: $data'); // Log data yang diterima
      stations.value = data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      print('Error: ${response.statusCode}');
      stations.clear();
    }
  } catch (e) {
    print("Error fetch stations: $e");
    stations.clear();
  } finally {
    isLoading.value = false;
  }
}

}
