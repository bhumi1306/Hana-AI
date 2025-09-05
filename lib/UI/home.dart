import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hana_ai/Utility/keys.dart';
import 'package:hana_ai/widgets/background.dart';
import '../Utility/commons.dart';
import '../Utility/icon_animation.dart';
import '../widgets/radial_menu.dart';
import '../widgets/sphere_animation.dart';
import '../widgets/text_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasChat = false;
  final TextEditingController _controller = TextEditingController();

  static const String apiKey = googleApiKey;

  final model = GenerativeModel(
    model: 'gemini-1.5-flash', // or gemini-1.5-pro
    apiKey: apiKey,
  );
  List<Map<String, String>> messages = [];

  Future<void> _sendMessage(String userMessage) async {
    if (userMessage.isEmpty) return;

    setState(() {
      hasChat = true;
      messages.add({"role": "user", "text": userMessage});
    });

    try {
      final content = [Content.text(userMessage)];
      final response = await model.generateContent(content);

      setState(() {
        messages.add({"role": "bot", "text": response.text ?? "No response"});
      });
      debugPrint('Gemini response: ${response.text}');
    } catch (e) {
      setState(() {
        messages.add({"role": "bot", "text": "⚠️ Error: $e"});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    const double arcLeftPadding = 16;
    const double bottomPaddingFactor = 0.12;

    return Scaffold(
      backgroundColor: theme.colorScheme.onPrimary,
      body: CustomBackground(
        child: Stack(
          children: [
            /// Sphere Animation (position changes based on chat state)
            // AnimatedPositioned(
            //   duration: const Duration(milliseconds: 600),
            //   curve: Curves.easeInOut,
            //   top: hasChat ? 80 : (screenHeight / 2) - 150,
            //   left: 0,
            //   right: 0,
            //   child: Center(
            //     child: FlowingLiquidOrb(
            //       text: "Hi, can I\nhelp you?",
            //       size: 250,
            //       palette: [
            //         theme.colorScheme.primary,
            //         theme.colorScheme.primaryContainer,
            //         theme.colorScheme.secondaryContainer,
            //         theme.colorScheme.tertiaryContainer,
            //         theme.colorScheme.primary,
            //       ],
            //     ),
            //   ),
            // ),

            // Chat messages
            if (hasChat)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 350, 16, 80),
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg["role"] == "user";
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          // Bot avatar only for bot messages
                          if (!isUser) ...[
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: theme.colorScheme.onPrimary
                                  .withOpacity(0.4),
                              child: Image.asset(
                                'assets/images/app-logo-transp.png',
                                width: 50,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: isUser
                                    ? LinearGradient(
                                        colors: [
                                          theme.colorScheme.onPrimary,
                                          theme.colorScheme.primaryContainer,
                                          theme.colorScheme.primary,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          theme.colorScheme.onPrimary,
                                          theme.colorScheme.tertiaryContainer.withOpacity(0.3),
                                          theme.colorScheme.tertiaryContainer,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                                ),
                              ),
                              child: Text(
                                msg["text"] ?? "",
                                style: TextStyle(
                                  color: theme.colorScheme.onSecondary,
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: fontFamily,
                                ),
                              ),
                            ),
                          ),
                          if (isUser) const SizedBox(width: 8),
                        ],
                      ),
                    );
                  },
                ),
              ),

            /// Bottom Input Bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: screenHeight * 0.12,
                ),
                child: Row(
                  children: [
                    /// Add (+) Button
                    // inside your bottom Row where you currently have the Add button container:
                    SizedBox(
                      width: 55, // reserve space for Add button
                    ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: theme.colorScheme.surface,
                    //     borderRadius: BorderRadius.circular(30),
                    //     border: Border.all(
                    //       color: theme.colorScheme.primary,
                    //       width: 2,
                    //     ),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.black.withOpacity(0.05),
                    //         blurRadius: 6,
                    //         offset: const Offset(0, 2),
                    //       ),
                    //     ],
                    //   ),
                    //   child: IconButton(
                    //     icon: const Icon(Icons.add, size: 30),
                    //     onPressed: () {
                    //       // TODO: add functionality for +
                    //     },
                    //   ),
                    // ),
                    const SizedBox(width: 8),

                    /// Text Field
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _controller,
                          onTapOutside: (event) {
                            FocusScope.of(
                              context,
                            ).unfocus(); // Closes the keyboard
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Write here..",
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSecondary.withOpacity(
                                0.6,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.mic,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    // TODO: voice input functionality
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.send,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    _sendMessage(_controller.text);
                                    _controller.clear();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            /// ArcMenu floats *over* reserved space
            Positioned(
              left: 16,
              bottom: screenHeight * 0.085,
              child: ArcMenu(
                icons: [
                  Icons.headset,
                  Icons.my_location,
                  Icons.videocam,
                ],
                radius: 98,
                mainColor: theme.colorScheme.primary,
                itemColor: theme.colorScheme.onPrimary,
                mainIcon: Icons.add,
                mainSize: 55,
                itemSize: 62,
                onIconPressed: (index) {
                  if (index == 0) {
                    debugPrint("0 tapped");
                  } else if (index == 1) {
                    debugPrint("1 tapped");
                  } else if (index == 2) {
                    debugPrint("2 tapped");
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
