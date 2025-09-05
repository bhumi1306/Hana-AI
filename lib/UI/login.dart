import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hana_ai/UI/home.dart';
import 'package:hana_ai/UI/register.dart';
import 'package:hana_ai/widgets/bottom_menu.dart';

import '../Utility/commons.dart';
import '../widgets/background.dart';
import '../widgets/button.dart';
import '../widgets/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _entryController;
  late Animation<double> _fadeLogo;
  late Animation<double> _scaleWelcome;
  late Animation<double> _slideForm;
  late Animation<double> _fadeForm;

  @override
  void initState() {
    super.initState();

    /// Float controller (infinite up-down motion)
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _floatController.repeat(reverse: true);

    /// Entry animations
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeLogo = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _scaleWelcome = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.2, 0.5, curve: Curves.elasticOut),
    );
    _slideForm = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _fadeForm = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  /// Function that validates form and navigates with slide animation
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) =>
          const GlassNavBar(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // start from right
            const end = Offset.zero;        // end at center
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.easeInOut));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.colorScheme.onPrimary,
      resizeToAvoidBottomInset: true,
      body: CustomBackground(
        child: AnimatedBuilder(
          animation: _entryController,
          builder: (context, _) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.04,
                  horizontal: screenWidth * 0.02,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          /// Top logo with spin + floating effect
                          FadeTransition(
                            opacity: _fadeLogo,
                            child: AnimatedBuilder(
                              animation: _floatAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    0,
                                    _floatController.isAnimating
                                        ? _floatAnimation.value
                                        : 0,
                                  ),
                                  child: child,
                                );
                              },
                              child: Image.asset(
                                "assets/images/app-logo-transp.png",
                                height: screenHeight * 0.12,
                                width: screenWidth * 0.3,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),

                          /// Welcome text
                          ScaleTransition(
                            scale: _scaleWelcome,
                            child: Column(
                              children: [
                                Text(
                                  'Welcome back!',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSecondary,
                                    fontSize: screenWidth * 0.055,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: fontFamily,
                                  ),
                                ),
                                Text(
                                  'Login to your account to continue',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSecondary,
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),

                          /// Form and rest
                          Transform.translate(
                            offset: Offset(0, _slideForm.value),
                            child: Opacity(
                              opacity: _fadeForm.value,
                              child: _buildFormContent(
                                theme,
                                screenHeight,
                                screenWidth,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Extracted method for clarity
  Widget _buildFormContent(
    ThemeData theme,
    double screenHeight,
    double screenWidth,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: emailController,
                  labelText: "Email",
                  hintText: "Enter your email",
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                CustomTextField(
                  controller: passwordController,
                  labelText: "Password",
                  hintText: "Enter your password",
                  obscureText: obscurePassword,
                  prefixIcon: Icons.lock,
                  suffixIcon: obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixTap: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.01),
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    'Forgot Password?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSecondary,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w600,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomElevatedButton(text: "Login", onPressed: () {
                  _handleLogin();
                }),
              ],
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.onSecondary.withOpacity(0.3),
                indent: 30,
                endIndent: 8,
              ),
            ),
            Text(
              'OR',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSecondary.withOpacity(0.6),
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
                fontFamily: fontFamily,
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.onSecondary.withOpacity(0.3),
                indent: 8,
                endIndent: 30,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SizedBox(
            width: double.infinity, // 🔑 make button full width
            child: CustomElevatedButton(
              text: "Continue with Google",
              backgroundColor: theme.colorScheme.onPrimary,
              borderColor: theme.colorScheme.primary,
              textColor: theme.colorScheme.primary,
              assetIcon: 'assets/icons/google-icon.png',
              onPressed: () {},
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Still without an account?',
                style: TextStyle(
                  color: theme.colorScheme.onSecondary,
                  fontSize: screenWidth * 0.035, // reduced a bit
                  fontWeight: FontWeight.w600,
                  fontFamily: fontFamily,
                ),
              ),
              TextSpan(
                text: ' Create one',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: screenWidth * 0.04, // reduced a bit
                  fontWeight: FontWeight.w800,
                  fontFamily: fontFamily,
                ),
                recognizer: TapGestureRecognizer()..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
