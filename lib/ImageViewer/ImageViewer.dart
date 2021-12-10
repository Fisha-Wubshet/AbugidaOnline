import 'package:photo_view/photo_view.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewer extends StatefulWidget {
  final title;
  final link;

  ImageViewer({
    this.title,
    this.link,
  });
  @override
  _ImageViewerState createState() => _ImageViewerState();
}
class _ImageViewerState extends State<ImageViewer> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title}"),
      ),
      // add this body tag with container and photoview widget
      body: Container(
          child: PhotoView(
            imageProvider: NetworkImage("${widget.link}"),
          )),

    );
  }
}