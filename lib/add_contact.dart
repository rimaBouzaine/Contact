import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:gestion_de_contact/sql_helper.dart';

class AddContactPage extends StatefulWidget {
  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  TextEditingController _nomController = TextEditingController();
  TextEditingController _prenomController = TextEditingController();
  TextEditingController _telController = TextEditingController();
  TextEditingController _photoController = TextEditingController();

  DatabaseHelper dbHelper = DatabaseHelper.instance;

  void _saveContact() async {
    String nom = _nomController.text;
    String prenom = _prenomController.text;
    String tel = _telController.text;

    // Validation du champ "Nom"
    if (nom.isEmpty || !RegExp(r'^[a-zA-Z]+$').hasMatch(nom)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Champ obligatoire'),
            content: Text('Le champ "Nom" est obligatoire et doit contenir des lettres.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Validation du champ "Prénom"
    if (prenom.isEmpty || !RegExp(r'^[a-zA-Z]+$').hasMatch(prenom)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Champ obligatoire'),
            content: Text('Le champ "Prénom" est obligatoire et doit contenir des lettres.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Validation du champ "Téléphone"
    if (tel.isEmpty  || !RegExp(r'^\d+$').hasMatch(tel)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Champ obligatoire'),
            content: Text('Le champ "Téléphone" est obligatoire et doit contenir chiffres.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Reste du code pour sauvegarder le contact
    Map<String, dynamic> newContact = {
      'nom': nom,
      'prenom': prenom,
      'tel': tel,
      'photo': _selectedImage != null ? _selectedImage!.path : '',
    };
    await dbHelper.insertContact(newContact);
    Navigator.pop(context);
  }



  void _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Widget _buildImage() {
    if (_selectedImage != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Stack(children:[CircleAvatar(backgroundImage: FileImage(_selectedImage!),radius: 55,),
            Positioned(
              bottom: 5,
              right: 5,
              child: IconButton(
                onPressed: _selectImage,
                icon: Icon(Icons.add),
              ),
            ),
          ] ),
        ),
      );
    } else {
      return Center(
          child: Stack(children: [
        CircleAvatar(
          backgroundImage: AssetImage('assets/inconnu.png'),
          radius: 55,
        ),
        Positioned(
          bottom: -8,
          right: -8,
          child: IconButton(
            onPressed: _selectImage,
            icon: Icon(Icons.add,size: 40,),
          ),
        ),
      ]));
    }
  }

  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //err : button overflow flutter by 53 pixels
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Nouveau Contact'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            SizedBox(height: 15,),
            Row(children: [
              Icon(Icons.person_outlined,color: Colors.grey, ),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))
                    ),

                  ),
                ),
              ),
            ],),
            SizedBox(height: 15,),
            Row(children: [
              SizedBox(width: 32),
              Expanded(
                child: TextFormField(
                  controller: _prenomController,
                  decoration: InputDecoration(
                    labelText: 'Prénom',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))
                    ),

                  ),
                ),
              ),
            ],),
            SizedBox(height: 15,),
            Row(children: [
              Icon(Icons.call,color: Colors.grey, ),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: _telController,
                  decoration: InputDecoration(
                    labelText: 'Téléphone',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))
                    ),

                  ),
                ),
              ),
            ],),


            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveContact,
                  child: Text('Enregistrer'),
                ),
                ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Annuler'),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
