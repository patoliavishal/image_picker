import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Picker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'File Picker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<PlatformFile>? _paths;
  final FileType pickingType = FileType.image;
  final bool multiPick = false;
  String? extension;

  void _pickFiles() async {
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: pickingType,
        allowMultiple: multiPick,
        allowedExtensions: (extension?.isNotEmpty ?? false)
            ? extension?.replaceAll(' ', '').split(',')
            : null,
      ))
          ?.files;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Unsupported operation' + e.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            kIsWeb
                ? _imageDisplayForWeb(_paths != null && _paths![0].bytes != null
                    ? _paths![0].bytes!
                    : Uint8List(0))
                : _imageDisplayForOther(_paths != null ? _paths![0].path! : ''),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => _pickFiles(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(multiPick ? 'Pick files' : 'Pick file',
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _imageDisplayForWeb(Uint8List imagePath) {
    return Image.memory(imagePath,
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.5,
        errorBuilder: (context, url, error) => const Icon(Icons.error),
        fit: BoxFit.cover);
  }

  _imageDisplayForOther(String imagePath) {
    return Image.file(File(imagePath),
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.5,
        errorBuilder: (context, url, error) => const Icon(Icons.error),
        fit: BoxFit.fill);
  }
}
