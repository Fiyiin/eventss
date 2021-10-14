import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  final int registeredUsers;
  final int checkedInUsers;

  Event(this.name, this.registeredUsers, this.checkedInUsers);
}

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  final Event event;

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: Text('Total Registered Users: ${event.registeredUsers}'),
                subtitle: Text('Checked In Users: ${event.checkedInUsers}'),
              ),
              ElevatedButton(
                onPressed: () => null,
                child: Text('Check In'),
              )
            ],
          )),
    );
  }
}
