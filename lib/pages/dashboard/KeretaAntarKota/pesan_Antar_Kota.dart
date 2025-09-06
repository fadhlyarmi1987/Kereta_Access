import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controllers/station/stations_controller.dart';


class PesanTiketAntarKotaPage extends StatefulWidget {
  const PesanTiketAntarKotaPage({super.key});

  @override
  State<PesanTiketAntarKotaPage> createState() => _PesanTiketAntarKotaPageState();
}

class _PesanTiketAntarKotaPageState extends State<PesanTiketAntarKotaPage> {
  final StationController stationController = Get.put(StationController());

  String? selectedAsal;
  String? selectedTujuan;
  DateTime? selectedDate;
  String? namaUser;
  String? emailUser;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pesan Tiket Antar Kota")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (stationController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              // Dropdown Stasiun Asal
              DropdownButtonFormField<String>(
                value: selectedAsal,
                decoration: const InputDecoration(
                  labelText: "Stasiun Asal",
                  border: OutlineInputBorder(),
                ),
                items: stationController.stations
                    .map((station) => DropdownMenuItem<String>(
                          value: station["id"].toString(),
                          child: Text(station["name"]),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedAsal = value);
                },
              ),
              const SizedBox(height: 16),
              // Dropdown Stasiun Tujuan
              DropdownButtonFormField<String>(
                value: selectedTujuan,
                decoration: const InputDecoration(
                  labelText: "Stasiun Tujuan",
                  border: OutlineInputBorder(),
                ),
                items: stationController.stations
                    .map((station) => DropdownMenuItem<String>(
                          value: station["id"].toString(),
                          child: Text(station["name"]),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedTujuan = value);
                },
              ),
              const SizedBox(height: 16),
              // Tanggal
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Tanggal Berangkat",
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    selectedDate == null
                        ? "Pilih tanggal"
                        : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Data Penumpang
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(namaUser ?? ""),
                  subtitle: Text(emailUser ?? ""),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (selectedAsal == null ||
                      selectedTujuan == null ||
                      selectedDate == null) {
                    Get.snackbar("Error", "Lengkapi semua data terlebih dahulu");
                    return;
                  }
                  print("Pesan tiket antar kota: "
                      "Asal=$selectedAsal, Tujuan=$selectedTujuan, "
                      "Tanggal=$selectedDate, User=$namaUser");
                },
                icon: const Icon(Icons.confirmation_num),
                label: const Text("Pesan Tiket"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
