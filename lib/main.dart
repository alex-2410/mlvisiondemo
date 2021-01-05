import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() {
  runApp(MLkitwithFlutter());
}

class MLkitwithFlutter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MLkit with Flutter',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'MLkit with Flutter'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File image;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _openCamera(BuildContext context) async {
    image = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {});
    Navigator.of(context).pop();
  }

  _openGallery(BuildContext context) async {
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {});
    Navigator.of(context).pop();
  }

  Widget _getimage() {
    if (image == null) return Text('No Image selected !');
    return Image.file(image, width: 400, height: 400);
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select an image'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text("Camera"),
                    onTap: () {
                      _openCamera(context);
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  GestureDetector(
                    child: Text("Gallery"),
                    onTap: () {
                      _openGallery(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> detectLabel() async {
    final FirebaseVisionImage visionimage = FirebaseVisionImage.fromFile(image);
    final ImageLabeler labeldetector = FirebaseVision.instance
        .imageLabeler(ImageLabelerOptions(confidenceThreshold: 0.50));
    final List<ImageLabel> labels =
        await labeldetector.processImage(visionimage);

    for (ImageLabel label in labels) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(label.text +
              " : " +
              (label.confidence * 100).toStringAsFixed(3) +
              "%")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _getimage(),
            OutlineButton(
              child: Text("Select an image"),
              onPressed: () => _showChoiceDialog(context),
              highlightedBorderColor: Colors.indigo,
              splashColor: Colors.indigo,
            ),
            RaisedButton(
              color: Colors.indigo,
              splashColor: Colors.orange,
              elevation: 5.0,
              child: Text("Predict!"),
              onPressed: () async {
                //String file = await getImageFileFormatAssets('$imagename');
                //setState(() {
                //imagePath = file;
                //});
                if (image == null) {
                  _scaffoldKey.currentState.showSnackBar(
                      SnackBar(content: Text("Please select an image")));
                } else {
                  detectLabel();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Future<String> getImageFileFormatAssets(String path) async {
//   final bytedata = await rootBundle.load('lib/assets/$path');
//   final Directory extdir = await getApplicationDocumentsDirectory();
//   final String dirpath = '${extdir.path}/Pictures/flutter_vision';
//   await Directory(dirpath).create(recursive: true);
//   final String filepath =
//       '$dirpath/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
//   final file = File(filepath);
//   await file.writeAsBytes(bytedata.buffer
//       .asUint8List(bytedata.offsetInBytes, bytedata.lengthInBytes));
//   return filepath;
// }
