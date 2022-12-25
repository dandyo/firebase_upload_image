// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:io';

import 'package:firebase_upload_image/model/menu_model.dart';
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
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('menus');

  List<XFile>? _imageFileList;
  String imageUrl = "";
  String imageEditUrl = "";

  dynamic _pickImageError;

  final controllerName = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );
      if (pickedFile == null) return;

      setState(() {
        print(pickedFile);
        _setImageFileListFromFile(pickedFile);
      });
    } catch (e) {
      print('e' + e.toString());
      setState(() {
        _pickImageError = e;
      });
    }
    // });
  }

  @override
  void initState() {
    super.initState();

    print('_imageFileList=' + _imageFileList.toString());
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

  Widget buildMenu(Menu menu) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
              child: menu.image != ""
                  ? Image.network(
                      menu.image,
                      fit: BoxFit.cover,
                    )
                  : Text('Select image'),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _onImageButtonPressed(ImageSource.gallery,
                          context: context);
                    },
                    child: Text('Select image'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            TextFormField(
              decoration: decoration('Menu Title'),
              controller: controllerName..text = menu.name,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_imageFileList != null) {
                  String uniqueName =
                      DateTime.now().millisecondsSinceEpoch.toString();
                  print('uniqueName=' + uniqueName);

                  Reference referenceRoot = FirebaseStorage.instance.ref();
                  Reference referenceDirImage = referenceRoot.child('menu');

                  Reference referenceUploadImage =
                      referenceDirImage.child(uniqueName);

                  try {
                    print('image path=' + _imageFileList![0].path);
                    await referenceUploadImage
                        .putFile(File(_imageFileList![0].path));
                    setState(() {});
                    imageUrl = await referenceUploadImage.getDownloadURL();
                    print('imageurl=' + imageUrl);
                  } catch (e) {
                    print(e);
                  }

                  final docMenu = FirebaseFirestore.instance
                      .collection('menus')
                      .doc(widget.id);

                  docMenu.update({
                    'name': controllerName.text,
                    'image': imageUrl,
                  });
                } else {
                  imageUrl = "";
                  final docMenu = FirebaseFirestore.instance
                      .collection('menus')
                      .doc(widget.id);

                  docMenu.update({
                    'name': controllerName.text,
                  });
                }

                // final docMenu = FirebaseFirestore.instance
                //     .collection('menus')
                //     .doc(widget.id);

                // docMenu.update({
                //   'name': controllerName.text,
                //   'image': imageUrl,
                // });

                Navigator.pop(context);
              },
              child: Text('Update'),
              style: buttonStyle,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final docUser = FirebaseFirestore.instance
                    .collection('menus')
                    .doc(widget.id);
                docUser.delete();

                Navigator.pop(context);
              },
              child: Text('Delete'),
              style: buttonStyle,
            ),
          ],
        ),
      );

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

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);
