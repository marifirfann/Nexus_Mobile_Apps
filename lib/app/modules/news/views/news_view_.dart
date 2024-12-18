import 'package:education_apps/app/data/news_service.dart';
import 'package:education_apps/app/modules/connection/controllers/connection_controller.dart';
import 'package:education_apps/app/modules/connection/views/no_connection_view.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skeleton_loader/skeleton_loader.dart'; // Import package
import 'package:get/get.dart'; // Assuming you're using GetX for connection control

class NewsView extends StatefulWidget {
  @override
  _NewsViewState createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  final NewsService _newsService = NewsService();
  List<dynamic> _newsArticles = [];
  String _category = 'technology'; // Default category
  final ConnectionController connectionController = Get.find(); // Assuming you have a connection controller

  @override
  void initState() {
    super.initState();
    _checkConnectionAndFetchNews();
  }

  Future<void> _checkConnectionAndFetchNews() async {
    if (!connectionController.isConnected.value) {
      // If no internet connection, show the NoConnectionView
      setState(() {
        _newsArticles = []; // Clear any previously loaded news
      });
    } else {
      // If connected, fetch news
      _fetchNews();
    }
  }

  Future<void> _fetchNews() async {
    try {
      final articles = await _newsService.fetchNews(_category);
      setState(() {
        _newsArticles = articles;
      });
    } catch (e) {
      print(e);
    }
  }

  void _changeCategory(String category) {
    setState(() {
      _category = category;
      _newsArticles = []; // Clear previous articles
    });
    _fetchNews(); // Fetch news for the selected category
  }

  void _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      print('Attempting to launch URL: $url');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Category toggle buttons
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryButton('Tech', 'technology'),
                _buildCategoryButton('Education', 'education'),
                _buildCategoryButton('Health', 'health'),
                _buildCategoryButton('Sport', 'sport'),
              ],
            ),
          ),
          Expanded(
            child: connectionController.isConnected.value
                ? _newsArticles.isEmpty
                    ? SingleChildScrollView(
                        // Wrap skeleton loader with SingleChildScrollView
                        child: Column(
                          children: List.generate(
                            5, // Number of skeleton items
                            (index) => Card(
                              margin: const EdgeInsets.all(10.0),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Skeleton loader for image
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    const SizedBox(
                                        width: 15), // Space between image and text
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SkeletonLoader(
                                            builder: Container(
                                              width: double.infinity,
                                              height: 16.0,
                                              color: Colors.grey[300],
                                            ),
                                          ), // Skeleton for title
                                          const SizedBox(height: 8),
                                          SkeletonLoader(
                                            builder: Container(
                                              width: double.infinity,
                                              height: 14.0,
                                              color: Colors.grey[300],
                                            ),
                                          ), // Skeleton for description
                                          const SizedBox(height: 10),
                                          SkeletonLoader(
                                            builder: Container(
                                              width: 100,
                                              height: 36.0,
                                              color: Colors.grey[300],
                                            ),
                                          ), // Skeleton for button
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _newsArticles.length,
                        itemBuilder: (context, index) {
                          final article = _newsArticles[index];
                          return Card(
                            margin: const EdgeInsets.all(10.0),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display image if available
                                  if (article['image_url'] != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        article['image_url'],
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    ),
                                  const SizedBox(
                                      width: 15), // Space between image and text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article['title'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          article['description'],
                                          style: const TextStyle(color: Colors.grey),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 10),
                                        GestureDetector(
                                          onTap: () => _launchURL(article['link']),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 16),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue.withOpacity(0.2),
                                                  blurRadius: 4,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                            child: const Text(
                                              'Read More',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                : const NoConnectionView()
          ),
        ],
      ),
    );
  }

  // Custom category button
  Widget _buildCategoryButton(String title, String category) {
    return GestureDetector(
      onTap: () => _changeCategory(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _category == category ? Colors.blue : Colors.transparent,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _category == category ? Colors.white : Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
