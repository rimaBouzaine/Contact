import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:gestion_de_contact/sql_helper.dart';
import 'package:gestion_de_contact/update_contact.dart';
import 'package:gestion_de_contact/add_contact.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contacts App',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),

      home: ContactsPage(),
    );
  }
}

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> contacts = [];

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  void _getContacts() async {
    List<Map<String, dynamic>> fetchedContacts = await dbHelper.getContacts();
    setState(() {
      contacts = fetchedContacts;
    });
  }

  void _addContact() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContactPage(),
      ),
    );

    _getContacts();
  }

  void _updateContact(int contactId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateContactPage(contactId: contactId),
      ),
    );

    _getContacts();
  }

  void _deleteContact(int contactId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce contact ?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context)
                    .pop(); // Fermer la boîte de dialogue de confirmation
                int rowsAffected = await dbHelper.deleteContact(contactId);
                print('Deleted $rowsAffected contact(s)');
                _getContacts();
              },
              child: Text('Oui'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Fermer la boîte de dialogue de confirmation
              },
              child: Text('Non'),
            ),
          ],
        );
      },
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (BuildContext context, int index) {
          String photoPath = contacts[index]['photo'];
          File imageFile = File(photoPath);
          return ListTile(
            title:
                Text('${contacts[index]['nom']} ${contacts[index]['prenom']}'),
            subtitle: Text(contacts[index]['tel']),
            //faire un test bch ya5u image inconnue par defaut

            leading:photoPath != "" ? CircleAvatar(
              backgroundImage: FileImage(imageFile),
            ):CircleAvatar(
                backgroundImage: AssetImage('assets/inconnu.png')
            ),

            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: Icon(Icons.call),
                color: Colors.green,
                onPressed: () => _makePhoneCall(contacts[index]['tel']),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteContact(contacts[index]['id']),
              ),
            ]),
            onTap: () => _updateContact(contacts[index]['id']),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addContact,
      ),
    );
  }
}

