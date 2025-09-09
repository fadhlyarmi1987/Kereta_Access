import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/booking_controller.dart';
import 'routes/route.dart';

void main() {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  // Daftarkan controller sekali di awal
  Get.put(BookingController());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token != null && token.isNotEmpty) {
      return AppRoutes.dashboard; // kalau ada token masuk dashboard
    } else {
      return AppRoutes.login; // kalau tidak ada token masuk login
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: snapshot.data, // pilih sesuai kondisi
          getPages: AppRoutes.routes,
        );
      },
    );
  }
}
