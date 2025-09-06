import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class RegisterPage extends StatelessWidget {
  final AuthController authC = Get.put(AuthController());

  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final telpC = TextEditingController();
  final nikC = TextEditingController();
  final kelaminC = "".obs;
  final tglLahirC = "".obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: nameC,
              decoration: InputDecoration(labelText: "Nama Lengkap"),
            ),
            TextField(
              controller: emailC,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passC,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: telpC,
              decoration: InputDecoration(labelText: "No. Telepon"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: nikC,
              decoration: InputDecoration(labelText: "NIK"),
              keyboardType: TextInputType.number,
            ),
            // 🔹 Dropdown Jenis Kelamin
            Obx(() {
              return DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Jenis Kelamin"),
                value: kelaminC.value.isEmpty
                    ? null
                    : kelaminC.value,
                items: ["Laki-laki", "Perempuan"]
                    .map(
                      (gender) =>
                          DropdownMenuItem(value: gender, child: Text(gender)),
                    )
                    .toList(),
                onChanged: (value) {
                  kelaminC.value = value ?? "";
                },
              );
            }),

            SizedBox(height: 10),

            // 🔹 DatePicker untuk Tanggal Lahir
            Obx(() {
              return TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Tanggal Lahir",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(text: tglLahirC.value),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    tglLahirC.value =
                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                  }
                },
              );
            }),
            SizedBox(height: 20),
            Obx(() {
              return authC.isLoading.value
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        authC.register(
                          nameC.text,
                          emailC.text,
                          passC.text,
                          telpC.text,
                          nikC.text,
                          kelaminC.value,
                          tglLahirC.value,
                        );
                      },
                      child: Text("Register"),
                    );
            }),
          ],
        ),
      ),
    );
  }
}
