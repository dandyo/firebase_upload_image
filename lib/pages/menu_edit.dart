// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:io';

import 'package:firebase_upload_image/model/menu_model.dart';
import 'package:firebase_upload_image/widgets/menu_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MenuEditPage extends StatefulWidget {
  final String id;

  const MenuEditPage({super.key, required this.id});

  @override
  State<MenuEditPage> createState() => _MenuEditPageState();
}

class _MenuEditPageState extends State<MenuEditPage> {
  // List<XFile>? _imageFileList;
  // File? image;
  String imageUrl = "";
  String imageName = "";
  String imageEditUrl = "";
  // XFile? imageEditUrl;

  final controllerName = TextEditingController();

  @override
  void initState() {
    // _buildImage();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Menu"),
        ),
        body: FutureBuilder<Menu?>(
          future: readMenu(widget.id),
          builder: ((context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else if (snapshot.hasData) {
              final menu = snapshot.data;

              return menu == null
                  ? Center(
                      child: Text('Menu not found.'),
                    )
                  : buildMenu(menu);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
        ));
  }

  Widget buildMenu(Menu menu) {
    imageEditUrl = menu.image;

    return Padding(
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
          SizedBox(height: 12),
          TextFormField(
            decoration: decoration('Menu Title'),
            controller: controllerName..text = menu.name,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final docMenu =
                  FirebaseFirestore.instance.collection('menus').doc(widget.id);

              docMenu.update({
                'name': controllerName.text,
                'image': this.imageUrl,
                'imageFilename': this.imageName,
              });

              Navigator.pop(context);
            },
            child: Text('Update'),
            style: buttonStyle,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final docUser =
                  FirebaseFirestore.instance.collection('menus').doc(widget.id);
              docUser.delete();

              Navigator.pop(context);
            },
            child: Text('Delete'),
            style: buttonStyle,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              print(menu.imageFileName);

              final storageRef = FirebaseStorage.instance.ref();

              final desertRef = storageRef.child("menu/${menu.imageFileName}");
              await desertRef.delete();

              Navigator.pop(context);
            },
            child: Text('Delete image'),
            style: buttonStyle,
          ),
        ],
      ),
    );
  }

  Future<Menu?> readMenu(String id) async {
    final docUser =
        FirebaseFirestore.instance.collection('menus').doc(id.toString());
    final snapshot = await docUser.get();

    if (snapshot.exists) {
      return Menu.fromJson(snapshot.data()!);
    } else {
      return null;
    }
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
