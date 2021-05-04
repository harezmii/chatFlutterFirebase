import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable, camel_case_types
class bottomSheetFloor  extends StatelessWidget{
  IconData _icons;
  String _text;
  Color _color;

  bottomSheetFloor(this._icons,this._text,this._color,{FileType file});

  get file => file;

  @override
  Widget build(BuildContext context) {
   return Container(
     child: Column(
       children: [
         GestureDetector(
           child: Container(
             height: 60,
             width: 60,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: this._color,
             ),
             child: Center(
               child: Icon(
                 this._icons,
                 color: Colors.white,
                 size: 28,
               ),
             ),
           ),
           onTap: () async {
             FilePickerResult result = await FilePicker.platform.pickFiles(
               type: file,
               allowMultiple: true,
               allowCompression: true,
             );
           },
         ),
         SizedBox(
           height: 10,
         ),
         Container(
           child: Text(
             this._text,
             style: TextStyle(
                 letterSpacing: 1.0,
                 fontSize: 16,
                 color: this._color),
           ),
         ),
       ],
     ),
   );
  }

}