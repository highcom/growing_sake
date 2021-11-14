import 'package:flutter/material.dart';

class LoginHome extends StatelessWidget {

  final String user_id;
  LoginHome({Key? key, required this.user_id}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:Center(
        child:Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ようこそ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(user_id),
          ],
        ),
      ),
    );
  }
}