import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  List<Map<String, dynamic>> penumpangTambahan = [];

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
          if (!tambahan) {
            seatUtama = result['seat'];
            carriageUtama = result['carriage'];
          } else if (index != null) {
            penumpangTambahan[index]["seat"] = result['seat'];
            penumpangTambahan[index]["carriage"] = result['carriage'];
          }
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
                  "Gerbong: ${carriageUtama ?? '-'} | Kursi: ${seatUtama ?? '-'}",
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
            Expanded(
              child: ListView(
                children: [
                  ...penumpangTambahan.asMap().entries.map((entry) {
                    final index = entry.key;
                    final p = entry.value;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Penumpang
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.blueAccent,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Penumpang Tambahan ${index + 1}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20, thickness: 1),

                            // Nama
                            TextField(
                              controller: p["nama"],
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_outline),
                                labelText: "Nama Lengkap",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // NIK
                            TextField(
                              controller: p["nik"],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.badge_outlined),
                                labelText: "NIK",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // No Telp
                            TextField(
                              controller: p["no_telp"],
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.phone),
                                labelText: "No. Telp",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Info Gerbong & Kursi
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.train,
                                    color: Colors.blueAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Gerbong: ${p['carriage'] ?? '-'} | Kursi: ${p['seat'] ?? '-'}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Tombol Aksi
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      penumpangTambahan.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    "Hapus",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.event_seat,
                                    color: Colors.white,
                                  ),
                                  label: const Text("Pilih Kursi"),
                                  onPressed: () {
                                    _konfirmasiData(
                                      context,
                                      {
                                        "nama": p["nama"]!.text,
                                        "nik": p["nik"]!.text,
                                      },
                                      tambahan: true,
                                      index: index,
                                    );
                                  },
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
          ],
        ),
      ),
    );
  }
}
