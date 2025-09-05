import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hana_ai/widgets/background.dart';
import 'package:hana_ai/widgets/sphere_animation.dart';

import '../UI/home.dart';

class GlassNavBar extends StatefulWidget {
  const GlassNavBar({super.key});

  @override
  _GlassNavBarState createState() => _GlassNavBarState();
}

class _GlassNavBarState extends State<GlassNavBar> {
  int _selectedIndex = 0;

  final List<String> _icons = [
    "assets/icons/robo-icon.png",
    "assets/icons/bot-icon.png",
    "assets/icons/star.png",
    "assets/icons/google-icon.png",
  ];

  final List<String> _labels = [
    "Home",
    "Menu",
    "Activity",
    "Profile",
  ];
  // Add your actual screens here
  final List<Widget> _screens = [
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Positioned.fill(
          //   child: CustomBackground(
          //   ),
          // ),
          /// --- Your screen content ---
          Positioned.fill(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      /// --- Floating Button ---
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: theme.colorScheme.primary,
      //   shape: CircleBorder(),
      //   onPressed: () {
      //     // TODO: your action
      //   },
      //   child: const Icon(Icons.mic, color: Colors.white,size: 30,),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: Colors.grey,
                //remove extra padding under labels
                selectedFontSize: 12,
                unselectedFontSize: 11,
                selectedLabelStyle: const TextStyle(height: 0.12),
                unselectedLabelStyle: const TextStyle(height: 0.12),
                items: List.generate(
                  _icons.length,
                      (index) => BottomNavigationBarItem(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: _selectedIndex == index
                          ? BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primaryContainer, theme.colorScheme.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      )
                          : null,
                      child: Image.asset(
                        _icons[index],
                        height: screenHeight*0.04,
                        width: screenWidth*0.06,
                        color: _selectedIndex == index
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                    label: _labels[index],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
