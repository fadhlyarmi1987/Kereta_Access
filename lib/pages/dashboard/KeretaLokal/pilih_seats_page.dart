import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constant/api_constant.dart';

class PilihSeatsPage extends StatefulWidget {
  const PilihSeatsPage({super.key});

  @override
  _PilihSeatsPageState createState() => _PilihSeatsPageState();
}

class _PilihSeatsPageState extends State<PilihSeatsPage> {
  String? selectedSeatLabel;
  int? selectedSeatId;
  bool isLoading = true;
  List<dynamic> carriages = [];
  int selectedCarriageIndex = 0;

  @override
  void initState() {
    super.initState();
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

  Future<int?> createBookingPending({
    required int tripId,
    required String departureDate,
    required Map<String, dynamic> penumpangUtama,
    required List<Map<String, dynamic>> tambahan,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("id") ?? 0;
      final Map<String, dynamic> data = {
        'user_id': userId,
        'trip_id': tripId,
        'departure_date': departureDate,
        'status': 'pending',
        'seat_id': penumpangUtama['seat_id'],
        'passengers': [
          {
            'name': penumpangUtama['name'],
            'nik': penumpangUtama['nik'],
            'jenis_kelamin': penumpangUtama['jenis_kelamin'],
            'tanggal_lahir': penumpangUtama['tanggal_lahir'],
            'seat_id': penumpangUtama['seat_id'],
          },
          ...tambahan,
        ],
      };

      // ✅ Perbaikan: gunakan ApiConstant.baseUrl agar konsisten
      final response = await http.post(
        Uri.parse('${ApiConstant.baseUrl}/pesan'), // << perbaikan
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final resBody = json.decode(response.body);
        Get.snackbar("Sukses", "Pilih Kursi Telah Berhasil", backgroundColor: Colors.green);
        final bookingId = resBody['data']?['id'];
        return bookingId;
      } else {
        final resBody = json.decode(response.body);
        Get.snackbar(
          "Error",
          "Gagal membuat booking: ${resBody['message'] ?? response.body}",
        );
        print(response.body);
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
      print(e);
    }
    return null;
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

  List<String> _getSeatColumnsForRow() {
    return ['A', 'B', 'C', 'aisle', 'D', 'E'];
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String nama = args?["nama"] ?? "Nama tidak ditemukan";
    final String nik = args?["nik"] ?? "NIK tidak ditemukan";
    final int tripId = int.tryParse(args?["tripId"].toString() ?? "0") ?? 0;
    final String departureDate = args?["departureDate"]?.toString() ?? "-";
    final String tanggalLahir = args?["tanggal_lahir"]?.toString() ?? "-";
    final String jenisKelamin = args["jenis_kelamin"]?.toString() ?? "-";

    final Map<String, dynamic> penumpangUtama = {
      "name": nama,
      "nik": nik,
      "jenis_kelamin": jenisKelamin,
      "tanggal_lahir": tanggalLahir,
      "seat_id": selectedSeatId,
    }; // << perbaikan
    final List<Map<String, dynamic>> tambahan =
        []; // << perbaikan (sementara kosong)

    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Kursi")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                            "$nama",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "NIK: $nik",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Trip ID: $tripId",
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            "Tanggal Keberangkatan: $departureDate",
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            "Tanggal Lahir: $jenisKelamin",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
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
                  Expanded(
                    child: carriages.isEmpty
                        ? const Center(child: Text("Tidak ada data gerbong."))
                        : _buildSeatLayout(carriages[selectedCarriageIndex]),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 70),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedSeatLabel != null
              ? Colors.blue
              : Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: selectedSeatLabel != null
            ? () async {
                final carriage = carriages[selectedCarriageIndex];
                final carriageName = carriage['class'] ?? 'Gerbong';
                final carriageNumber = selectedCarriageIndex + 1;
                final carriageLabel = "$carriageName $carriageNumber";

                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      "Konfirmasi Kursi",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      "Anda memilih kursi:\n\n"
                      "Gerbong: $carriageLabel\n"
                      "Kursi: $selectedSeatLabel",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Batal"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  // ✅ Perbaikan: panggil createBookingPending dengan data dari arguments
                  if (selectedSeatId == null) {
                    Get.snackbar("Error", "Harap pilih kursi terlebih dahulu");
                    return;
                  }
                  final bookingId = await createBookingPending(
                    tripId: tripId,
                    departureDate: departureDate,
                    penumpangUtama: penumpangUtama,
                    tambahan: tambahan,
                  );

                  if (bookingId != null) {
                    Get.back(
                      result: {
                        "seat_id": selectedSeatId,
                        "seat": selectedSeatLabel,
                        "carriage": carriageLabel,
                      },
                    );
                  }
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
    final isAvailable = seat['status'] != 'booked';

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
