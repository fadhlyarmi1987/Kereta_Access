import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:kereta_access/constant/api_constant.dart';

class TrainController extends GetxController {
  var isLoading = true.obs;
  var trains = [].obs;

  final Dio _dio = Dio();

  Future<void> fetchTrains() async {
  try {
    isLoading.value = true;

    final response = await Dio().get(
      ApiConstant.trains,
    );

    if (response.statusCode == 200) {
      // response.data langsung List
      final List<dynamic> data = response.data;

      trains.value = data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      trains.clear();
    }
  } catch (e) {
    print("Error fetch trains: $e");
    trains.clear();
  } finally {
    isLoading.value = false;
  }
}


  @override
  void onInit() {
    super.onInit();
    fetchTrains();
  }
}
