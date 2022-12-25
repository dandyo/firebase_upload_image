// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_upload_image/model/menu_model.dart';
import 'package:firebase_upload_image/pages/menu_add.dart';
import 'package:firebase_upload_image/pages/menu_edit.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

// void main() {
//   runApp(const MyApp());
// }
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter - Upload Image to Firebase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter - Upload Image to Firebase'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<List<Menu>>(
        stream: readMenus(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (snapshot.hasData) {
            final menus = snapshot.data!;

            return ListView(
              itemExtent: 80.0,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: 8,
                bottom: 8,
              ),
              children: menus.map(buildMenu).toList(),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MenuAddPage()))
              .then((value) {
            setState(() {});
          });
        },
      ),
    );
  }

  Widget buildMenu(Menu menu) => ListTile(
        title: Text(menu.name),
        visualDensity: VisualDensity(vertical: 3),
        leading: menu.image != ""
            ? _sizedContainer(CachedNetworkImage(
                imageUrl: menu.image,
                placeholder: (context, url) => const CircleAvatar(
                  backgroundColor: Colors.amber,
                  radius: 150,
                ),
                imageBuilder: (context, image) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ))
            : CircleAvatar(
                child: Text('I'),
              ),
        onTap: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MenuEditPage(id: menu.id)))
              .then((value) {
            setState(() {});
          });
        },
      );

  Widget _sizedContainer(Widget child) {
    return SizedBox(
      width: 80.0,
      height: 80.0,
      child: Center(child: child),
    );
  }

  Stream<List<Menu>> readMenus() => FirebaseFirestore.instance
      .collection('menus')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Menu.fromJson(doc.data())).toList());
}
