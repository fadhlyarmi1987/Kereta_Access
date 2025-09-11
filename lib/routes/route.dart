import 'package:get/get.dart';
import 'package:kereta_access/pages/dashboard/KeretaAntarKota/hasil_pencarian_AK_page.dart';
import 'package:kereta_access/pages/dashboard/KeretaAntarKota/pesan_Antar_Kota.dart';
import 'package:kereta_access/pages/dashboard/KeretaAntarKota/pilih_seats_AK_page.dart';
import 'package:kereta_access/pages/dashboard/Konstant/detail_penumpang_page.dart';
import 'package:kereta_access/pages/dashboard/KeretaLokal/hasil_pencarian_page.dart';
import 'package:kereta_access/pages/dashboard/KeretaLokal/pilih_seats_lokal_page.dart';
import 'package:kereta_access/pages/dashboard/Konstant/pilih_stasiun_page.dart';
import 'package:kereta_access/pages/dashboard/bottom_navbar.dart';
import 'package:kereta_access/pages/dashboard/KeretaLokal/pesan_Lokal.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const lokal = '/lokal';
  static const pesanLokal = '/pesanlokal';
  static const pesanAnKot = '/pesanankot';
  static const hasilpencarianLokal = '/hasilpencarianLokal';
  static const hasilpencarianAKpage = '/hasilpencarianAK';
  static const pilihseatslokal = '/pilihseatslokal';
  static const pilihseatsantarkota = '/pilihseatsantarkota';
  static const detailpenumpang = '/detailpenumpang';
  static const pilihstasiun = '/pilihstasiun';

  static final routes = [
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: register, page: () => RegisterPage()),
    GetPage(name: dashboard, page: () => DashboardPage()),
    //GetPage(name: lokal, page: () => KeretaLokalPage()),
    GetPage(name: pesanLokal, page: () => PesanTiketPage()),
    GetPage(name: pesanAnKot, page: () => PesanTiketAntarKotaPage()),
    GetPage(name: pilihseatslokal, page: () => PilihSeatsPage()),
    GetPage(name: pilihseatsantarkota, page: () => PilihSeatsAntarKotaPage()),
    GetPage(name: detailpenumpang, page: () => DetailPenumpangPage()),
    GetPage(
      name: hasilpencarianLokal,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return HasilPencarianPage(
          originId: args["originId"],
          destinationId: args["destinationId"],
          departureDate: args["departureDate"],
          originName: args["originName"],
          destinationName: args["destinationName"],
        );
      },
    ),
    GetPage(
      name: hasilpencarianAKpage,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return HasilPencarianAKPage(
          originId: args["originId"],
          destinationId: args["destinationId"],
          departureDate: args["departureDate"],
          originName: args["originName"],
          destinationName: args["destinationName"],
        );
      },
    ),

    GetPage(
      name: pilihstasiun,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?; // Safe cast
        if (args == null || args.isEmpty) {
          // Handle missing arguments, maybe use default values or show an error
          print("Missing or invalid arguments");
          return PilihStasiunPage(
            type: "default_type", // Default type jika tidak ada argumen
          );
        }

        // Return PilihStasiunPage dengan mengirimkan selectedStasiunId dan type
        return PilihStasiunPage(
          selectedStasiunId:
              args["selectedStasiunId"], // Pastikan key ini ada di args
          type: args["type"], // Kirim type yang sesuai (Asal/Tujuan)
        );
      },
    ),
  ];
}
