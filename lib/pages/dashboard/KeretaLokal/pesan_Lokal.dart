import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/station/stations_controller.dart';
import '../../../routes/route.dart';

class PesanTiketPage extends StatefulWidget {
  const PesanTiketPage({super.key});

  @override
  State<PesanTiketPage> createState() => _PesanTiketPageState();
}

class _PesanTiketPageState extends State<PesanTiketPage> {
  final StationController stationController = Get.put(StationController());

  Map<String, dynamic>? selectedAsal;
  Map<String, dynamic>? selectedTujuan;
  DateTime? selectedDate;

  String? namaUser;
  String? emailUser;
  String? nikUser;
  String? noTelpUser;
  String? tanggalLahirUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      namaUser = prefs.getString("name") ?? "Guest";
      emailUser = prefs.getString("email") ?? "";
      nikUser = prefs.getString("nik") ?? "";
      noTelpUser = prefs.getString("no_telp") ?? "";
      tanggalLahirUser = prefs.getString("tanggal_lahir") ?? "";
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectStation(String type) async {
    final result = await Get.toNamed(AppRoutes.pilihstasiun);
    if (result != null) {
      setState(() {
        if (type == "Asal") {
          selectedAsal = result;
        } else {
          selectedTujuan = result;
        }
      });
    }
  }

  Widget _buildStationSelector({
    required String label,
    required String hint,
    required IconData icon,
    required Map<String, dynamic>? selectedStation,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.blueAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedStation == null
                      ? hint
                      : "${selectedStation['name']} (${selectedStation['code']})",
                  style: TextStyle(
                    fontSize: 15,
                    color: selectedStation == null ? Colors.grey : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesan Tiket Lokal"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Asal & Tujuan (side by side)
            Row(
              children: [
                _buildStationSelector(
                  label: "Stasiun Asal",
                  hint: "Pilih Asal",
                  icon: Icons.train,
                  selectedStation: selectedAsal,
                  onTap: () => _selectStation("Asal"),
                ),
                const SizedBox(width: 12),
                _buildStationSelector(
                  label: "Stasiun Tujuan",
                  hint: "Pilih Tujuan",
                  icon: Icons.flag,
                  selectedStation: selectedTujuan,
                  onTap: () => _selectStation("Tujuan"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tanggal keberangkatan
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blueAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedDate == null
                            ? "Pilih Tanggal Keberangkatan"
                            : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                        style: TextStyle(
                          fontSize: 15,
                          color: selectedDate == null ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Data pengguna
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
                title: Text(
                  namaUser ?? "Guest",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${emailUser ?? ''}", style: const TextStyle(fontSize: 13)),
                      Text("NIK: $nikUser", style: const TextStyle(fontSize: 13)),
                      Text("No Telp: $noTelpUser", style: const TextStyle(fontSize: 13)),
                      Text("Tanggal Lahir: $tanggalLahirUser", style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Pesan
            ElevatedButton.icon(
              onPressed: () {
                if (selectedAsal == null ||
                    selectedTujuan == null ||
                    selectedDate == null) {
                  Get.snackbar("Error", "Lengkapi semua data terlebih dahulu");
                  return;
                }

                Get.toNamed(
                  AppRoutes.hasilpencarianLokal,
                  arguments: {
                    "originId": selectedAsal!['id'],
                    "destinationId": selectedTujuan!['id'],
                    "departureDate": selectedDate!.toIso8601String().split("T")[0],
                    "originName": selectedAsal!['name'],
                    "destinationName": selectedTujuan!['name'],
                    "originCode": selectedAsal!['code'],
                    "destinationCode": selectedTujuan!['code'],
                  },
                );
              },
              icon: const Icon(Icons.search),
              label: const Text("Cari Tiket"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
