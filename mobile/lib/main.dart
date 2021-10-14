import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile/events_page.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'decorations.dart';

void main() async {
  runApp(MyApp());
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eventss',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final form = FormGroup({
    'email': FormControl<String>(validators: [
      Validators.email,
      Validators.required,
    ]),
    'password': FormControl<String>(
      validators: [Validators.required],
    ),
  });

  Future<void> _onSubmit(FormGroup form) async {
    final email = form.value['email'] as String;
    final password = form.value['password'] as String;

    if (email.isNotEmpty && password == 'admin') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => EventsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: Text(
              'Admin Login',
            ),
          ),
          body: ReactiveFormBuilder(
            form: () => form,
            builder: (context, form, child) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20),
                    ReactiveTextField(
                      formControlName: 'email',
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      onSubmitted: () => form.focus('password'),
                      validationMessages: (control) =>
                          {ValidationMessage.required: 'Email is required'},
                      decoration: Decorations.formInputDecoration.copyWith(
                        labelText: 'Email',
                        suffixIcon: IconButton(
                          onPressed: () {
                            form.control('email').updateValue('');
                          },
                          icon: Icon(Icons.close, size: 20),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    ReactiveTextField(
                      formControlName: 'password',
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      validationMessages: (control) =>
                          {ValidationMessage.required: 'Password is required'},
                      decoration: Decorations.formInputDecoration.copyWith(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            form.control('password').updateValue('');
                          },
                          icon: Icon(Icons.close, size: 20),
                        ),
                      ),
                    ),
                    SizedBox(height: 60),
                    ReactiveFormConsumer(
                      builder: (context, form, child) {
                        return TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 20.0,
                            ),
                          ).copyWith(
                            backgroundColor: MaterialStateProperty.resolveWith(
                              (states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors.amber.withOpacity(0.38);
                                } else
                                  return Colors.amber;
                              },
                            ),
                            foregroundColor: MaterialStateProperty.resolveWith(
                              (states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors.white54;
                                } else
                                  return Colors.white;
                              },
                            ),
                          ),
                          onPressed: form.valid ? () => _onSubmit(form) : null,
                          child: Text(
                            'Login',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
