import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hana_ai/UI/login.dart';
import 'package:hana_ai/widgets/background.dart';

import '../Utility/commons.dart';
import '../widgets/animated_button.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _floatController;
  late Animation<double> _spinAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    /// Spin controller
    _spinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _spinAnimation = Tween<double>(begin: 0, end: math.pi * 2).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeInOut),
    );

    /// Float controller (infinite up-down motion)
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Start spin, then float
    _spinController.forward().whenComplete(() {
      _floatController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: CustomBackground(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Top logo with spin + floating effect
              AnimatedBuilder(
                animation: Listenable.merge([_spinAnimation, _floatAnimation]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatController.isAnimating ? _floatAnimation.value : 0),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // perspective
                        ..rotateY(_spinAnimation.value),
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  "assets/images/app-logo-transp.png",
                  height: screenHeight * 0.6,
                  width: screenWidth *0.8,
                  fit: BoxFit.contain,
                ),
              ),
        
              /// Bottom section
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.1),
                child: Column(
                  children: [
                    Text(
                      'Welcome to Hana-AI !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: screenWidth * 0.075,
                        fontWeight: FontWeight.w900,
                        fontFamily: fontFamily,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      'Meet Our AI Assistant: Your Go-To For Instant Answers To Any Question.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w700,
                        fontFamily: fontFamily,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    AnimatedButton(
                      text: 'Get Started',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                      background: [theme.colorScheme.primaryContainer, theme.colorScheme.primary], // optional
                    )
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (context) => LoginScreen()),
                    //     );
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     foregroundColor: theme.colorScheme.onPrimary,
                    //     backgroundColor: theme.colorScheme.primary,
                    //     elevation: 7,
                    //     padding: EdgeInsets.symmetric(
                    //       horizontal: screenWidth * 0.2,
                    //       vertical: 16,
                    //     ),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //   ),
                    //   child: Text(
                    //     "Get Started",
                    //     style: TextStyle(
                    //       color: theme.colorScheme.onPrimary,
                    //       fontSize: screenWidth * 0.04,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
