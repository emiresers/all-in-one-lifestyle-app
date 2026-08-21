import 'package:flutter/material.dart';

import '../../widgets/app_bottom_nav.dart';
import '../posts/posts_screen.dart';
import '../products/products_screen.dart';
import '../quotes/quotes_screen.dart';
import '../recipes/recipes_screen.dart';
import '../todos/todos_screen.dart';

class MainScreen extends StatefulWidget {
  final int userId;

  const MainScreen({super.key, required this.userId});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2;
  final List<ScrollController> _scrollControllers = List.generate(
    5,
    (_) => ScrollController(),
  );

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      RecipesScreen(
        userId: widget.userId,
        scrollController: _scrollControllers[0],
      ),
      PostsScreen(
        userId: widget.userId,
        scrollController: _scrollControllers[1],
      ),
      ProductsScreen(
        userId: widget.userId,
        scrollController: _scrollControllers[2],
      ),
      TodosScreen(
        userId: widget.userId,
        scrollController: _scrollControllers[3],
      ),
      QuotesScreen(
        userId: widget.userId,
        scrollController: _scrollControllers[4],
      ),
    ];
  }

  @override
  void dispose() {
    for (final controller in _scrollControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _selectTab(int index) {
    if (index == _currentIndex) {
      final controller = _scrollControllers[index];

      if (controller.hasClients) {
        controller.animateTo(
          controller.position.minScrollExtent,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      }

      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _selectTab,
        items: const [
          AppBottomNavItem(
            icon: Icons.restaurant_menu_outlined,
            selectedIcon: Icons.restaurant_menu_rounded,
            label: 'Recipes',
          ),
          AppBottomNavItem(
            icon: Icons.article_outlined,
            selectedIcon: Icons.article_rounded,
            label: 'Posts',
          ),
          AppBottomNavItem(
            icon: Icons.shopping_bag_outlined,
            selectedIcon: Icons.shopping_bag_rounded,
            label: 'Products',
          ),
          AppBottomNavItem(
            icon: Icons.check_circle_outline_rounded,
            selectedIcon: Icons.check_circle_rounded,
            label: 'Todos',
          ),
          AppBottomNavItem(
            icon: Icons.format_quote_outlined,
            selectedIcon: Icons.format_quote_rounded,
            label: 'Quotes',
          ),
        ],
      ),
    );
  }
}
