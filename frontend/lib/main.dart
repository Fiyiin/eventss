import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:eventss/decorations.dart';
import 'package:eventss/succes_page.dart';
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
  CollectionReference eventsRef =
      FirebaseFirestore.instance.collection('events');
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
    'event': FormControl<Event>(
      validators: [Validators.required],
    ),
  });

  Future<void> register(NewUser user) async {
    try {
      setState(() {
        _isLoading = true;
      });
      HttpsCallable callable = functions.httpsCallable('createUser');
      await callable(
        NewUser(
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phoneNumber: user.phoneNumber,
          eventId: user.eventId,
        ).toJson(),
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
        eventId: (form.value['event'] as Event).id,
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
          appBar: AppBar(
            title: Text(
              'Eventss',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: ReactiveFormBuilder(
              form: () => form,
              builder: (context, form, child) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 7.h),
                      Text(
                        'Register for an event',
                        style: TextStyle(fontSize: 26),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5.h),
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
                      SizedBox(height: 5.h),
                      ReactiveTextField(
                        formControlName: 'last_name',
                        textInputAction: TextInputAction.next,
                        onSubmitted: () => form.focus('email'),
                        validationMessages: (control) => {
                          ValidationMessage.required: 'Last name is required'
                        },
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
                      SizedBox(height: 5.h),
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
                      SizedBox(height: 5.h),
                      FutureBuilder(
                        future: eventsRef.get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Couldn\'t fetch events'));
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: Text("Loading..."));
                          }
                          final events = snapshot.data!.docs
                              .map(
                                (DocumentSnapshot document) => Event(
                                  document.id,
                                  (document.data()!
                                      as Map<String, dynamic>)['name'],
                                ),
                              )
                              .toList();
                          return ReactiveDropdownField(
                            formControlName: 'event',
                            validationMessages: (control) => {
                              ValidationMessage.required:
                                  'this a required field'
                            },
                            items: events.map<DropdownMenuItem<Event>>((value) {
                              return DropdownMenuItem(
                                child: Text(value.name),
                                value: value,
                              );
                            }).toList(),
                            decoration:
                                Decorations.formInputDecoration.copyWith(
                              labelText: 'Event',
                              hintText: 'Select Event',
                            ),
                          );
                        },
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
                            child: _isLoading
                                ? CircularProgressIndicator.adaptive()
                                : Text(
                                    'Register',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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

class NewUser {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String eventId;

  NewUser({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.eventId,
  });

  Map<String, Object?> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'eventId': eventId,
    };
  }
}

class Event {
  final String id;
  final String name;

  Event(this.id, this.name);
}
