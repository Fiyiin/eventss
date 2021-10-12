import 'package:flutter/material.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            children: [
              Icon(
                Icons.celebration,
                color: Colors.amber,
                size: 100,
              ),
              Text('Thank you for registering!'),
              Text(
                  'An email containing the next steps has been sent to your email address'),
            ],
          ),
        ),
      ),
    );
  }
}
