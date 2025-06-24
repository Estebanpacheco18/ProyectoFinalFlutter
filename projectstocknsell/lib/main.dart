import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Productos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ProductsPage(title: 'Lista de Productos'),
    );
  }
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key, required this.title});
  final String title;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late Future<List<dynamic>> _products;

Future<List<dynamic>> fetchProducts() async {
  final response = await http.get(
    Uri.parse('https://laboratorio06-web-backend.onrender.com/api/products'),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
    return data;
  } else {
    throw Exception('Error al cargar productos');
  }
}

  @override
  void initState() {
    super.initState();
    _products = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos.'));
          } else {
return ListView.builder(
  itemCount: snapshot.data!.length,
  itemBuilder: (context, index) {
    final product = snapshot.data![index];
    return ListTile(
      title: Text(product['nombre'] ?? 'Sin nombre'),
      subtitle: Text(product['descripcion'] ?? ''),
      trailing: Text('\$${product['precio']?.toString() ?? ''}'),
    );
  },
);
          }
        },
      ),
    );
  }
}