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
  int? bookingId;
  String? seatUtama;
  String? carriageUtama;
  int? seatId;

  List<Map<String, dynamic>> penumpangTambahan = [];
  late final Map<String, dynamic> args; // ✅ simpan sekali

  @override
  void initState() {
    super.initState();
    args = Get.arguments ?? {}; // simpan args dari GetX
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

  void _tambahPenumpangCard() {
    if (penumpangTambahan.length >= 3) {
      Get.snackbar("Batas Tercapai", "Maksimal 3 penumpang tambahan");
      return;
    }
    setState(() {
      penumpangTambahan.add({
        "nama": TextEditingController(),
        "nik": TextEditingController(),
        "no_telp": TextEditingController(),
        "jenis_kelamin": "Laki-laki",
        "tanggal_lahir": TextEditingController(),
        "seat": null,
        "carriage": null,
      });
    });
  }

  @override
  void dispose() {
    for (var p in penumpangTambahan) {
      (p["nama"] as TextEditingController).dispose();
      (p["nik"] as TextEditingController).dispose();
      (p["no_telp"] as TextEditingController).dispose();
    }
    super.dispose();
  }

  Future<void> _konfirmasiData(
    BuildContext context,
    Map<String, dynamic> penumpang, {
    bool tambahan = false,
    int? index,
  }) async {
    final isTambahan = tambahan;
    final namaPenumpang = isTambahan ? penumpang['nama'] : nama;
    final nikPenumpang = isTambahan ? penumpang['nik'] : nik;
    final tglLahirPenumpang =
        isTambahan ? penumpang['tanggal_lahir'] : tanggalLahir;
    final jkPenumpang =
        isTambahan ? penumpang['jenis_kelamin'] : jenisKelamin;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text("Konfirmasi Data",
                style: TextStyle(fontWeight: FontWeight.bold)),
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
                Expanded(child: Text(namaPenumpang?.toString() ?? "-")),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.badge, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(nikPenumpang?.toString() ?? "-")),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Tanggal Lahir: ${tglLahirPenumpang?.toString() ?? '-'}",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Jenis Kelamin: ${jkPenumpang?.toString() ?? '-'}",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.train, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text("Trip ID: ${penumpang['trip_id'] ?? '-'}"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Tanggal Keberangkatan: ${penumpang['departure_date'] ?? '-'}",
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Batal", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Sesuai"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await Get.toNamed(
        AppRoutes.pilihseats,
        arguments: {
          "nama": namaPenumpang,
          "nik": nikPenumpang,
          "tanggal_lahir": tglLahirPenumpang,
          "jenis_kelamin": jkPenumpang,
          "trainId": args["trainId"],
          "tripId": args["tripId"],
          "departureDate": args["departureDate"],
          "takenSeats": [
            if (seatUtama != null) seatUtama,
            ...penumpangTambahan
                .where((p) => p["seat"] != null)
                .map((p) => p["seat"]),
          ],
        },
      );

      print("🎯 Result diterima di DetailPenumpangPage: $result");

      if (result != null && result is Map) {
        setState(() {
          if (isTambahan && index != null) {
            penumpangTambahan[index]["seat"] = result['seat'];
            penumpangTambahan[index]["carriage"] = result['carriage'];
            penumpangTambahan[index]["seat_id"] = result['seat_id'];
          } else {
            seatUtama = result['seat'];
            carriageUtama = result['carriage'];
            seatId = result['seat_id'];
            bookingId = result['booking_id'];
          }
        });

        Get.snackbar(
          "Sukses",
          "Kursi ${result['seat']} berhasil dipilih",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Penumpang"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.train, color: Colors.blue),
                    title: Text(args["trainName"] ?? ""),
                    subtitle: Text(
                      "${args['originStation']} → ${args['destinationStation']}\n"
                      "Berangkat: ${args['departureTime']} | "
                      "Tiba: ${args['arrivalTime']}",
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Penumpang Utama",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(nama ?? "-"),
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
                          "trip_id": args["tripId"].toString(),
                          "departure_date": args["departureDate"].toString(),
                          "tanggal_lahir": tanggalLahir ?? "",
                        }, tambahan: false);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...penumpangTambahan.asMap().entries.map((entry) {
                  final index = entry.key;
                  final p = entry.value;
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.blueAccent),
                              const SizedBox(width: 8),
                              Text("Penumpang Tambahan ${index + 1}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(),
                          TextField(
                            controller: p["nama"],
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline),
                              labelText: "Nama Lengkap",
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: p["nik"],
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.badge_outlined),
                              labelText: "NIK",
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.male,
                                  color: Colors.blueAccent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text("Jenis Kelamin",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: RadioListTile<String>(
                                            title: const Text("Laki-laki"),
                                            value: "Laki-laki",
                                            groupValue:
                                                p["jenis_kelamin"],
                                            onChanged: (value) {
                                              setState(() {
                                                p["jenis_kelamin"] =
                                                    value!;
                                              });
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: RadioListTile<String>(
                                            title: const Text("Perempuan"),
                                            value: "Perempuan",
                                            groupValue:
                                                p["jenis_kelamin"],
                                            onChanged: (value) {
                                              setState(() {
                                                p["jenis_kelamin"] =
                                                    value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: p["tanggal_lahir"],
                            readOnly: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.calendar_today),
                              labelText: "Tanggal Lahir",
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  p["tanggal_lahir"].text =
                                      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Gerbong: ${p['carriage'] ?? '-'} | Kursi: ${p['seat'] ?? '-'} | ID Kursi: ${p['seat_id'] ?? '-'}",
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    penumpangTambahan.removeAt(index);
                                  });
                                },
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                label: const Text("Hapus",
                                    style: TextStyle(color: Colors.red)),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _konfirmasiData(
                                    context,
                                    {
                                      "nama": p["nama"].text,
                                      "nik": p["nik"].text,
                                      "trip_id":
                                          args["tripId"].toString(),
                                      "departure_date": args["departureDate"]
                                          .toString(),
                                      "tanggal_lahir":
                                          p["tanggal_lahir"].text,
                                      "jenis_kelamin": p["jenis_kelamin"],
                                    },
                                    tambahan: true,
                                    index: index,
                                  );
                                },
                                icon: const Icon(Icons.event_seat,
                                    color: Colors.white),
                                label: const Text("Pilih Kursi"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: penumpangTambahan.length >= 3
                      ? null
                      : _tambahPenumpangCard,
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah Penumpang"),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text("Booking",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () {
                  final bookingCtrl = Get.put(BookingController());
                  final rawDate = args["departureDate"];

                  if (seatId == null || bookingId == null) {
                    Get.snackbar(
                      "Error",
                      "Anda belum memilih kursi / booking belum dibuat",
                    );
                    return;
                  }
                  if (rawDate == null || rawDate.toString().isEmpty) {
                    Get.snackbar(
                      "Error",
                      "Tanggal keberangkatan tidak tersedia",
                    );
                    return;
                  }

                  final formattedDate =
                      DateFormat('yyyy-MM-dd').format(DateTime.parse(
                    rawDate.toString(),
                  ));

                  final tambahan = penumpangTambahan.map((p) {
                    return {
                      "name": p["nama"].text.isNotEmpty
                          ? p["nama"].text
                          : "-",
                      "nik": p["nik"].text.isNotEmpty
                          ? p["nik"].text
                          : "-",
                      "jenis_kelamin":
                          (p["jenis_kelamin"] == "Laki-laki" ||
                                  p["jenis_kelamin"] == "Perempuan")
                              ? p["jenis_kelamin"]
                              : "Laki-laki",
                      "tanggal_lahir": p["tanggal_lahir"].text.isNotEmpty
                          ? p["tanggal_lahir"].text
                          : formattedDate,
                      "seat_id": p["seat_id"] ?? "-",
                      "trip_id": int.parse(args["tripId"].toString()),
                      "departure_date": formattedDate,
                    };
                  }).toList();

                  bookingCtrl.updateBookingStatusByUser(
  1, // user_id dari SharedPreferences atau token login
  int.parse(args["tripId"].toString()),
  "CONFIRMED",
);

                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
