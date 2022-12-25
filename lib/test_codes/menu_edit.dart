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

  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;

  final controllerName = TextEditingController();
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context, bool isMultiImage = false}) async {
    // await _displayPickImageDialog(context!,
    //     (double? maxWidth, double? maxHeight, int? quality) async {
    // OnPickImageCallback onPick(1200, 800, 80);
    // double maxWidth = 1200;
    // double maxHeight = 800;
    // int quality = 70;

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

  // Future<void> _displayPickImageDialog(
  //     BuildContext context, OnPickImageCallback onPick) async {
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Add optional parameters'),
  //           content: Text('test'),
  //           actions: <Widget>[
  //             TextButton(
  //               child: const Text('CANCEL'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //             TextButton(
  //                 child: const Text('PICK'),
  //                 onPressed: () {
  //                   final double? width = 1000;
  //                   final double? height = 800;
  //                   final int? quality = 100;

  //                   onPick(width, height, quality);
  //                   Navigator.of(context).pop();
  //                 }),
  //           ],
  //         );
  //       });
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    // if (_controller != null) {
    //   _controller!.setVolume(0.0);
    //   _controller!.pause();
    // }
    super.deactivate();
  }

  @override
  void dispose() {
    // _disposeVideoController();
    // maxWidthController.dispose();
    // maxHeightController.dispose();
    // qualityController.dispose();
    super.dispose();
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
              child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
                  ? FutureBuilder<void>(
                      future: retrieveLostData(),
                      builder:
                          (BuildContext context, AsyncSnapshot<void> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                            return const Text(
                              'You have not yet picked an image.',
                              textAlign: TextAlign.center,
                            );
                          case ConnectionState.done:
                            return _handlePreview();
                          default:
                            if (snapshot.hasError) {
                              return Text(
                                'Pick image/video error: ${snapshot.error}}',
                                textAlign: TextAlign.center,
                              );
                            } else {
                              return const Text(
                                'You have not yet picked an image.',
                                textAlign: TextAlign.center,
                              );
                            }
                        }
                      },
                    )
                  : _handlePreview(),
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

  Widget _handlePreview() {
    print('_handlePreview');
    return _previewImages();
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileList != null) {
      print('return Semantics');
      // print(_imageFileList![0].path);

      return Semantics(
        label: 'image_picker_example_picked_images',
        child: ListView.builder(
          key: UniqueKey(),
          itemBuilder: (BuildContext context, int index) {
            // Why network for web?
            // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
            return Semantics(
              label: 'image_picker_example_picked_image',
              child: kIsWeb
                  ? Image.network(_imageFileList![index].path)
                  : Image.file(File(_imageFileList![index].path)),
            );
          },
          itemCount: _imageFileList!.length,
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      // if (response.type == RetrieveType.video) {
      //   isVideo = true;
      //   await _playVideo(response.file);
      // } else {
      //   isVideo = false;
      setState(() {
        if (response.files == null) {
          _setImageFileListFromFile(response.file);
        } else {
          _imageFileList = response.files;
        }
      });
      // }
    } else {
      _retrieveDataError = response.exception!.code;
    }
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

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);
