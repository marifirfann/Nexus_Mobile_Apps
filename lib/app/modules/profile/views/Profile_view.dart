// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_apps/app/modules/profile/views/TopUpScreen.dart';
import 'package:education_apps/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io'; // Untuk menangani file gambar dari galeri
import '../controllers/Profile_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_settings_view.dart'; // Impor SettingsView

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  ProfileViewState createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  final ProfileController controller = Get.put(ProfileController());
  File? profileImage; // Icon profile
  String mentorName = '';
  String mentorSchool = '';
  String mentorBalance = '10000'; // Tambahkan variable untuk saldo

  @override
  void initState() {
    super.initState();
    fetchMentorData();
  }

  void fetchMentorData() async {
    User? user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users') // Ganti dengan nama koleksi untuk mentor
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          mentorName = doc['name']; // Sesuaikan dengan field di Firestore
          mentorSchool = doc['school'];
          // mentorBalance = doc['balance'].toString(); // Ambil saldo mentor
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header dengan background biru dan foto profil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 80, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Obx(
                    () => GestureDetector(
                      onTap: () {
                        controller
                            .getImageFromGallery(); // Memanggil fungsi untuk memilih gambar
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            controller.selectedImagePath.value.isNotEmpty
                                ? FileImage(File(controller.selectedImagePath
                                    .value)) // Gambar dari galeri
                                : const NetworkImage(
                                    'https://www.example.com/profile_pic_url', // URL default gambar profil
                                  ) as ImageProvider,
                        child: controller.selectedImagePath.value.isEmpty
                            ? const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 30,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    mentorName.isNotEmpty ? mentorName : 'Loading...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    mentorSchool.isNotEmpty ? mentorSchool : 'Loading...',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Menambahkan saldo mentor
                  Text(
                    mentorBalance.isNotEmpty
                        ? 'Saldo Anda: Rp $mentorBalance' // Menampilkan saldo
                        : 'Saldo: Loading...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Tombol Top Up
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigasi ke halaman Top Up
                      Get.to(() => TopUpScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green, // Warna hijau untuk tombol Top Up
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Top Up',
                      style: TextStyle(
                        color: Colors.white, // Warna teks Top Up
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Mentor yang Anda Bimbing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mentor yang Anda Bimbing',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.school, color: Colors.blue),
                    title: const Text('Bimbingan Matematika - Kelas 10'),
                    subtitle: const Text('Progress: 70%'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Fungsi menuju detail mentoring
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.school, color: Colors.blue),
                    title: const Text('Bimbingan Fisika - Kelas 10'),
                    subtitle: const Text('Progress: 50%'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Fungsi menuju detail mentoring
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.school, color: Colors.blue),
                    title: const Text('Bimbingan Kimia - Kelas 10'),
                    subtitle: const Text('Progress: 30%'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Fungsi menuju detail mentoring
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Prestasi Mentor
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prestasi Anda',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    leading: Icon(Icons.emoji_events, color: Colors.amber),
                    title: Text('Mentor Terbaik dalam Olimpiade Matematika'),
                    subtitle: Text('Tahun 2023'),
                  ),
                  ListTile(
                    leading: Icon(Icons.emoji_events, color: Colors.amber),
                    title: Text('Mentor Finalis Lomba Sains Nasional'),
                    subtitle: Text('Tahun 2022'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Tombol Edit Profil
            ElevatedButton(
              onPressed: () {
                Get.to(EditProfileView());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue, // Warna biru untuk tombol Edit Profil
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Edit Profil',
                style: TextStyle(
                  color: Colors.white, // Warna teks Edit Profil
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tombol Logout
            ElevatedButton(
              onPressed: () async {
                // Proses sign out terlebih dahulu
                await FirebaseAuth.instance.signOut();

                // Gunakan WidgetsBinding untuk menunggu frame berikutnya
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.offAll(() => const LoginScreen());
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Warna merah untuk tombol Logout
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white, // Warna teks Logout
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
