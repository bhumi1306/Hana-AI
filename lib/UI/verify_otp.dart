import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hana_ai/Services/resend_otp.dart';
import 'package:hana_ai/Services/verify_otp.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utility/commons.dart';
import '../Utility/snackbar.dart';
import '../widgets/bottom_menu.dart';
import '../widgets/button.dart';
import 'home.dart';

void showEmailVerificationSheet(BuildContext context, String email,int tempId ) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
      return _EmailVerificationContent(email: email,tempId: tempId,);
    },
  );
}

class _EmailVerificationContent extends StatefulWidget {
  final String email;
  final int tempId;
  const _EmailVerificationContent({super.key,required this.email, required this.tempId});

  @override
  State<_EmailVerificationContent> createState() =>
      _EmailVerificationContentState();
}

class _EmailVerificationContentState extends State<_EmailVerificationContent> with TickerProviderStateMixin{
  String _otp = "";
  late Timer _timer;
  int _secondsRemaining = 60;
  TextEditingController otpController = TextEditingController();
  bool isVerified = false;
  late AnimationController _tickController;
  late Animation<double> _scaleAnimation;
  bool isLoading = false;
  VerifyOTP verifyOTP = VerifyOTP();
  ResendOtp resendOtp = ResendOtp();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Tick animation controller
    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation =
        CurvedAnimation(parent: _tickController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _timer.cancel();
    _tickController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "$minutes:${secs.toString().padLeft(2, '0')}";
  }

  /// Function that validates otp and navigates
  void verifyOtp() async{
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      http.Response response = await verifyOTP.verifyOTP(widget.tempId, _otp).timeout(Duration(seconds: 15),);

     if (response.statusCode == 200) {
            Map<String, dynamic> responseBody = jsonDecode(response.body);

            final int id = responseBody['user']['id'];
            final String username = responseBody['user']['username'];
            final token = responseBody['token'];

            await storage.write(key: 'token', value: token);

            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('id', id);
            await prefs.setString('username', username);

            if (kDebugMode) {
              print('id: $id');
              print(token);
            }
            prefs.setBool('isLoggedIn', true);

            if (mounted) {
              setState(() {
                isVerified = true;
                isLoading = false;
              });
            }

            if (mounted) {
              _tickController.forward();

              // After 3 seconds, go to home
              Future.delayed(const Duration(seconds: 3), () {
                Navigator.pop(context); // close bottom sheet
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 800),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                    const GlassNavBar(),
                    transitionsBuilder: (context, animation, secondaryAnimation,
                        child) {
                      const begin = Offset(1.0, 0.0); // start from right
                      const end = Offset.zero; // end at center
                      final tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: Curves.easeInOut));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              });
              SnackBarUtil.show(context, message: 'Registered successfully.', icon: Icons.check_circle,);
            }
          } else {
            if (mounted) {
              SnackBarUtil.show(context, message: 'Invalid OTP.', icon: Icons.error,);
            }
          }
        }
    on TimeoutException catch (_) {
      setState(() {
        isLoading = false; // Hide loading indicator on timeout
      });
      SnackBarUtil.show(context, message: 'Please try again.', icon: Icons.error,);
    }
    catch (e) {
      debugPrint('Exception in otp verification: $e');
      SnackBarUtil.show(context, message: 'Please try again.', icon: Icons.error,);
        }
    finally {
      setState(() {
        isLoading = false;  // Hide loader
      });
    }
      }

  /// Function that resends otp 
  void resendUserOtp() async{
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      http.Response response = await resendOtp.resendOtp(widget.email).timeout(Duration(seconds: 15),);

      if (response.statusCode == 200) {
        _startTimer(); // restart timer on resend
        SnackBarUtil.show(context, message: 'OTP resent.', icon: Icons.mail,);

      } else {
        if (mounted) {
          SnackBarUtil.show(context, message: 'Please try again.', icon: Icons.error,);
        }
      }
    }
    on TimeoutException catch (_) {
      setState(() {
        isLoading = false; // Hide loading indicator on timeout
      });
      SnackBarUtil.show(context, message: 'Please try again.', icon: Icons.error,);
    }
    catch (e) {
      debugPrint('Exception in otp resending: $e');
      SnackBarUtil.show(context, message: 'Please try again.', icon: Icons.error,);
    }
    finally {
      setState(() {
        isLoading = false;  // Hide loader
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;

    if (isVerified) {
      return SizedBox(
        height: 400,
        child: Center(
          child: AnimatedBuilder(
            animation: _tickController,
            builder: (context, child) {
              // Invert animation so we start large → shrink inward
              final scale = 2.5 - (_tickController.value * 1.5);

              return Transform.scale(
                scale: scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background expanding+shrinking circles
                        ...List.generate(
                          3,
                              (i) {
                            final baseSize = 140 + (i * 40);
                            return Container(
                              width: baseSize.toDouble(),
                              height: baseSize.toDouble(),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.tertiaryContainer
                                    .withOpacity(0.15),
                              ),
                            );
                          },
                        ),

                        // Sparkle stars
                        ...List.generate(
                          5,
                              (i) {
                            final angle = (72 * i) * 3.14 / 180;
                            return Positioned(
                              top: 70 * -sin(angle),
                              left: 70 * cos(angle),
                              child: FadeTransition(
                                opacity: Tween<double>(begin: 0.2, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: _tickController,
                                    curve: Interval(
                                        i * 0.1, 1.0, curve: Curves.easeInOut),
                                  ),
                                ),
                                child: ImageIcon(AssetImage('assets/icons/star.png'),color: Colors.white,),
                              ),
                            );
                          },
                        ),

                        // Center tick
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.tertiaryContainer,
                          ),
                          padding: const EdgeInsets.all(24),
                          child: const Icon(Icons.check,
                              size: 50, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Successfully!",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Your account has been created",
                      style: TextStyle(color: Colors.black54,fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Verify email",
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 6),
             Text(
              "Verify your email below to proceed.",
              style: TextStyle(color: Colors.black54,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: fontFamily,
              ),
            ),

            const SizedBox(height: 24),

             Text.rich(
              TextSpan(
                text: "Enter the ",
                children: [
                  TextSpan(
                    text: "4 digits code ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: "sent to your email address "),
                  TextSpan(
                    text: widget.email,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: " below."),
                ],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // OTP fields
            PinCodeTextField(
              appContext: context,
              length: 4,
              obscureText: false,
              animationType: AnimationType.fade,
              keyboardType: TextInputType.number,
              onEditingComplete:() {
                FocusScope.of(context).unfocus();  // Closes the keyboard
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              showCursor: true,
              cursorColor: theme.colorScheme.tertiaryContainer,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 50,
                fieldWidth: 50,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.white,
                activeColor: theme.colorScheme.tertiaryContainer,
                inactiveColor: theme.colorScheme.tertiaryContainer,
                selectedColor: theme.colorScheme.tertiaryContainer,
              ),
              animationDuration: const Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              enableActiveFill: true,
              boxShadows: const [
                BoxShadow(
                  offset: Offset(0, 1),
                  color: Colors.black12,
                  blurRadius: 10,
                )
              ],
              controller: otpController,
              autoDisposeControllers: false,
              onChanged: (value) {
                setState(() {
                  _otp = value;
                });
                debugPrint(_otp);
              },
              beforeTextPaste: (text) {
                debugPrint("Allowing to paste $text");
                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                return true;
              },
            ),

            const SizedBox(height: 8),

            // Countdown
            Text(
              _secondsRemaining > 0
                  ? "Code expires in ${_formatTime(_secondsRemaining)}"
                  : "Code expired",
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: () {
                if (_secondsRemaining == 0) {
                  resendUserOtp();
                  // _startTimer(); // restart timer on resend
                }
              },
              child: Text(
                "Didn't get code? Resend code",
                style: TextStyle(
                  color: _secondsRemaining == 0 ? theme.colorScheme.primary : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Verify button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _otp.length == 4
                      ? theme.colorScheme.primary
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _otp.length == 4
                    ? () {
                  verifyOtp();
                }
                    : null,
                child: const Text(
                  "Verify",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
