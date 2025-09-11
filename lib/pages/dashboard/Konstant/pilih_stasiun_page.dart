import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/station/stations_controller.dart';

class PilihStasiunPage extends StatefulWidget {
  final String? selectedStasiunId; // ID stasiun yang dipilih
  final String type; // asal atau tujuan

  const PilihStasiunPage({
    Key? key,
    this.selectedStasiunId,
    required this.type,
  }) : super(key: key);

  @override
  State<PilihStasiunPage> createState() => _PilihStasiunPageState();
}

class _PilihStasiunPageState extends State<PilihStasiunPage> {
  final StationController stationController = Get.find();
  final TextEditingController searchC = TextEditingController();

  var filteredStations = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    // Default tampil semua stasiun
    filteredStations.assignAll(stationController.stations);

    searchC.addListener(() {
      filterStations(searchC.text);
    });
  }

  void filterStations(String query) {
    if (query.isEmpty) {
      filteredStations.assignAll(stationController.stations);
    } else {
      filteredStations.assignAll(
        stationController.stations.where((station) {
          final name = (station['name'] ?? "").toString().toLowerCase();
          final code = (station['code'] ?? "").toString().toLowerCase();
          return name.contains(query.toLowerCase()) ||
              code.contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pilih Stasiun ${widget.type}"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input Pencarian
            TextField(
              controller: searchC,
              decoration: InputDecoration(
                hintText: "Cari nama atau kode stasiun...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Daftar Stasiun
            Expanded(
              child: Obx(() {
                if (stationController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (filteredStations.isEmpty) {
                  return const Center(
                    child: Text(
                      "Stasiun tidak ditemukan",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredStations.length,
                  itemBuilder: (context, index) {
                    final station = filteredStations[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.train, color: Colors.blue),
                        title: Text(
                          "${station['name']} (${station['code']})",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          Get.back(
                            result: {
                              "id": station['id'].toString(),
                              "name": station['name'],
                              "code": station['code'],
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
