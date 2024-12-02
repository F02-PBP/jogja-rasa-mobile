import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jogjarasa_mobile/screens/login.dart';
import 'package:jogjarasa_mobile/screens/register.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  final PageController pageController = PageController();
  int activeIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> carouselItems = [
    {
      'title': 'Jelajahi Kuliner Jogja',
      'subtitle': 'Temukan kelezatan kuliner khas Jogja',
      'icon': 'restaurant_menu'
    },
    {
      'title': 'Gudeg Jogja',
      'subtitle': 'Rasakan nikmatnya gudeg asli Jogja',
      'icon': 'lunch_dining'
    },
    {
      'title': 'Bakpia & Jajanan',
      'subtitle': 'Berbagai macam jajanan khas Jogja',
      'icon': 'bakery_dining'
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    Future.delayed(const Duration(seconds: 1), () {
      _autoScroll();
    });
  }

  void _autoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (activeIndex == carouselItems.length - 1) {
          pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        } else {
          pageController.nextPage(
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        }
        _autoScroll();
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50,
              Colors.orange.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(seconds: 1),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Icon(
                          Icons.restaurant_menu,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'JogjaRasa',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: carouselItems.length,
                          onPageChanged: (index) {
                            setState(() {
                              activeIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: buildCarouselCard(carouselItems[index]),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedSmoothIndicator(
                        activeIndex: activeIndex,
                        count: carouselItems.length,
                        effect: ExpandingDotsEffect(
                          dotColor: Colors.white.withOpacity(0.4),
                          activeDotColor: Colors.white,
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(double.infinity, 50),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.login),
                            const SizedBox(width: 8),
                            Text(
                              'Masuk',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add),
                            const SizedBox(width: 8),
                            Text(
                              'Daftar',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCarouselCard(Map<String, String> item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            getIconData(item['icon']!),
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Text(
            item['title']!,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item['subtitle']!,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant_menu':
        return Icons.restaurant_menu;
      case 'lunch_dining':
        return Icons.lunch_dining;
      case 'bakery_dining':
        return Icons.bakery_dining;
      default:
        return Icons.restaurant;
    }
  }
}
