import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'decorations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
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
    'firstName': FormControl<String>(
      validators: [Validators.required],
    ),
    'lastName': FormControl<String>(
      validators: [Validators.required],
    ),
    'email': FormControl<String>(validators: [
      Validators.email,
      Validators.required,
    ]),
    'phone_number': FormControl<String>(
      validators: [Validators.required, Validators.number],
    ),
  });

  void _onSubmit(FormGroup form) {}

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Scaffold(
          body: SingleChildScrollView(
            child: ReactiveFormBuilder(
              form: () => form,
              builder: (context, form, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Register for event',
                      style: TextStyle(fontSize: 26),
                      textAlign: TextAlign.center,
                    ),
                    ReactiveTextField(
                      formControlName: 'firstName',
                      textInputAction: TextInputAction.next,
                      onSubmitted: () => form.focus('lastName'),
                      validationMessages: (control) => {
                        ValidationMessage.required: 'First name is required'
                      },
                      decoration: Decorations.formInputDecoration.copyWith(
                        labelText: 'First Name',
                        suffixIcon: IconButton(
                          onPressed: () {
                            form.control('firstName').updateValue('');
                          },
                          icon: Icon(Icons.close, size: 20),
                        ),
                      ),
                    ),
                    ReactiveTextField(
                      formControlName: 'lastName',
                      textInputAction: TextInputAction.next,
                      onSubmitted: () => form.focus('email'),
                      validationMessages: (control) =>
                          {ValidationMessage.required: 'Last name is required'},
                      decoration: Decorations.formInputDecoration.copyWith(
                        labelText: 'Last Name',
                        suffixIcon: IconButton(
                          onPressed: () {
                            form.control('lastName').updateValue('');
                          },
                          icon: Icon(Icons.close, size: 20),
                        ),
                      ),
                    ),
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
                    ReactiveTextField(
                      formControlName: 'phone_number',
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.phone,
                      validationMessages: (control) => {
                        ValidationMessage.required: 'Phone number is required'
                      },
                      decoration: Decorations.formInputDecoration.copyWith(
                        labelText: 'Phone Number',
                        suffixIcon: IconButton(
                          onPressed: () {
                            form.control('phone_number').updateValue('');
                          },
                          icon: Icon(Icons.close, size: 20),
                        ),
                      ),
                    ),
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
                                  return Colors.amber;
                                } else
                                  return Colors.amberAccent;
                              },
                            ),
                            foregroundColor: MaterialStateProperty.resolveWith(
                              (states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors.yellow;
                                } else
                                  return Colors.yellowAccent;
                              },
                            ),
                          ),
                          onPressed: form.valid ? () => _onSubmit(form) : null,
                          child: Text('Register'),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
