import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hana_ai/UI/login.dart';

import '../Utility/commons.dart';
import '../widgets/background.dart';
import '../widgets/button.dart';
import '../widgets/text_field.dart';
import 'home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (value.length > 12) {
      return 'Password must not exceed 12 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Function that validates form and navigates
  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
        isRegister: true,
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
                                  'Create Account',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSecondary,
                                    fontSize: screenWidth * 0.055,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: fontFamily,
                                  ),
                                ),
                                Text(
                                  'Create a new account to continue',
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
                  controller: usernameController,
                  keyboardType: TextInputType.text,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z][a-zA-Z ]*'))],
                  hintText: 'Full name',
                  maxLength: 40,
                  textCapitalization: TextCapitalization.sentences,
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    String trimmedValue = value!.trim();
                    if (trimmedValue == null || trimmedValue.isEmpty) {
                      return 'Username is required.';
                    }
                    return null;
                  },
                  labelText: 'Username',
                ),
                SizedBox(height: screenHeight * 0.02),
                CustomTextField(
                  controller: emailController,
                  labelText: "Email",
                  hintText: "Enter your email",
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
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
                  obscureText: !obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixTap: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  validator: validatePassword,
                ),
                SizedBox(height: screenHeight * 0.02),
                CustomTextField(
                  controller: confirmPasswordController,
                  keyboardType: TextInputType.text,
                  hintText: 'Confirm Password',
                  obscureText: !obscureConfirmPassword,
                  prefixIcon: Icons.lock_open_outlined,
                  suffixIcon: obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixTap: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                  validator: validateConfirmPassword,
                  labelText: 'Confirm Password',
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomElevatedButton(text: "Sign Up", onPressed: () {
                  _handleRegister();
                }),
              ],
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),

        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Already have an account?',
                style: TextStyle(
                  color: theme.colorScheme.onSecondary,
                  fontSize: screenWidth * 0.035, // reduced a bit
                  fontWeight: FontWeight.w600,
                  fontFamily: fontFamily,
                ),
              ),
              TextSpan(
                text: ' Sign In',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: screenWidth * 0.04, // reduced a bit
                  fontWeight: FontWeight.w800,
                  fontFamily: fontFamily,
                ),
                recognizer: TapGestureRecognizer()..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
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
