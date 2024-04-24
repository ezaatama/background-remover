import 'dart:io';
import 'dart:typed_data';

import 'package:background_remover/background_remover.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Background Remove',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Background Remover'),
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
  Uint8List? image;
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();
  XFile? file;

  Future<void> _removeImage() async {
    setState(() {
      image = null;
    });

    if (file != null) {
      setState(() {
        isLoading = true;
      });
      final Uint8List imageBytes = await file!.readAsBytes();
      image = await removeBackground(imageBytes: imageBytes);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectFile() async {
    setState(() {
      image = null;
    });
    file = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        isLoading = true;
      });
      final Uint8List imageBytes = await file!.readAsBytes();

      setState(() {
        image = imageBytes;
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveImage() async {
    if (image != null) {
      Uint8List imageInUnit8List = image!;
      final tempDir = await getExternalStorageDirectory();
      final String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.png';
      final String filePath = '${tempDir!.path}/$fileName';

      File file = await File(filePath).create();
      debugPrint('$file');

      file.writeAsBytesSync(imageInUnit8List);
      debugPrint('file tersimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (image != null) Image.memory(image!),
            if (isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await _selectFile();
                    },
                    child: const Text('Ambil Gambar')),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await _removeImage();
                    },
                    child: const Text('Hapus Background')),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await _saveImage();
                    },
                    child: const Text('Simpan Gambar')),
              ],
            ),
          ],
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: _pickImage,
      //   child: const Icon(Icons.image),
      // ),
    );
  }
}
