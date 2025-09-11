import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kereta_access/constant/api_constant.dart';
import '../../../routes/route.dart';

class HasilPencarianAKPage extends StatefulWidget {
  final String originId;
  final String destinationId;
  final String departureDate;
  final String originName;
  final String destinationName;

  const HasilPencarianAKPage({
    super.key,
    required this.originId,
    required this.destinationId,
    required this.departureDate,
    required this.originName,
    required this.destinationName,
  });

  @override
  State<HasilPencarianAKPage> createState() => _HasilPencarianAKPageState();
}

class _HasilPencarianAKPageState extends State<HasilPencarianAKPage> {
  bool isLoading = true;
  List<dynamic> trips = [];

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse(ApiConstant.pencariantrip),
      headers: {"Accept": "application/json"},
      body: {
        "origin_id": widget.originId.toString(),
        "destination_id": widget.destinationId.toString(),
        "departure_date": widget.departureDate,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        trips = data["data"].where((trip) {
          return trip['train']['type'] == "AK";
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal ambil data: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hasil Pencarian"),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Header asal - tujuan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade100, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.originName} → ${widget.destinationName}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Tanggal: ${widget.departureDate}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : trips.isEmpty
                ? const Center(
                    child: Text(
                      "Tidak ada trip ditemukan",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      final tripStations =
                          trip['trip_stations'] as List<dynamic>;

                      final originStation = tripStations.firstWhere(
                        (s) => s['station_id'].toString() == widget.originId,
                        orElse: () => null,
                      );
                      final destinationStation = tripStations.firstWhere(
                        (s) =>
                            s['station_id'].toString() == widget.destinationId,
                        orElse: () => null,
                      );

                      if (originStation == null || destinationStation == null) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            final args = Get.arguments;

                            Get.toNamed(
                              AppRoutes.detailpenumpang,
                              arguments: {
                                "tripId": trip['id'].toString(),
                                "trainName": trip['train']['name'],
                                "trainId": trip["train"]["id"],
                                "type": trip["train"]["type"],
                                "originStation":
                                    originStation['station']['name'],
                                "destinationStation":
                                    destinationStation['station']['name'],
                                "departureTime":
                                    originStation['departure_time'],
                                "arrivalTime":
                                    destinationStation['arrival_time'],
                                "departureDate":
                                    widget.departureDate, 
                                "nama": args["nama"],
                                "nik": args["nik"],
                                "jenis_kelamin": args["jenis_kelamin"],
                                "tanggal_lahir": args["tanggal_lahir"],
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama Kereta
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.train,
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      trip['train']['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Info waktu
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          originStation['station']['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "Berangkat: ${originStation['departure_time'] ?? '-'}",
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.blueAccent,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          destinationStation['station']['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "Tiba: ${destinationStation['arrival_time'] ?? '-'}",
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
