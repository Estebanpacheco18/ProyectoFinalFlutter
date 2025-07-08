import 'package:flutter/material.dart';
import 'products_page.dart';
import 'cart_page.dart';
import 'orders_page.dart';
import 'account_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    ProductsPage(),
    CartPage(),
    OrdersPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: theme.cardColor,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                  begin: 1.0, end: _selectedIndex == 0 ? 1.3 : 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: const Icon(Icons.store),
              ),
            ),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                  begin: 1.0, end: _selectedIndex == 1 ? 1.3 : 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: const Icon(Icons.shopping_cart),
              ),
            ),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                  begin: 1.0, end: _selectedIndex == 2 ? 1.3 : 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: const Icon(Icons.list_alt),
              ),
            ),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                  begin: 1.0, end: _selectedIndex == 3 ? 1.3 : 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: const Icon(Icons.person),
              ),
            ),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}