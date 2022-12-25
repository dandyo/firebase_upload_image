// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:firebase_upload_image/model/menu_model.dart';
import 'package:firebase_upload_image/widgets/menu_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuAddPage extends StatefulWidget {
  const MenuAddPage({super.key});

  @override
  State<MenuAddPage> createState() => _MenuAddPageState();
}

class _MenuAddPageState extends State<MenuAddPage> {
  String imageUrl = "";
  String imageName = "";
  String imageEditUrl = "";
  final controllerName = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Menu"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MenuImage(
              eImage: imageEditUrl,
              onFileChanged: ((imageUrl, imageName) {
                setState(() {
                  this.imageUrl = imageUrl;
                  this.imageName = imageName;
                });
              }),
            ),
            SizedBox(height: 24),
            TextFormField(
              decoration: decoration('Menu Title'),
              controller: controllerName,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final menu = Menu(
                  name: controllerName.text,
                  image: imageUrl,
                  imageFileName: imageName,
                );

                createMenu(menu);
                Navigator.pop(context);
              },
              child: Text('Save'),
              style: buttonStyle,
            ),
          ],
        ),
      ),
    );
  }

  Future createMenu(Menu menu) async {
    final docMenu = FirebaseFirestore.instance.collection('menus').doc();
    menu.id = docMenu.id;

    final json = menu.toJson();
    await docMenu.set(json);
  }

  final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    minimumSize: Size.fromHeight(50),
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  );

  InputDecoration decoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      );
}
