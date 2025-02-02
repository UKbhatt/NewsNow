import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:newapp/model/NewsSource.dart';
import 'package:newapp/model/Smallnews.dart' as smallnews;
import '../view/Description.dart';
import '../viewModel/newViewModel.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final format = DateFormat('MMMM dd, yyyy');
  late Future _newsFuture;
  late Future<List<smallnews.Article>> _smallNewsFuture;
  String selectedName = 'abc-news';
  late final Map<String, String> _sourcesList;
  final supabase = Supabase.instance.client;
  bool _isLoadingSources = false;

  Future<void> _signOut() async {
    await supabase.auth.signOut();
  }

  Map<int, Key> _imageKeys = {};

  @override
  void initState() {
    super.initState();
    _newsFuture = Newviewmodel().fetchNewsHeadlines(selectedName);
    fetchSources();
    _smallNewsFuture = fetchSmallNewsOptimized();
  }

  Future<List<smallnews.Article>> fetchSmallNewsOptimized() async {
    try {
      final response = await Newviewmodel().fetchSmallNews();
      return response.articles ?? [];
    } catch (e) {
      debugPrint("Error occurred while fetching small news: $e");
      return [];
    }
  }

  Future<void> fetchSources() async {
    setState(() {
      _isLoadingSources = true;
    });
    try {
      final Sources sourcesResponse = await Newviewmodel().fetchNewsSources();
      setState(() {
        _sourcesList = {
          for (var value in sourcesResponse.sources!) value.id!: value.name!
        };
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
            color: Colors.white,
          ),
          onPressed: () => Navigator.pushNamed(context, '/Category'),
        ),
        centerTitle: true,
        title: const Text(
          'News Now',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: selectedName,
            icon: const Icon(Icons.category, color: Colors.white),
            onSelected: (String value) {
              setState(() {
                selectedName = value;
                _newsFuture = Newviewmodel().fetchNewsHeadlines(selectedName);
              });
            },
            itemBuilder: (BuildContext context) {
              return List.generate(_sourcesList.length, (index) {
                return PopupMenuItem<String>(
                  value: _sourcesList.keys.elementAt(index),
                  child: Text(
                    _sourcesList.values.elementAt(index),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                );
              });
            },
          ),
        ],
        backgroundColor: Colors.black,
        elevation: 10,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: FadeIn(
          duration: const Duration(milliseconds: 500),
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: FutureBuilder(
                    future: _newsFuture,
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: SpinKitChasingDots(
                              color: Color.fromARGB(255, 162, 199, 228),
                              size: 50,
                            ),
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
                                  dateTime =
                                      DateTime.parse(article.publishedAt!);
                                } catch (e) {
                                  dateTime = null;
                                }
                              }
                              return Container(
                                width: width * 0.9,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
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
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DescriptionScreen(
                                          image: article.urlToImage ?? '',
                                          title: article.title ?? 'No Title',
                                          description: article.description ??
                                              'No Description Available',
                                          author: article.author ??
                                              'Unknown Author',
                                          source: article.source?.name ??
                                              'Unknown Source',
                                          dateTime: dateTime != null
                                              ? format.format(dateTime)
                                              : 'Unknown Date',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: CachedNetworkImage(
                                          key: _imageKeys[index] ??
                                              Key('$index'),
                                          imageUrl: article.urlToImage ?? '',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          placeholder: (context, url) =>
                                              const Center(
                                            child: SpinKitSquareCircle(
                                              color: Color.fromARGB(
                                                  255, 162, 199, 228),
                                              size: 50,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Center(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _imageKeys[index] =
                                                      Key('$index');
                                                });
                                              },
                                              child: const Icon(
                                                Icons.refresh,
                                                color: Colors.black,
                                              ),
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
                                            color:
                                                Colors.black.withOpacity(0.7),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                article.source?.name ??
                                                    'Unknown Publisher',
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                dateTime != null
                                                    ? format.format(dateTime)
                                                    : 'Unknown Date',
                                                style: const TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading articles.'));
                      } else {
                        return const Center(child: Text('No data available'));
                      }
                    },
                  ),
                ),
              ];
            },
            body: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: FutureBuilder<List<smallnews.Article>>(
                future: _smallNewsFuture,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SpinKitChasingDots(
                        color: Color.fromARGB(255, 162, 199, 228),
                        size: 50,
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final article = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 3,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: InkWell(
                                onTap: () {
                                  DateTime? dateTime;
                                  if (article.publishedAt != null) {
                                    try {
                                      dateTime =
                                          DateTime.parse(article.publishedAt!);
                                    } catch (e) {
                                      dateTime = null;
                                    }
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DescriptionScreen(
                                        image: article.urlToImage ?? '',
                                        title: article.title ?? 'No Title',
                                        description: article.description ??
                                            'No Description Available',
                                        author:
                                            article.author ?? 'Unknown Author',
                                        source: article.source?.name ??
                                            'Unknown Source',
                                        dateTime: dateTime != null
                                            ? format.format(dateTime)
                                            : 'Unknown Date',
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: article.urlToImage ?? '',
                                      placeholder: (context, url) =>
                                          const SpinKitRing(
                                        color: Colors.black,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        article.title ?? 'No Title',
                                        style: const TextStyle(fontSize: 16),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error loading small news.'));
                  } else {
                    return const Center(
                        child: Text('No small news available.'));
                  }
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm Your Action'),
                content: const Text('Do you want to exit or log out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _signOut();
                      Navigator.popAndPushNamed(context, '/Login');
                    },
                    child: const Text('Logout'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(exit(0)),
                    child: const Text('Exit'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
    );
  }
}
