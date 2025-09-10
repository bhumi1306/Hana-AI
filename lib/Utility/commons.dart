import 'package:flutter_secure_storage/flutter_secure_storage.dart';

String fontFamily = 'Cormorant';

// const String baseUrl = 'http://localhost:3000/api' ;
// const String baseUrl = 'http://10.0.2.2:3000/api' ;
const String baseUrl = 'http://192.168.1.29:3000/api' ;

Future<String> getToken() async {
  final storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'token');
  return token ?? '';
}