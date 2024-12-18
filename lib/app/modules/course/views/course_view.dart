import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';  // Tambahkan import Firestore
import 'package:url_launcher/url_launcher.dart';  // Untuk membuka Maps

class CourseView extends StatelessWidget {
  final stt.SpeechToText _speech = stt.SpeechToText(); // Inisialisasi STT
  final TextEditingController _searchController = TextEditingController();
  bool _isListening = false;

  CourseView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(''), // Kosongkan judul
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            labelColor: Color(0xFFFFFFFF), // Warna teks tab yang dipilih
            unselectedLabelColor: Color(0xFF060074),
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Matematika'),
              Tab(text: 'Fisika'),
            ],
          ),
          flexibleSpace: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: 300,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Kursus...',
                    hintStyle: const TextStyle(
                        color: Color.fromARGB(135, 255, 255, 255)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    suffixIcon: GestureDetector(
                      onTap: _toggleListening,
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildCourseList(),
            _buildCourseList(filter: 'Matematika'),
            _buildCourseList(filter: 'Fisika'),
          ],
        ),
      ),
    );
  }

  void _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(onResult: (result) {
          _searchController.text = result.recognizedWords;
        });
        _isListening = true;
      }
    } else {
      _speech.stop();
      _isListening = false;
    }
  }

  // Fetch courses from Firestore
  Widget _buildCourseList({String? filter}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading courses.'));
        }

        final courses = snapshot.data?.docs ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            final title = course['title'];
            final subtitle = course['subtitle'];
            final imageUrl = course['imageUrl'];
            final audioUrl = course['audioUrl'];
            final location = course['location'];
            final latitude = course['latitude'];
            final longitude = course['longitude'];
            final type = course['type']; // Online / Offline
            final price = course['price']; // Harga kursus
            final videoUrl = course['videoUrl']; // Menambahkan videoUrl

            if (filter != null &&
                !title.toString().toLowerCase().contains(filter.toLowerCase())) {
              return const SizedBox.shrink();
            }
            return _buildCourseCard(
              context,
              title,
              subtitle,
              imageUrl,
              audioUrl,
              location,
              latitude,
              longitude,
              type,
              price,
              videoUrl,  // Pass videoUrl
            );
          },
        );
      },
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    String title,
    String subtitle,
    String imageUrl,
    String? audioUrl, 
    String location,
    double latitude,
    double longitude,
    String type,
    String price,
    String? videoUrl, // Menambahkan videoUrl
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tambahkan status Online / Offline
                  Text(
                    type == 'Offline' ? 'Status: Offline' : 'Status: Online',
                    style: TextStyle(
                      color: type == 'Offline' ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _showCourseDetailsModal(
                        context,
                        title,
                        subtitle,
                        price,
                        imageUrl,
                        latitude,
                        longitude,
                        type,
                        videoUrl, // Pass videoUrl
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Mulai Kursus',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  // Jika kursus offline, tampilkan tombol Maps
                  if (type == 'Offline')
                    IconButton(
                      icon: const Icon(Icons.map, color: Colors.green),
                      onPressed: () {
                        _launchMap(latitude, longitude);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Menampilkan modal dengan detail kursus
// Menampilkan modal dengan detail kursus
void _showCourseDetailsModal(
  BuildContext context,
  String title,
  String subtitle,
  String price,
  String imageUrl,
  double latitude,
  double longitude,
  String type,
  String? videoUrl, // Menambahkan parameter videoUrl
) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(  // Add SingleChildScrollView here
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(imageUrl, height: 150),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Harga: $price',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              // Tombol untuk membuka Maps
              if (type == 'Offline')
                ElevatedButton(
                  onPressed: () {
                    _launchMap(latitude, longitude);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Lihat Lokasi di Maps'),
                ),
              const SizedBox(height: 10),
              // Tombol Hubungi Mentor
              ElevatedButton(
                onPressed: () {
                  _contactMentor();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Hubungi Mentor'),
              ),
              const SizedBox(height: 10),
              // Jika ada URL video, tampilkan tombol untuk memutar video
              if (videoUrl != null && videoUrl.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    _playVideo(videoUrl);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Tonton Video Kursus'),
                ),
            ],
          ),
        ),
      );
    },
  );
}


  // Fungsi untuk membuka WhatsApp atau aplikasi lain untuk menghubungi mentor
  void _contactMentor() async {
    const mentorPhoneNumber = '6281234567890'; // Ganti dengan nomor mentor
    final url = 'https://wa.me/$mentorPhoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Fungsi untuk membuka lokasi di Maps
  void _launchMap(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps?q=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Fungsi untuk memutar video
  void _playVideo(String videoUrl) async {
    if (await canLaunch(videoUrl)) {
      await launch(videoUrl);
    } else {
      throw 'Could not launch $videoUrl';
    }
  }
}
