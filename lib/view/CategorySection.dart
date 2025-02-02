import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../view/Description.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:newapp/viewModel/newViewModel.dart';
import '../model/categoryNews.dart';
import 'package:intl/intl.dart';

class Categorysection extends StatefulWidget {
  const Categorysection({super.key});

  @override
  State<Categorysection> createState() => _CategorysectionState();
}

class _CategorysectionState extends State<Categorysection> {
  Newviewmodel newviewmodel = Newviewmodel();
  final format = DateFormat('MMMM dd, yyyy');
  String categoryName = 'general';

  final List<String> categoryList = [
    'general',
    'Sports',
    'health',
    'Entertainment',
    'Business',
    'Technology'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
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
          backgroundColor: Colors.black,
          ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      categoryName = categoryList[index];
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 7.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: categoryName == categoryList[index]
                              ? Colors.orange.shade900
                              : const Color.fromARGB(255, 176, 174, 182),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 12),
                          child: Text(
                            categoryList[index].toString().toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<CategoryNews>(
              future: newviewmodel.fetchCategoryNews(categoryName),
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SpinKitChasingDots(
                      color: Color.fromARGB(255, 10, 0, 0),
                      size: 50,
                    ),
                  );
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final article = snapshot.data!.articles![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        child: InkWell(
                          onTap: () {
                            DateTime? dateTime;
                            if (article.publishedAt != null) {
                              try {
                                dateTime = DateTime.parse(article.publishedAt!);
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
                                  author: article.author ?? 'Unknown Author',
                                  source:
                                      article.source?.name ?? 'Unknown Source',
                                  dateTime: dateTime != null
                                      ? format.format(dateTime)
                                      : 'Unknown Date',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: CachedNetworkImage(
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
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.title ?? 'No Title',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading articles.'));
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
