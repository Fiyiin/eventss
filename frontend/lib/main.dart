import 'package:cloud_functions/cloud_functions.dart';
import 'package:eventss/decorations.dart';
import 'package:eventss/succes_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());

  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventss',
      theme: ThemeData(
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
  bool _isLoading = false;

  FirebaseFunctions functions = FirebaseFunctions.instance;
  final form = FormGroup({
    'first_name': FormControl<String>(
      validators: [Validators.required],
    ),
    'last_name': FormControl<String>(
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

  Future<void> register(NewUser user) async {
    try {
      setState(() {
        _isLoading = true;
      });
      HttpsCallable callable = functions.httpsCallable('createUser');
      final res = await callable(
        NewUser(
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                phoneNumber: user.phoneNumber)
            .toJson(),
      );
    } catch (e) {
      rethrow;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onSubmit(FormGroup form) async {
    await register(
      NewUser(
        firstName: form.value['first_name'] as String,
        lastName: form.value['last_name'] as String,
        email: form.value['email'] as String,
        phoneNumber: form.value['phone_number'] as String,
      ),
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SuccessPage()),
    );
  }

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
                      formControlName: 'first_name',
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
                      formControlName: 'last_name',
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
                          child: _isLoading
                              ? CircularProgressIndicator.adaptive()
                              : Text(
                                  'Register',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
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

class NewUser {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  NewUser({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, Object?> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
