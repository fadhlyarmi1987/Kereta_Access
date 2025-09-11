import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../constant/api_constant.dart';
import '../../../controllers/booking_controller.dart';

class PilihSeatsPage extends StatefulWidget {
  const PilihSeatsPage({super.key});

  @override
  _PilihSeatsPageState createState() => _PilihSeatsPageState();
}

class _PilihSeatsPageState extends State<PilihSeatsPage> {
  final bookingCtrl = Get.put(() => BookingController());

  String? selectedSeatLabel;
  int? selectedSeatId;
  bool isLoading = true;
  List<dynamic> carriages = [];
  int selectedCarriageIndex = 0;
  List<String> takenSeats = [];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args["takenSeats"] != null) {
      takenSeats = List<String>.from(args["takenSeats"]);
    }
    _fetchSeats();
  }

  Future<void> _fetchSeats() async {
    final args = Get.arguments;
    if (args == null || args["trainId"] == null) {
      setState(() => isLoading = false);
      Get.snackbar('Error', 'trainId tidak ditemukan di arguments');
      return;
    }

    final int trainId = args["trainId"];
    final url = ApiConstant.seats(trainId);

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            carriages = data['data'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          Get.snackbar('Error', data['message'] ?? 'Gagal memuat kursi');
        }
      } else {
        setState(() => isLoading = false);
        Get.snackbar('Error', 'Kode Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    }
  }

  void _selectSeat(String label, int id, int carriageIndex) {
    setState(() {
      selectedCarriageIndex = carriageIndex;
      selectedSeatLabel = label;
      selectedSeatId = id;
    });
  }

  MapEntry<int, String>? _parseSeat(String seatNumber) {
    final reg = RegExp(r'^(\d+)([A-Z]+)$', caseSensitive: false);
    final m = reg.firstMatch(seatNumber.trim());
    if (m == null) return null;
    final row = int.tryParse(m.group(1) ?? '');
    final letter = (m.group(2) ?? '').toUpperCase();
    if (row == null || letter.isEmpty) return null;
    return MapEntry(row, letter);
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String nama = args?["nama"] ?? "Nama tidak ditemukan";
    final String nik = args?["nik"] ?? "NIK tidak ditemukan";

    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Kursi")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header penumpang
                  Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nama Penumpang: $nama",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "NIK: $nik",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pilih gerbong
                  if (carriages.isNotEmpty)
                    SizedBox(
                      height: 42,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: carriages.length,
                        itemBuilder: (context, index) {
                          final carriage = carriages[index];
                          final className = carriage['class'] ?? '';
                          final label = "$className ${index + 1}";
                          final isActive = selectedCarriageIndex == index;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(label),
                              selected: isActive,
                              onSelected: (_) {
                                setState(() {
                                  selectedCarriageIndex = index;
                                  selectedSeatLabel = null;
                                  selectedSeatId = null;
                                });
                              },
                              selectedColor: Colors.blue,
                              labelStyle: TextStyle(
                                color: isActive ? Colors.white : Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 20),
                  const Text(
                    "Pilih Kursi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Kursi
                  Expanded(
                    child: carriages.isEmpty
                        ? const Center(child: Text("Tidak ada data gerbong."))
                        : _buildSeatLayout(carriages[selectedCarriageIndex]),
                  ),

                  const SizedBox(height: 12),

                  // Legend warna
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendBox(color: Colors.blue, label: 'Tersedia'),
                      const SizedBox(width: 16),
                      _legendBox(color: Colors.green, label: 'Terpilih'),
                      const SizedBox(width: 16),
                      _legendBox(color: Colors.grey, label: 'Terisi'),
                    ],
                  ),
                  const SizedBox(height: 70), // space for confirm button
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor:
        selectedSeatLabel != null ? Colors.blue : Colors.grey,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  onPressed: selectedSeatLabel != null
      ? () async {
          final carriage = carriages[selectedCarriageIndex];
          final carriageClass = carriage['class'] ?? 'Gerbong';
          final carriageNumber = selectedCarriageIndex + 1;
          final carriageLabel = "$carriageClass $carriageNumber";

          final args = Get.arguments;
          final bookingCtrl = Get.find<BookingController>();

          // langsung buat booking
          final booking = await bookingCtrl.createPendingBooking(
            tripId: int.tryParse(args["tripId"].toString()) ?? 0,
            departureDate: args["departureDate"].toString(),
            seatId: selectedSeatId ?? 0,
            penumpang: {
              "name": args["nama"],
              "nik": args["nik"],
              "jenis_kelamin": args["jenis_kelamin"],
              "tanggal_lahir": args["tanggal_lahir"],
              "seat_id": selectedSeatId ?? 0,
            },
          );

          if (booking != null) {
            print("✅ Booking sukses: $booking");
            print("📤 Mengirim result balik...");
            Get.back(
              result: {
                "seat": selectedSeatLabel,
                "carriage": carriageLabel,
                "seat_id": selectedSeatId,
                "booking_id": booking["id"],
              },
            );
          } else {
            Get.snackbar("Error", "Booking gagal dibuat");
          }
        }
      : null,
  child: const Text(
    "Konfirmasi",
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
),

    );
  }

  Widget _buildSeatLayout(Map<String, dynamic> carriage) {
    final seatsListRaw = (carriage['seats'] as List<dynamic>?) ?? [];
    final Map<int, Map<String, Map<String, dynamic>>> rowsMap = {};
    for (final s in seatsListRaw) {
      final seat = Map<String, dynamic>.from(s as Map);
      final seatNumber = (seat['seat_number'] ?? '').toString();
      final parsed = _parseSeat(seatNumber);
      if (parsed == null) continue;
      final rowNum = parsed.key;
      final letter = parsed.value;
      rowsMap.putIfAbsent(rowNum, () => {});
      rowsMap[rowNum]![letter] = seat;
    }

    final rowNumbers = rowsMap.keys.toList()..sort();

    return ListView(
      children: rowNumbers.map((rowNum) {
        final letterMap = rowsMap[rowNum] ?? {};
        final allCols = ['A', 'B', 'C', 'D', 'E'];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: allCols.map((col) {
              if (col == 'D') {
                return Row(
                  children: [
                    const SizedBox(width: 24),
                    _buildSeatBox(letterMap[col]),
                  ],
                );
              }
              return _buildSeatBox(letterMap[col]);
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeatBox(Map<String, dynamic>? seat) {
    if (seat == null) {
      return const SizedBox(width: 51, height: 42);
    }

    final seatLabel = seat['seat_number'].toString();
    final seatId = int.tryParse(seat['seat_id'].toString()) ?? 0;
    final isSelected = selectedSeatLabel == seatLabel;

    final isAlreadyTaken = takenSeats.contains(seatLabel);
    final isAvailable = seat['status'] != 'booked' && !isAlreadyTaken;

    return GestureDetector(
      onTap: isAvailable
          ? () => _selectSeat(seatLabel, seatId, selectedCarriageIndex)
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: !isAvailable
              ? Colors.grey
              : (isSelected ? Colors.green : Colors.blue),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          seatLabel,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _legendBox({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
