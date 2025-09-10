// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:hana_ai/Utility/keys.dart';
// import 'package:hana_ai/widgets/background.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import '../Utility/commons.dart';
// import '../widgets/radial_menu.dart';
// import 'login.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class ChatSession {
//   final String id;
//   final String title;
//   final DateTime createdAt;
//   final DateTime? updatedAt;
//   final List<Map<String, dynamic>> messages;
//
//   ChatSession({
//     required this.id,
//     required this.title,
//     required this.createdAt,
//     this.updatedAt,
//     required this.messages,
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'createdAt': createdAt.toIso8601String(),
//       'messages': messages,
//     };
//   }
//
//   factory ChatSession.fromJson(Map<String, dynamic> json) {
//     return ChatSession(
//       id: json['id'],
//       title: json['title'],
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
//       messages: List<Map<String, dynamic>>.from(json['messages']),
//     );
//   }
// }
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../UI/home.dart';
// import '../Utility/commons.dart';
//
// class ApiService {
//
//   static Future<String?> getAuthToken() async {
//     String token = await getToken();
//     return token;
//   }
//
//   static Future<String?> getUserId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('id');
//   }
//
//   static Future<Map<String, String>> getAuthHeaders() async {
//     final token = await getAuthToken();
//     return {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//   }
//
//   // Save chat history to backend
//   static Future<bool> saveChatHistory(List<ChatSession> chatHistory) async {
//     try {
//       final userId = await getUserId();
//       if (userId == null) return false;
//
//       final headers = await getAuthHeaders();
//       final body = json.encode({
//         'chatHistory': chatHistory.map((session) => session.toJson()).toList(),
//       });
//
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/chat-history/$userId'),
//         headers: headers,
//         body: body,
//       );
//
//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('Error saving chat history: $e');
//       return false;
//     }
//   }
//
//   // Get chat history from backend
//   static Future<List<ChatSession>> getChatHistory({int limit = 50, int offset = 0}) async {
//     try {
//       final userId = await getUserId();
//       if (userId == null) return [];
//
//       final headers = await getAuthHeaders();
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/chat-history/$userId?limit=$limit&offset=$offset'),
//         headers: headers,
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List<dynamic> chatHistoryData = data['data']['chatHistory'];
//
//         return chatHistoryData.map((item) => ChatSession.fromJson(item)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('Error loading chat history: $e');
//       return [];
//     }
//   }
//
//   // Get specific chat session
//   static Future<ChatSession?> getChatSession(String sessionId) async {
//     try {
//       final userId = await getUserId();
//       if (userId == null) return null;
//
//       final headers = await getAuthHeaders();
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/chat-history/$userId/$sessionId'),
//         headers: headers,
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return ChatSession.fromJson(data['data']);
//       }
//       return null;
//     } catch (e) {
//       debugPrint('Error loading chat session: $e');
//       return null;
//     }
//   }
//
//   // Delete chat session
//   static Future<bool> deleteChatSession(String sessionId) async {
//     try {
//       final userId = await getUserId();
//       if (userId == null) return false;
//
//       final headers = await getAuthHeaders();
//       final response = await http.delete(
//         Uri.parse('$baseUrl/api/chat-history/$userId/$sessionId'),
//         headers: headers,
//       );
//
//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('Error deleting chat session: $e');
//       return false;
//     }
//   }
// }
//
// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin{
//   bool hasChat = false;
//   String username = 'user';
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   static const String apiKey = googleApiKey;
//
//   final model = GenerativeModel(
//     model: 'gemini-1.5-flash',
//     apiKey: apiKey,
//   );
//
//   List<Map<String, dynamic>> messages = [];
//   bool isTyping = false;
//   List<ChatSession> chatHistory = [];
//   String? currentChatId;
//   bool isLoadingHistory = false;
//
//   // Animation controllers for typing effect
//   late AnimationController _typingController;
//   String _currentDisplayText = '';
//   String _fullResponseText = '';
//   int _currentMessageIndex = -1;
//
//   @override
//   void initState() {
//     super.initState();
//     getUsername();
//     _typingController = AnimationController(
//       duration: const Duration(milliseconds: 50),
//       vsync: this,
//     );
//     _loadChatHistory();
//   }
//
//   @override
//   void dispose() {
//     _typingController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void getUsername() async{
//     final prefs = await SharedPreferences.getInstance();
//     String name = prefs.getString('username') ?? 'user';
//     if(mounted){
//       setState(() {
//         username = name;
//       });
//     }
//   }
//
//   // Load chat history from backend
//   Future<void> _loadChatHistory() async {
//     setState(() {
//       isLoadingHistory = true;
//     });
//
//     try {
//       final history = await ApiService.getChatHistory();
//       if (mounted) {
//         setState(() {
//           chatHistory = history;
//           isLoadingHistory = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading chat history: $e');
//       if (mounted) {
//         setState(() {
//           isLoadingHistory = false;
//         });
//       }
//       // Fallback to local storage
//       _loadLocalChatHistory();
//     }
//   }
//
//   // Fallback method to load from local storage
//   Future<void> _loadLocalChatHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? historyJson = prefs.getString('chat_history');
//
//     if (historyJson != null) {
//       final List<dynamic> historyList = json.decode(historyJson);
//       setState(() {
//         chatHistory = historyList.map((item) => ChatSession.fromJson(item)).toList();
//         chatHistory.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//       });
//     }
//   }
//
//   // Save chat history to backend and local storage
//   Future<void> _saveChatHistory() async {
//     try {
//       // Save to backend
//       final success = await ApiService.saveChatHistory(chatHistory);
//
//       if (!success) {
//         // Fallback to local storage if backend fails
//         await _saveLocalChatHistory();
//       }
//     } catch (e) {
//       debugPrint('Error saving to backend, using local storage: $e');
//       await _saveLocalChatHistory();
//     }
//   }
//
//   // Fallback method to save to local storage
//   Future<void> _saveLocalChatHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String historyJson = json.encode(
//       chatHistory.map((session) => session.toJson()).toList(),
//     );
//     await prefs.setString('chat_history', historyJson);
//   }
//
//   // Create a new chat session
//   void _createNewChat() {
//     if (messages.isNotEmpty && currentChatId != null) {
//       _saveCurrentChat();
//     }
//
//     setState(() {
//       messages.clear();
//       hasChat = false;
//       currentChatId = null;
//       isTyping = false;
//     });
//
//     Navigator.pop(context);
//   }
//
//   // Save current chat session
//   void _saveCurrentChat() {
//     if (messages.isEmpty) return;
//
//     String title = _generateChatTitle();
//     final session = ChatSession(
//       id: currentChatId ?? DateTime.now().millisecondsSinceEpoch.toString(),
//       title: title,
//       createdAt: DateTime.now(),
//       messages: List.from(messages),
//     );
//
//     // Update existing session or add new one
//     final existingIndex = chatHistory.indexWhere((s) => s.id == session.id);
//     if (existingIndex >= 0) {
//       chatHistory[existingIndex] = session;
//     } else {
//       chatHistory.insert(0, session);
//     }
//
//     _saveChatHistory();
//   }
//
//   // Generate chat title from first user message
//   String _generateChatTitle() {
//     final firstUserMessage = messages.firstWhere(
//           (msg) => msg['role'] == 'user',
//       orElse: () => {'text': 'New Chat'},
//     );
//
//     String title = firstUserMessage['text'] ?? 'New Chat';
//     if (title.length > 30) {
//       title = '${title.substring(0, 27)}...';
//     }
//     return title;
//   }
//
//   // Load a specific chat session
//   void _loadChatSession(ChatSession session) {
//     setState(() {
//       messages = List.from(session.messages);
//       currentChatId = session.id;
//       hasChat = messages.isNotEmpty;
//       isTyping = false;
//     });
//
//     Navigator.pop(context);
//     _scrollToBottom();
//   }
//
//   // Delete a chat session
//   Future<void> _deleteChatSession(ChatSession session) async {
//     try {
//       // Try to delete from backend first
//       final success = await ApiService.deleteChatSession(session.id);
//
//       if (success || true) { // Continue with local deletion even if backend fails
//         setState(() {
//           chatHistory.removeWhere((s) => s.id == session.id);
//         });
//
//         // If deleting current chat, clear it
//         if (currentChatId == session.id) {
//           setState(() {
//             messages.clear();
//             hasChat = false;
//             currentChatId = null;
//           });
//         }
//
//         // Update local storage
//         await _saveLocalChatHistory();
//       }
//     } catch (e) {
//       debugPrint('Error deleting chat session: $e');
//       // Show error message to user
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to delete chat session. Please try again.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   void _startTypingAnimation(String fullText, int messageIndex) {
//     _fullResponseText = fullText;
//     _currentMessageIndex = messageIndex;
//     _currentDisplayText = '';
//     _typeNextCharacter();
//   }
//
//   void _typeNextCharacter() {
//     if (_currentDisplayText.length < _fullResponseText.length) {
//       setState(() {
//         _currentDisplayText = _fullResponseText.substring(0, _currentDisplayText.length + 1);
//         if (_currentMessageIndex >= 0 && _currentMessageIndex < messages.length) {
//           messages[_currentMessageIndex]["text"] = _currentDisplayText;
//         }
//       });
//
//       _scrollToBottom();
//
//       Future.delayed(const Duration(milliseconds: 30), () {
//         if (mounted) {
//           _typeNextCharacter();
//         }
//       });
//     } else {
//       setState(() {
//         isTyping = false;
//       });
//       _saveCurrentChat();
//     }
//   }
//
//   Future<void> _sendMessage(String userMessage) async {
//     if (userMessage.isEmpty) return;
//
//     currentChatId ??= DateTime.now().millisecondsSinceEpoch.toString();
//
//     setState(() {
//       hasChat = true;
//       messages.add({"role": "user", "text": userMessage});
//       isTyping = true;
//     });
//
//     _scrollToBottom();
//
//     try {
//       final content = [Content.text(userMessage)];
//       final response = await model.generateContent(content);
//
//       setState(() {
//         messages.add({"role": "bot", "text": ""});
//       });
//
//       final responseText = response.text ?? "No response";
//       final messageIndex = messages.length - 1;
//
//       _startTypingAnimation(responseText, messageIndex);
//
//       debugPrint('Gemini response: ${response.text}');
//     } catch (e) {
//       setState(() {
//         messages.add({"role": "bot", "text": "⚠️ Error: $e"});
//         isTyping = false;
//       });
//       _scrollToBottom();
//       _saveCurrentChat();
//     }
//   }
//
//   Widget _buildSideDrawer() {
//     final theme = Theme.of(context);
//     double screenHeight = MediaQuery.of(context).size.height;
//
//     return Padding(
//       padding: EdgeInsets.only(bottom: screenHeight * 0.15),
//       child: Drawer(
//         backgroundColor: theme.colorScheme.onPrimary,
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     theme.colorScheme.primaryContainer,
//                     theme.colorScheme.tertiaryContainer,
//                     theme.colorScheme.primary,
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Image.asset(
//                     'assets/images/app-logo-transp.png',
//                     width: 40,
//                     height: 40,
//                   ),
//                   const SizedBox(width: 12),
//                   Text(
//                     'Chat History',
//                     style: TextStyle(
//                       color: theme.colorScheme.onPrimary,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: fontFamily,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // New Chat Button
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: _createNewChat,
//                   icon: const Icon(Icons.add),
//                   label: const Text('New Chat'),
//                   style: ElevatedButton.styleFrom(
//                     elevation: 4,
//                     backgroundColor: theme.colorScheme.primary,
//                     foregroundColor: theme.colorScheme.onPrimary,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             const Divider(),
//
//             // Chat History List
//             Expanded(
//               child: isLoadingHistory
//                   ? const Center(
//                 child: CircularProgressIndicator(),
//               )
//                   : chatHistory.isEmpty
//                   ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.chat_bubble_outline,
//                       size: 64,
//                       color: theme.colorScheme.outline,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No chat history yet',
//                       style: TextStyle(
//                         color: theme.colorScheme.outline,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//                   : ListView.builder(
//                 itemCount: chatHistory.length,
//                 itemBuilder: (context, index) {
//                   final session = chatHistory[index];
//                   final isCurrentChat = session.id == currentChatId;
//
//                   return Container(
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isCurrentChat
//                           ? theme.colorScheme.tertiaryContainer.withOpacity(0.3)
//                           : null,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor: theme.colorScheme.tertiaryContainer,
//                         child: Icon(
//                           Icons.chat,
//                           color: theme.colorScheme.onPrimary,
//                           size: 20,
//                         ),
//                       ),
//                       title: Text(
//                         session.title,
//                         style: TextStyle(
//                           fontWeight: isCurrentChat ? FontWeight.bold : FontWeight.normal,
//                           color: isCurrentChat
//                               ? theme.colorScheme.primary
//                               : theme.colorScheme.onSurface,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       subtitle: Text(
//                         _formatDate(session.createdAt),
//                         style: TextStyle(
//                           color: theme.colorScheme.outline,
//                           fontSize: 12,
//                         ),
//                       ),
//                       trailing: PopupMenuButton<String>(
//                         surfaceTintColor: theme.colorScheme.tertiaryContainer,
//                         onSelected: (value) {
//                           if (value == 'delete') {
//                             _showDeleteConfirmation(session);
//                           }
//                         },
//                         itemBuilder: (context) => [
//                           const PopupMenuItem(
//                             value: 'delete',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.delete, size: 18),
//                                 SizedBox(width: 8),
//                                 Text('Delete'),
//                               ],
//                             ),
//                           ),
//                         ],
//                         child: Icon(
//                           Icons.more_vert,
//                           color: theme.colorScheme.outline,
//                         ),
//                       ),
//                       onTap: () => _loadChatSession(session),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date).inDays;
//
//     if (difference == 0) {
//       return 'Today';
//     } else if (difference == 1) {
//       return 'Yesterday';
//     } else if (difference < 7) {
//       return '$difference days ago';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
//
//   void _showDeleteConfirmation(ChatSession session) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Chat'),
//           content: Text('Are you sure you want to delete "${session.title}"?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _deleteChatSession(session);
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildTypingIndicator() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             radius: 22,
//             backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.4),
//             child: Image.asset(
//               'assets/images/app-logo-transp.png',
//               width: 50,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Theme.of(context).colorScheme.onPrimary,
//                   Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
//                   Theme.of(context).colorScheme.tertiaryContainer,
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomLeft: Radius.circular(4),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(
//                   width: 40,
//                   height: 20,
//                   child: Row(
//                     children: List.generate(3, (index) {
//                       return AnimatedContainer(
//                         duration: Duration(milliseconds: 300 + (index * 100)),
//                         margin: const EdgeInsets.symmetric(horizontal: 2),
//                         width: 6,
//                         height: 6,
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).colorScheme.onSecondary,
//                           shape: BoxShape.circle,
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//         key: _scaffoldKey,
//         backgroundColor: theme.colorScheme.onPrimary,
//         drawer: _buildSideDrawer(),
//         body: CustomBackground(
//             child: Stack(
//               children: [
//               Image.asset('assets/images/aiSphere.gif',
//               width: screenWidth,
//             ),
//             Positioned(
//               left: screenWidth * 0.37,
//               top: screenHeight * 0.15,
//               child: Text(
//                 'Hello, ${username.split(' ').first}',
//                 style: TextStyle(
//                   color: theme.colorScheme.onPrimary,
//                   fontSize: screenWidth * 0.05,
//                   fontWeight: FontWeight.w900,
//                   fontFamily: fontFamily,
//                 ),
//               ),
//             ),
//
//             // Top Menu Button
//             Positioned(
//               top: MediaQuery.of(context).padding.top + 10,
//               left: 16,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.surface.withOpacity(0.9),
//                   borderRadius: BorderRadius.circular(25),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   icon: Icon(
//                     Icons.menu,
//                     color: theme.colorScheme.primary,
//                     size: 24,
//                   ),
//                   onPressed: () {
//                     _scaffoldKey.currentState?.openDrawer();
//                   },
//                 ),
//               ),
//             ),
//
//             if (hasChat)
//         Padding(
//         padding: const EdgeInsets.fromLTRB(16, 260, 16, 80),
//     child: ListView.builder(
//     controller: _scrollController,
//     itemCount: messages.length + (isTyping && messages.isNotEmpty && messages.last["role"] != "bot" ? 1 : 0),
//     itemBuilder: (context, index) {
//     if (index >= messages.length && isTyping) {
//     return _buildTypingIndicator();
//     }
//     final msg = messages[index];
//     final isUser = msg["role"] == "user";
//     return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4),
//     child: Row(
//     crossAxisAlignment: CrossAxisAlignment.end,
//     mainAxisAlignment: isUser
//     ? MainAxisAlignment.end
//         : MainAxisAlignment.start,
//     children: [
//     if (!isUser) ...[
//     CircleAvatar(
//     radius: 22,
//     backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.4),
//     child: Image.asset(
//     'assets/images/app-logo-transp.png',
//     width: 50,
//     ),
//     ),
//     const SizedBox(width: 8),
//     ],
//     Flexible(
//     child: Container(
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//     gradient: isUser
//     ? LinearGradient(
//     colors: [
//     theme.colorScheme.onPrimary,
//     theme.colorScheme.primaryContainer,
//     theme.colorScheme.primary,
//     ],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     )
//         : LinearGradient(
//     colors: [
//     theme.colorScheme.onPrimary,
//     theme.colorScheme.tertiaryContainer.withOpacity(0.3),
//     theme.colorScheme.tertiaryContainer,
//     ],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     ),
//     borderRadius: BorderRadius.only(
//     topLeft: const Radius.circular(16),
//     topRight: const Radius.circular(16),
//     bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
//     bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
//     ),
//     ),
//     child: Text(
//     msg["text"] ?? "",
//     style: TextStyle(
//     color: theme.colorScheme.onSecondary,
//     fontSize: screenWidth * 0.04,
//     fontWeight: FontWeight.w600,
//     fontFamily: fontFamily,
//     ),
//     ),
//     ),
//     ),
//     if (isUser) const SizedBox(width: 8),
//     ],
//     ),
//     );
//     },
//     ),
//     ),
//
//     /// Bottom Input Bar
//     Align(
//     alignment: Alignment.bottomCenter,
//     child: Padding(
//     padding: EdgeInsets.only(
//     left: 16,
//     right: 16,
//     bottom: screenHeight * 0.12,
//     ),
//     child: Row(
//     children: [
//     SizedBox(width: 55),
//     const SizedBox(width: 8),
//
//     /// Text Field
//     Expanded(
//     child: Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12),
//     decoration: BoxDecoration(
//     color: theme.colorScheme.surface,
//     borderRadius: BorderRadius.circular(50),
//     border: Border.all(
//     color: theme.colorScheme.primary,
//     width: 2,
//     ),
//     boxShadow: [
//     BoxShadow(
//     color: Colors.black.withOpacity(0.05),
//     blurRadius: 6,
//     offset: const Offset(0, 2),
//     ),
//     ],
//     ),
//     child: TextField(
//     controller: _controller,
//     enabled: !isTyping,
//     onTapOutside: (event) {
//     FocusScope.of(context).unfocus();
//     },
//     decoration: InputDecoration(
//     border: InputBorder.none,
//     hintText: isTyping ? "AI is typing..." : "Write here..",
//     hintStyle: TextStyle(
//     color: theme.colorScheme.onSecondary.withOpacity(0.6),
//     ),
//     contentPadding: const EdgeInsets.symmetric(
//     horizontal: 16,
//     vertical: 14,
//     ),
//     suffixIcon: Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//     IconButton(
//     icon: Icon(
//     Icons.mic,
//     color: theme.colorScheme.onPrimary,
//     ),
//     style: IconButton.styleFrom(
//     backgroundColor: isTyping
//     ? theme.colorScheme.tertiaryContainer
//         : theme.colorScheme.primary,
//     ),
//     onPressed: () async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setBool('isLoggedIn', false);
//     Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => LoginScreen()),
//     );
//     },
//     ),
//     IconButton(
//     icon: Icon