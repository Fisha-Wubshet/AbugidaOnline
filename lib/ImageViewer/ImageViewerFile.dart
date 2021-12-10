import 'dart:io';

import 'package:photo_view/photo_view.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewerFile extends StatefulWidget {
  final title;
  final path;

  ImageViewerFile({
    this.title,
    this.path,
  });
  @override
  _ImageViewerFileState createState() => _ImageViewerFileState();
}
class _ImageViewerFileState extends State<ImageViewerFile> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title}"),
      ),
      // add this body tag with container and photoview widget
      body: Container(
          child: PhotoView(
            imageProvider: FileImage(File('${widget.path}')),
          )),

    );
  }
}