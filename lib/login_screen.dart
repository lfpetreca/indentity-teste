import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  static String currentIpv4 = '10.1.12.46';
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  dynamic _apiResponse;
  dynamic _accessToken;

  void _auth() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    final String tokenUrl = 'http://$currentIpv4:5000/connect/token';
    final Object body = {
      'client_id': 'api_app',
      'grant_type': 'password',
      'client_secret': '11fad4d5-d551-48ab-873e-21f2da19be1c',
      'username': username,
      'password': password,
    };

    print('BODY => $body');

    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
      encoding: Encoding.getByName('utf-8'),
    );

    setState(() {
      print("RESPONSE_STATUS_CODE => ${response.statusCode}");
      if (response.statusCode == 200) {
        dynamic resBody = json.decode(response.body);        
        _accessToken = resBody?['access_token'];
        print("BODY_RESPONSE => $_accessToken");
        _checkInfo();
      }
    });
  }

  void _checkInfo() async {
    final String url = 'http://$currentIpv4:5002/ufs'; //juridico/notificacao';    
    print("ACCESS_TOKEN => $_accessToken");

    Map<String, String> headers = {
      'Authorization': 'Bearer $_accessToken',
    };

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    setState(() {
      print("RESPONSE_STATUS_CODE => ${response.statusCode}");
      if (response.statusCode == 200) {
        dynamic resBody = json.decode(response.body);
        _apiResponse = resBody;
        print("BODY_RESPONSE => $_apiResponse");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 72),
                TextField(
                  controller: _usernameController,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Usuário'),
                  ),
                ),
                const SizedBox(width: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    label: Text('Senha'),
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        //Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _auth,
                      child: const Text('Entrar'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
