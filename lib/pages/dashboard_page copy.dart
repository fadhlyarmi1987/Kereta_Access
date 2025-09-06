// import 'package:flutter/material.dart';
// import '../models/train.model.dart';
// import '../services/TrainService.dart';

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("🚆 Data Trains"),
//         backgroundColor: Colors.blue,
//       ),
//       body: FutureBuilder<List<Train>>(
//         future: TrainService.getTrains(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//           final trains = snapshot.data ?? [];
//           if (trains.isEmpty) {
//             return const Center(child: Text("Tidak ada data kereta"));
//           }

//           return ListView.builder(
//             itemCount: trains.length,
//             itemBuilder: (context, index) {
//               final train = trains[index];
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 child: ListTile(
//                   leading: const Icon(Icons.train),
//                   title: Text("${train.name}"),
//                   subtitle: Text(
//                       "Kelas: ${train.serviceClass} | Gerbong: ${train.carriageCount}"),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
