// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;

class MenuImage extends StatefulWidget {
  // const MenuImage({super.key});
  final String eImage;
  final String eImageName;
  final Function(String imageUrl, String imageName) onFileChanged;

  MenuImage({
    this.eImage = "",
    this.eImageName = "",
    required this.onFileChanged,
  });

  @override
  State<MenuImage> createState() => _MenuImageState();
}

class _MenuImageState extends State<MenuImage> {
  final ImagePicker _picker = ImagePicker();

  String? imageUrl;
  String? imageName;

  void readExistingImage() {
    print(widget.eImageName);

    setState(() {
      imageUrl = widget.eImage;
      imageName = widget.eImageName;
    });

    // imageName = widget.onFileChanged(1).toString();
    // print(widget.onFileChanged);
    // imageName = widget.imageName;
    // print('existing image=' + widget.eImage);
    // print('existing image file name=' + imageFileName);
  }

  @override
  void initState() {
    // print('file name=' + widget.onFileChanged().indexOf(1).toString());
    // print('onFileChanged=' + this.onFileChanged(1).toString());
    // print('existing image=' + widget.eImage);
    if (widget.eImage != "") {
      readExistingImage();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imageUrl == null)
          Icon(
            Icons.image,
            size: 60,
            color: Colors.grey,
          ),
        if (imageUrl != null)
          InkWell(
            onTap: () {},
            // child: CachedNetworkImage(
            //   imageUrl: imageUrl!,
            //   placeholder: (context, url) => const CircleAvatar(
            //     backgroundColor: Colors.amber,
            //     radius: 150,
            //   ),
            //   imageBuilder: (context, image) => Container(
            //     decoration: BoxDecoration(
            //       image: DecorationImage(
            //         image: image,
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //   ),
            //   errorWidget: (context, url, error) => const Icon(Icons.error),
            // ),
            child: Image.network(
              imageUrl!,
              width: 100,
              height: 100,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return const Text('Image not found');
              },
            ),
          ),
        ElevatedButton(
          onPressed: () {
            _selectPhoto();
          },
          child: Text(
            imageUrl != null ? 'Change image' : 'Select image',
          ),
        ),
      ],
    );
  }

  Future _selectPhoto() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            builder: (context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.camera),
                      title: Text('Camera'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.filter),
                      title: Text('Gallery'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              );
            },
            onClosing: () {},
          );
        });
  }

  Future _pickImage(ImageSource source) async {
    XFile? pickedFile;
    try {
      pickedFile = await _picker.pickImage(source: source);
    } catch (e) {
      print(e);
      return;
    }

    // final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) {
      return;
    }

    var file = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        maxHeight: 700,
        maxWidth: 700);

    if (file == null) {
      return;
    }
    // print('file.path = ' + file.path);

    // await _uploadFile(file.path);

    // // file = (await compressImage(file.path, 35)) as CroppedFile?;
    final tempName = DateTime.now().millisecondsSinceEpoch.toString();

    final croppedfile = await compressImage(file.path, 35, tempName);
    final _file = croppedfile.path;

    // print('_file.path = ' + croppedfile.path);

    await _uploadFile(croppedfile.path, tempName);
  }

  Future<File> compressImage(String path, int quality, String imageName) async {
    // await getTemporaryDirectory().path
    final newPath = p.join((await getTemporaryDirectory()).path,
        '${imageName}.${p.extension(path)}');

    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      newPath,
      quality: quality,
    );

    return result!;
  }

  Future _uploadFile(String path, String _imageName) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: new CircularProgressIndicator(),
        );
      },
    );
    // print(path);

    final ref =
        storage.FirebaseStorage.instance.ref().child('menu').child(_imageName);

    final result = await ref.putFile(File(path));
    final fileUrl = await result.ref.getDownloadURL();

    setState(() {
      imageUrl = fileUrl;
      imageName = _imageName;
      // imageFileName = imageName;
    });

    widget.onFileChanged(fileUrl, _imageName);

    Navigator.of(context).pop();
  }
}
