import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class PhotoUploadGallery extends StatefulWidget {
  final int colCount;
  final bool takePhotoOnInit;
  final String prefix;
  final ValueChanged<Map<String, String>> onUpload;

  PhotoUploadGallery({
    this.colCount = 3,
    this.takePhotoOnInit = false,
    required this.prefix,
    required this.onUpload,
  });

  @override
  State<StatefulWidget> createState() => new _PhotoUploadGalleryState();
}

class _PhotoUploadGalleryState extends State<PhotoUploadGallery> {
  bool _isBusy = false;
  final ImagePicker _picker = ImagePicker();
  List<XFile> photos = [];
  Map<String, String> imageUrls = {};

  @override
  void initState() {
    super.initState();
    if (widget.takePhotoOnInit) {
      _takePhoto();
    }
  }

  void _takePhoto() {
    _picker.pickImage(source: ImageSource.camera).then((XFile? photo) async {
      if (photo != null) {
        setState(() {
          _isBusy = true;
        });
        imageUrls[photo.path] = "";
        photos.add(photo);
        await _uploadPhoto(photo);
        setState(() {
          _isBusy = false;
        });
      }
    });
  }

  void _chooseFromGallery() {
    _picker.pickImage(source: ImageSource.gallery).then((XFile? photo) async {
      if (photo != null) {
        setState(() {
          _isBusy = true;
        });
        imageUrls[photo.path] = "";
        photos.add(photo);
        await _uploadPhoto(photo);
        setState(() {
          _isBusy = false;
        });
      }
    });
  }

  Future<void> _uploadPhoto(XFile image) async {
    String pathName = widget.prefix +
        '/' +
        Path.basename(image.path).replaceAll("[\\W]|_", "");
    try {
      await FirebaseStorage.instance.ref(pathName).putFile(File(image.path));
      imageUrls[image.path] =
          await FirebaseStorage.instance.ref(pathName).getDownloadURL();
      widget.onUpload(imageUrls);
    } on FirebaseException catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File upload error. ' + (e.message ?? ""))));
      print(e);
    }
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.all(2),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
          SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .apply(color: Theme.of(context).colorScheme.onPrimary))
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      color: Colors.black12,
      child: GridView.count(
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          crossAxisCount: widget.colCount,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(2),
          // Generate 100 widgets that display their index in the List.
          children: <Widget>[
                _buildButton(Icons.add_a_photo, "Take Photo", () {
                  _takePhoto();
                }),
                _buildButton(Icons.add_photo_alternate, "Add From Gallery", () {
                  _chooseFromGallery();
                }),
              ] +
              List.generate(photos.length, (index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                        color: Colors.grey,
                        margin: EdgeInsets.all(2),
                        child: Image(
                          fit: BoxFit.cover,
                          image: FileImage(File(photos[index].path)),
                        )),
                    (imageUrls[photos[index].path]?.isNotEmpty ?? false)
                        ? Positioned(
                            bottom: 4,
                            right: 4,
                            child:
                                Icon(Icons.check_circle, color: Colors.green))
                        : Positioned(
                            bottom: 4,
                            right: 4,
                            child: Icon(Icons.check_circle_outline,
                                color: Colors.grey))
                  ],
                );
              })),
    );
  }
}
