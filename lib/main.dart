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
  List<Map<String, dynamic>> filteredContacts = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  void _getContacts() async {
    List<Map<String, dynamic>> fetchedContacts = await dbHelper.getContacts();
    currentLetter = ''; // Reset the currentLetter variable

    // Convert the QueryResultSet to a modifiable list
    List<Map<String, dynamic>> contactsList = fetchedContacts.toList();

    // Sort the list of contacts
    contactsList.sort((a, b) => a['nom'].toLowerCase().compareTo(b['nom'].toLowerCase()));

    setState(() {
      contacts = contactsList;
      filteredContacts = contactsList;
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

  String currentLetter = '';
  void _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _filterContacts(String query) {
    List<Map<String, dynamic>> filteredList = contacts.where((contact) {
      final String fullName =
      '${contact['nom']} ${contact['prenom']} ${contact['tel']}'.toLowerCase();
      return fullName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredContacts = filteredList;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body:Column(
          children: [
      Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onChanged: _filterContacts,
        decoration: InputDecoration(
          labelText: 'Rechercher un contact',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
    ),
    Expanded(child: ListView.builder(
        itemCount: filteredContacts.length,
        itemBuilder: (BuildContext context, int index) {
          String photoPath = filteredContacts[index]['photo'];
          File imageFile = File(photoPath);

          // Get the first letter of the contact's name
          String firstLetter = filteredContacts[index]['nom'][0].toUpperCase();

          // Check if the first letter is different from the current letter
          bool isNewLetter = firstLetter != currentLetter;

          // Update the current letter if it's a new letter
          if (isNewLetter) {
            currentLetter = firstLetter;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the header if it's a new letter
              if (isNewLetter)
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    currentLetter,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ListTile(
                title: Text(
                    '${filteredContacts[index]['nom']} ${filteredContacts[index]['prenom']}'),
                subtitle: Text(filteredContacts[index]['tel']),
                //faire un test bch ya5u image inconnue par defaut

                leading: photoPath != ""
                    ? CircleAvatar(
                        backgroundImage: FileImage(imageFile),
                      )
                    : CircleAvatar(
                        backgroundImage: AssetImage('assets/inconnu.png')),

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
              ),
            ],
          );
        },
      ))]),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addContact,
      ),
    );
  }
}
