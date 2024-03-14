import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:news_app/model/article.dart';
import 'package:news_app/styles.dart';
import 'package:news_app/widget/custom_scaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(0),
              ),
            ),
          ),
        ),
        appBarTheme: AppBarTheme(elevation: 0),
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: primaryColor,
          onPrimary: Colors.black,
          secondary: secondaryColor,
        ),
      ),
      initialRoute: NewsListPage.routeName,
      routes: {
        NewsListPage.routeName: (context) => const NewsListPage(),
        ArticleDetailPage.routeName: (context) => ArticleDetailPage(
          article: ModalRoute.of(context)?.settings.arguments as Article,
        ),
        ArticleWebView.routeName: (context) => ArticleWebView(
          url: ModalRoute.of(context)?.settings.arguments as String,
        ),
      },
    );
  }
}

class NewsListPage extends StatelessWidget {
  static const routeName = '/article_list';

  const NewsListPage({Key? key}) : super(key: key);

  List<Article> parseArticles(String? json) {
    if (json == null) {
      return [];
    }

    final List parsed = jsonDecode(json);
    return parsed.map((json) => Article.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News App'),
      ),
      body: FutureBuilder<String>(
        future:
        DefaultAssetBundle.of(context).loadString('assets/articles.json'),
        builder: (context, snapshot) {
          final List<Article> articles = parseArticles(snapshot.data);
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return _buildArticleItem(context, articles[index]);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home", activeIcon: Icon(Icons.home_filled, color: Colors.black,)),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home")
      ],
        
      ),
    );
  }

  Widget _buildArticleItem(BuildContext context, Article article) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      leading: Hero(
        tag: article.urlToImage,
        child: Image.network(
          article.urlToImage,
          width: 100,
        ),
      ),
      title: Text(article.title),
      subtitle: Text(article.author),
      onTap: () {
        Navigator.pushNamed(context, ArticleDetailPage.routeName,
            arguments: article);
      },
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  static const routeName = '/article_detail';

  final Article article;

  const ArticleDetailPage({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
                tag: article.urlToImage,
                child: Image.network(article.urlToImage)
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.description),
                  const Divider(color: Colors.grey),
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  Text('Date: ${article.publishedAt}'),
                  const SizedBox(height: 10),
                  Text('Author: ${article.author}'),
                  const Divider(color: Colors.grey),
                  Text(
                    article.content,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    child: const Text('Read more'),
                    onPressed: () {
                      Navigator.pushNamed(context, ArticleWebView.routeName,
                          arguments: article.url);
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
}

class ArticleWebView extends StatelessWidget {
  static const routeName = '/article_web';

  final String url;

  const ArticleWebView({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()..loadRequest(Uri.parse(url));
    return CustomScaffold(
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}