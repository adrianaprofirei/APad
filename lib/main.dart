import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';

import 'package:flutter_quill/quill_delta.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APad',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QuillEditorPage(),
    );
  }
}

class QuillEditorPage extends StatefulWidget {
  @override
  _QuillEditorPageState createState() => _QuillEditorPageState();
}

class _QuillEditorPageState extends State<QuillEditorPage> {
  late QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('APad'),
        actions: [
          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: _loadFile,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _showSaveDialog,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _clearText,
          ),
        ],
      ),
      body: Column(
        children: [
          QuillToolbar.simple(
            configurations: QuillSimpleToolbarConfigurations(
              controller: _controller,
              sharedConfigurations: const QuillSharedConfigurations(
                locale: Locale('en'),
              ),
            ),
          ),
          Expanded(
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                controller: _controller,
                // readOnly: false,
                sharedConfigurations: const QuillSharedConfigurations(
                  locale: Locale('en'),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showSaveDialog() {
    TextEditingController _fileNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save File'),
          content: TextField(
            controller: _fileNameController,
            decoration: InputDecoration(hintText: 'Enter file name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveFile(_fileNameController.text);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveFile(String fileName) async {
    try {
      String plainText = _controller.document.toPlainText();

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        return;
      }

      if (fileName.isEmpty) {
        fileName = 'untitled';
      }

      String filePath = '$selectedDirectory/$fileName.txt';

      File file = File(filePath);
      await file.writeAsString(plainText);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved to $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save file: $e')),
      );
    }
  }

  Future<void> _loadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        String content = await file.readAsString(encoding: utf8);
        if (!content.endsWith('\n')) {
          content += '\n';
        }


        setState(() {
          _controller = QuillController(
            document: Document.fromDelta(Delta()..insert(content)),
            selection: TextSelection.collapsed(offset: 0),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File loaded successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load file: $e')),
      );
    }
  }

  void _clearText() {
    setState(() {
      _controller = QuillController(
        document: Document.fromDelta(Delta()..insert('\n')),
        selection: TextSelection.collapsed(offset: 0),
      );
    });
  }


}
