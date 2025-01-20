import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:newapp/model/NewsSource.dart';
import '../viewModel/newViewModel.dart';
import 'package:intl/intl.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final format = DateFormat('MMMM dd, yyyy');
  late Future _newsFuture;
  String selectedName = 'abc-news';
  List<String> _sources = [];
  bool _isLoadingSources = false;

  @override
  void initState() {
    super.initState();
    _newsFuture = Newviewmodel().fetchNewsHeadlines(selectedName);
    fetchSources();
  }

  List<String> _sourcesIds = [];

  Future<void> fetchSources() async {
    setState(() {
      _isLoadingSources = true;
    });
    try {
      final Sources sourcesResponse = await Newviewmodel().fetchNewsSources();
      setState(() {
        _sources =
            sourcesResponse.sources!.map((source) => source.name!).toList();
        _sourcesIds =
            sourcesResponse.sources!.map((source) => source.id!).toList();
        _isLoadingSources = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSources = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load sources: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
        centerTitle: true,
        title: const Text(
          'News Now',
          style: TextStyle(
              color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isLoadingSources)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 235, 113, 163), strokeWidth: 2),
              ),
            )
          else
            PopupMenuButton<String>(
              initialValue: selectedName,
              icon: const Icon(Icons.category, color: Colors.black),
              onSelected: (String value) {
                setState(() {
                  selectedName = value;
                  _newsFuture = Newviewmodel().fetchNewsHeadlines(selectedName);
                });
              },
              itemBuilder: (BuildContext context) {
                return List.generate(_sources.length, (index) {
                  return PopupMenuItem<String>(
                    value: _sourcesIds[index],
                    child: Text(_sources[index]),
                  );
                });
              },
            )
        ],
      ),
      body: FutureBuilder(
        future: _newsFuture,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitChasingDots(
                color: Color.fromARGB(255, 162, 199, 228),
                size: 50,
              ),
            );
          } else if (snapshot.hasData) {
            return SizedBox(
              height: height * 0.55,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.articles!.length,
                itemBuilder: (context, index) {
                  final article = snapshot.data!.articles![index];
                  DateTime? dateTime;
                  if (article.publishedAt != null) {
                    try {
                      dateTime = DateTime.parse(article.publishedAt!);
                    } catch (e) {
                      dateTime = null;
                    }
                  }
                  return Container(
                    width: width * 0.9,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: article.urlToImage ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => const Center(
                              child: SpinKitSquareCircle(
                                color: Color.fromARGB(255, 162, 199, 228),
                                size: 50,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.title ?? 'No Title',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  article.source?.name ?? 'Unknown Publisher',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateTime != null
                                      ? format.format(dateTime)
                                      : 'Unknown Date',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading articles.'));
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
