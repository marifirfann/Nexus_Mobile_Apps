import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:education_apps/app/modules/profile/controllers/Profile_controller.dart';
import 'package:education_apps/app/modules/profile/views/geolocation_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileController controller = Get.find<ProfileController>();

  // TextEditingController untuk menangani input teks
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();

  final box = GetStorage(); // Penyimpanan lokal
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch data pengguna ketika widget diinisialisasi
    checkPendingUploads();
  }

  // Fungsi untuk mengambil data pengguna dari Firestore
  void fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          // Mengisi controller dengan data yang diambil dari Firestore
          usernameController.text = doc['name'] ?? '';
          emailController.text = doc['email'] ?? '';
          schoolController.text = doc['school'] ?? '';
        });
      }
    }
  }

  // Mengecek koneksi internet
  Future<bool> hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    return connectivityResult != ConnectivityResult.none;
  }

  // Fungsi untuk menyimpan perubahan ke Firestore atau lokal
  // Fungsi untuk menyimpan perubahan ke Firestore atau lokal
void saveChanges() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  Map<String, dynamic> dataToSave = {
    'name': usernameController.text,
    'email': emailController.text,
    'school': schoolController.text,
    'uid': user.uid,
  };

  if (await hasInternetConnection()) {
    // Jika ada koneksi, langsung upload
    await uploadToFirestore(dataToSave);
  } else {
    // Jika tidak ada koneksi, simpan ke penyimpanan lokal
    box.write('pending_upload', dataToSave);
    Get.snackbar(
      'Offline',
      'Perubahan tersimpan di penyimpanan lokal. Akan diunggah saat online.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orangeAccent,
      colorText: Colors.white,
    );

    // Tetap tampilkan notifikasi "Tersimpan" untuk memberikan kepastian
    Get.snackbar(
      'Tersimpan',
      'Perubahan berhasil disimpan secara lokal.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}


  // Fungsi untuk upload data ke Firestore
  Future<void> uploadToFirestore(Map<String, dynamic> data) async {
    setState(() {
      isUploading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(data['uid'])
          .update({
        'name': data['name'],
        'email': data['email'],
        'school': data['school'],
      });

      Get.snackbar(
        'Sukses',
        'Perubahan berhasil disimpan di database',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Hapus data dari penyimpanan lokal jika berhasil upload
      box.remove('pending_upload');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengupload data ke database.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  // Cek jika ada data yang tertunda saat koneksi kembali online
  void checkPendingUploads() async {
    var data = box.read('pending_upload');
    if (data != null && await hasInternetConnection()) {
      uploadToFirestore(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gambar Profil
              Center(
                child: Obx(
                  () => CircleAvatar(
                    radius: 60,
                    backgroundImage: controller
                            .selectedImagePath.value.isNotEmpty
                        ? FileImage(File(controller.selectedImagePath.value))
                        : const AssetImage('assets/default_profile.png'),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  controller.getImageFromGallery();
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
                  'Ganti Foto Profil',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),

              _buildInputField('Nama Pengguna', usernameController),
              const SizedBox(height: 20),
              _buildInputField('Email', emailController),
              const SizedBox(height: 20),
              _buildInputField('Sekolah', schoolController),
              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child:
                       const Text(
                          'Simpan Perubahan',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GetLocationView()),
                  );
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
                  'Lihat Lokasi Anda',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Masukkan $label',
          ),
        ),
      ],
    );
  }
}
