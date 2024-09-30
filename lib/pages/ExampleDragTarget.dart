import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExampleDragTarget extends StatefulWidget {
  const ExampleDragTarget({Key? key}) : super(key: key);

  @override
  State<ExampleDragTarget> createState() => DropPageState();
}

class DropPageState extends State<ExampleDragTarget> {
  XFile? file;
  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) async {
        XFile _file = detail.files.last;
        final filePath = _file.path;
        if (filePath.endsWith(".png") ||
            filePath.endsWith(".jpg") ||
            filePath.endsWith(".jpeg") ||
            filePath.endsWith(".webp") ||
            filePath.endsWith(".svg")) {
          setState(() {
            file = _file;
          });

          if (filePath.endsWith(".svg")) {
            final svgContent = await file?.readAsString();
            print(svgContent);
          }
        }
      },
      child: Column(
        children: [
          ElevatedButton(
            child: Text("return main"),
            onPressed: () {
              //导航到main
              Navigator.pop(
                context,
                "我是返回值: ${file?.path}",
              );
            },
          ),
          const SizedBox(height: 10),
          file == null ? uploadImage() : viewImage(file!),
        ],
      ),
    );
  }

  Widget uploadImage() {
    return Center(
      child: Container(
        width: 400,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: const Color(0xFFC9CDD4),
            width: 1,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 60, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              '拖动图片打开',
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget viewImage(XFile file) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(blurRadius: 8, color: Colors.black26),
            ],
          ),
          child: SizedBox(
            width: 400,
            height: 200,
            child: file.path.endsWith(".svg")
                ? SvgPicture.file(
                    File(file.path),
                    height: 352,
                  )
                : Image.file(
                    File(file.path),
                  ),
          ),
        ),
      ),
    );
  }
}
