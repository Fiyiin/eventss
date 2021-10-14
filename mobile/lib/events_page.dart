import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mobile/main.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final Stream<QuerySnapshot> _eventsStream =
      FirebaseFirestore.instance.collection('events').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text('Events'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(),
                ),
                (route) => false),
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Container(
        color: Colors.white54,
        child: StreamBuilder(
          stream: _eventsStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text("Loading"));
            }
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['name']),
                    tileColor: Colors.grey[350],
                    minVerticalPadding: 20,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailScreen(
                            event: Event(
                              data['name'],
                              document.id,
                              data['registered_users'],
                              data['checked_in_users'],
                            ),
                          ),
                        )),
                  );
                }).toList(),
              );
            } else {
              return Center(
                child: Text('There are no events yet'),
              );
            }
          },
        ),
      ),
    );
  }
}

class Event {
  final String name;
  final String id;
  final int registeredUsers;
  final int checkedInUsers;

  Event(this.name, this.id, this.registeredUsers, this.checkedInUsers);
}

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  final Event event;

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  FirebaseFunctions functions = FirebaseFunctions.instance;
  bool _isLoading = false;

  Future<void> checkIn(String eventId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      HttpsCallable callable = functions.httpsCallable('checkInUser');
      await callable({'eventId': eventId});
    } catch (e) {
      rethrow;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: Text(
                    'Total Registered Users: ${widget.event.registeredUsers}'),
                subtitle:
                    Text('Checked In Users: ${widget.event.checkedInUsers}'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final res = await FlutterBarcodeScanner.scanBarcode(
                    '#FFD859',
                    'Cancel',
                    true,
                    ScanMode.QR,
                  );
                  if (res == 'Your registration has been approved!') {
                    await checkIn(widget.event.id);
                    Navigator.pop(context);
                  }
                },
                child: _isLoading
                    ? CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white,
                      )
                    : Text('Check In'),
              )
            ],
          )),
    );
  }
}
