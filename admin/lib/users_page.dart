import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersPage extends StatefulWidget {
  UsersPage({Key? key}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          final users = snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return User(
              id: document.id,
              firstName: data['firstName'],
              lastName: data['lastName'],
              email: data['email'],
              phoneNumber: data['phoneNumber'],
              approved: data['approved'],
            );
          }).toList();
          return ListView.separated(
            padding: EdgeInsets.all(35),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('S/n'),
                    SizedBox(width: 15),
                    Text('Name'),
                    SizedBox(width: 15),
                    Text('Email'),
                    SizedBox(width: 15),
                    Text('Phone Number'),
                    SizedBox(width: 15),
                    Text('Approved')
                  ],
                );
              }
              index -= 1;
              return Container(
                color: index % 2 == 1 ? Colors.white : Colors.white60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text((1 + index).toString()),
                    SizedBox(width: 15),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                          '${users[index].firstName} ${users[index].lastName}'),
                    ),
                    SizedBox(width: 15),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(users[index].email),
                    ),
                    SizedBox(width: 15),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(users[index].phoneNumber),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Row(
                        children: [
                          Text(users[index].approved.toString()),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert),
                            itemBuilder: (context) {
                              return [
                                const PopupMenuItem<String>(
                                  value: 'approve',
                                  child: Text('Approve'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'deny',
                                  child: Text('Deny'),
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(),
            itemCount: users.length + 1,
          );
        },
      ),
    );
  }
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final bool approved;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.approved,
  });
}
