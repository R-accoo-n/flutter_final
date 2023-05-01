import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CinemaApp());
}

class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Final',
      home: CinemaHomePage()
      );
    }
}

class CinemaHomePage extends StatefulWidget {
  const CinemaHomePage({super.key});

  @override
  State<CinemaHomePage> createState() => _CinemaHomePageState();
}

class _CinemaHomePageState extends State<CinemaHomePage> {
  bool isLogined = false;
  String accessToken = '';
  String sessionToken = '';

  void getIsLogined() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool boolValue = prefs.getBool('wasEverLogined') ?? false;
    print(boolValue);
    isLogined = boolValue;
  }

  startLogin() async {
    final response = await http.post(
      Uri.parse('https://fs-mt.qwerty123.tech/api/auth/session'),
      headers: {
        HttpHeaders.acceptLanguageHeader: 'en'
      }
    );
    print(jsonDecode(response.body));
    sessionToken = ((jsonDecode(response.body)['data'])['sessionToken']);
    print(sessionToken);
    getAccessTocken();
  }

  Future<void> getAccessTocken() async {
    var signature = sha256.convert(utf8.encode('${sessionToken}2jukqvNnhunHWMBRRVcZ9ZQ9'));
    final response = await http.post(
        Uri.parse('https://fs-mt.qwerty123.tech/api/auth/token'),
        headers: {
          HttpHeaders.acceptLanguageHeader: 'en',
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.acceptHeader: 'application/json',
        },
        body: jsonEncode(<String, String>{
          'sessionToken' : sessionToken,
          'signature' : signature.toString(),
        }),
    );
    print(jsonDecode(response.body));
    accessToken = ((jsonDecode(response.body)['data'])['sessionToken']);
    print(accessToken);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(accessToken != ''){
      prefs.setBool('wasEverLogined', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!isLogined){
      startLogin();
    }
    return Scaffold(
      appBar: AppBar(
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              isLogined.toString(),
            ),
          ],
        ),
      ),
    );
  }
}
