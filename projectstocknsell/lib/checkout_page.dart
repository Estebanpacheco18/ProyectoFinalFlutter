import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final cardController = TextEditingController();
  final nameController = TextEditingController();
  bool isLoading = false;

  Future<void> makeOrder(BuildContext context) async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart');
    List<dynamic> cart = cartString != null ? json.decode(cartString) : [];
    if (cart.isEmpty) return;

    double total = 0;
final productos = cart.map((item) {
  total += (item['precio'] ?? 0) * (item['cantidad'] ?? 1);
  return {
    'productoId': item['_id'],
    'cantidad': item['cantidad'],
    'preciounitario': item['precio'],
  };
}).toList();

    final token = prefs.getString('token');

    // Llama al backend para crear el pedido y actualizar stock
    final response = await http.post(
      Uri.parse('https://laboratorio06-web-backend.onrender.com/api/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'productos': productos,
        'total': total,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      await prefs.remove('cart');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Compra realizada con éxito!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar compra')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Simulación de pago con tarjeta', style: TextStyle(fontSize: 18)),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre en la tarjeta'),
            ),
            TextField(
              controller: cardController,
              decoration: const InputDecoration(labelText: 'Número de tarjeta'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => makeOrder(context),
                    child: const Text('Pagar y comprar'),
                  ),
          ],
        ),
      ),
    );
  }
}