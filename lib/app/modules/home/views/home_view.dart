import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan judul dan deskripsi
            Container(
              height: 150,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(300),
                ),
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 35),
                  child: Text(
                    'Selamat Datang di Nexus Network Education.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Mentor Favorit
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mentor Favorit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: const Text('Budi Santoso'),
                    subtitle: const Text('Pengalaman di dunia pendidikan'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Fungsi
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: const Text('Rina Wijaya'),
                    subtitle: const Text('Ekspert di bidang teknologi'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Fungsi
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Rekomendasi Program Mentorship
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rekomendasi Program Mentorship',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.school, color: Colors.blue),
                    title: const Text('Mentorship di Pengembangan Karier'),
                    subtitle: const Text('Tingkatkan skill dan cari peluang baru'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Fungsi
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.school, color: Colors.blue),
                    title: const Text('Mentorship di Teknologi Digital'),
                    subtitle: const Text('Pelajari teknologi terbaru dan aplikasinya'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Fungsi
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Tombol Mulai Mentorship
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Fungsi
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Mulai Mentorship',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
