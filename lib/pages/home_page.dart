import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _articles = [];
  bool _isLoading = true;

  final String _apiKey = '9a944b1e145141e0a5a3706d092a3f6e';
  final String _url =
      'https://newsapi.org/v2/everything?q=deporte&language=es&sortBy=publishedAt&pageSize=100';

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    try {
      final response = await http.get(Uri.parse('$_url&apiKey=$_apiKey'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _articles = data['articles'];
          _isLoading = false;
        });
      } else {
        throw Exception('Error al cargar noticias');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias Deportivas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final article = _articles[index];
          final url = article['url'];
          final hasValidUrl = url != null && url.toString().startsWith('http');

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: article['urlToImage'] != null
                  ? Image.network(
                article['urlToImage'],
                width: 100,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.image_not_supported),
              title: Text(article['title'] ?? 'Sin título'),
              subtitle: Text(
                article['description'] ?? 'Sin descripción',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: hasValidUrl
                  ? () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(article['title'] ?? ''),
                    content: const Text('Ver noticia completa en el navegador.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _launchURL(url);
                        },
                        child: const Text('Ir a la noticia'),
                      ),
                    ],
                  ),
                );
              }
                  : null,
            ),
          );
        },
      ),
    );
  }
}
