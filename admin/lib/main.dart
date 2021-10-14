import 'package:admin/decorations.dart';
import 'package:admin/users_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());

  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'Eventss',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: MyHomePage(),
      );
    });
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
        MaterialPageRoute(
          builder: (context) => UsersPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Admin Login',
              style: TextStyle(fontSize: 26),
              textAlign: TextAlign.center,
            ),
          ),
          body: SingleChildScrollView(
            child: ReactiveFormBuilder(
              form: () => form,
              builder: (context, form, child) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 7.h),
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
                      SizedBox(height: 5.h),
                      ReactiveTextField(
                        formControlName: 'password',
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        validationMessages: (control) => {
                          ValidationMessage.required: 'Password is required'
                        },
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
                      SizedBox(height: 5.h),
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
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                (states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Colors.amber.withOpacity(0.38);
                                  } else
                                    return Colors.amber;
                                },
                              ),
                              foregroundColor:
                                  MaterialStateProperty.resolveWith(
                                (states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Colors.white54;
                                  } else
                                    return Colors.white;
                                },
                              ),
                            ),
                            onPressed:
                                form.valid ? () => _onSubmit(form) : null,
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
          ),
        );
      },
    );
  }
}
