import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:confetti/confetti.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final cardController = TextEditingController();
  final nameController = TextEditingController();
  bool isLoading = false;
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

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
        'precioUnitario': item['precio'], // Usa el nombre correcto
      };
    }).toList();

    final token = prefs.getString('token');

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
      _confettiController.play();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Stack(
          alignment: Alignment.center,
          children: [
            AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text(
                '¡Felicidades!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              content: const Text(
                'Tu compra se realizó con éxito.',
                textAlign: TextAlign.center,
              ),
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              maxBlastForce: 20,
              minBlastForce: 8,
              gravity: 0.2,
            ),
          ],
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context)
            .popUntil((route) => route.settings.name == '/home');
      }
    } else {
      String errorMsg = 'Ocurrió un error al procesar la compra';
      try {
        final error = json.decode(response.body);
        if (error is Map && error.containsKey('error')) {
          errorMsg = error['error'];
        }
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: const Text('Confirmar compra'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Simulación de pago con tarjeta',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre en la tarjeta',
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cardController,
                  decoration: InputDecoration(
                    labelText: 'Número de tarjeta',
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => makeOrder(context),
                        child: const Text(
                          'Pagar y comprar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}