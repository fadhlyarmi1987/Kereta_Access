import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/booking_controller.dart';
import '../../../routes/route.dart';

class DetailPenumpangPage extends StatefulWidget {
  const DetailPenumpangPage({super.key});

  @override
  State<DetailPenumpangPage> createState() => _DetailPenumpangPageState();
}

class _DetailPenumpangPageState extends State<DetailPenumpangPage> {
  String? nama;
  String? nik;
  String? jenisKelamin;
  String? tanggalLahir;

  String? seatUtama;
  String? carriageUtama;
  int? seatId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nama = prefs.getString("name") ?? "-";
      nik = prefs.getString("nik") ?? "-";
      jenisKelamin = prefs.getString("jenis_kelamin") ?? "-";
      tanggalLahir = prefs.getString("tanggal_lahir") ?? "-";
    });
  }

  Future<void> _konfirmasiData(
    BuildContext context,
    Map<String, dynamic> penumpang, {
    bool tambahan = false,
    int? index,
  }) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              "Konfirmasi Data",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    penumpang['nama']?.isNotEmpty == true
                        ? penumpang['nama']!
                        : "-",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.badge, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    penumpang['nik']?.isNotEmpty == true
                        ? penumpang['nik']!
                        : "-",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text("Batal"),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text("Sesuai"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final args = Get.arguments;
      final result = await Get.toNamed(
        AppRoutes.pilihseats,
        arguments: {
          "nama": penumpang['nama'],
          "nik": penumpang['nik'],
          "trainId": args["trainId"],
        },
      );

      if (result != null && result is Map) {
        setState(() {
          seatUtama = result['seat'];
          carriageUtama = result['carriage'];
          seatId = result['seat_id']; // Menyimpan ID kursi
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Penumpang"),
        backgroundColor: Colors.blueAccent,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Trip
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.train, color: Colors.blue, size: 32),
                title: Text(
                  args["trainName"] ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  "${args['originStation']} → ${args['destinationStation']}\n"
                  "Berangkat: ${args['departureTime']} | "
                  "Tiba: ${args['arrivalTime']}",
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              "Penumpang",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // Penumpang utama
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  nama ?? "-",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "NIK: $nik\n"
                  "Jenis Kelamin: $jenisKelamin\n"
                  "Tanggal Lahir: $tanggalLahir\n"
                  "Gerbong: ${carriageUtama ?? '-'} | Kursi: ${seatUtama ?? '-'} | ID Kursi: ${seatId ?? '-'}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.event_seat, color: Colors.blue),
                  onPressed: () {
                    _konfirmasiData(context, {
                      "nama": nama ?? "",
                      "nik": nik ?? "",
                    }, tambahan: false);
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                "Booking",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: () {
                final bookingCtrl = Get.put(BookingController());
                final rawDate = Get.arguments["departureDate"];

                if (rawDate == null || rawDate.toString().isEmpty) {
                  Get.snackbar("Error", "Tanggal keberangkatan tidak tersedia");
                  return;
                }

                final formattedDate = DateFormat(
                  'yyyy-MM-dd',
                ).format(DateTime.parse(rawDate.toString()));
                bookingCtrl.createBooking(
                  context,
                  tripId: int.parse(Get.arguments["tripId"].toString()),
                  departureDate: formattedDate,
                  penumpangUtama: {
                    "name": nama ?? "-",
                    "nik": nik ?? "-",
                    "jenis_kelamin": jenisKelamin ?? "-",
                    "tanggal_lahir": tanggalLahir ?? "-",
                    "seat_id": seatId ?? "-",
                  },
                  tambahan: [], // Daftar penumpang tambahan bisa ditambahkan jika ada
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
