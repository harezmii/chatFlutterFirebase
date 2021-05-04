import 'package:flutter/material.dart';

final meDecoration = BoxDecoration(
  color: Colors.orange.shade100,
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(10),
    bottomRight: Radius.circular(10),
    topRight: Radius.circular(10),
    bottomLeft: Radius.circular(0),
  ),
);
final otherDecoration = BoxDecoration(
  color: Colors.grey,
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(10),
    topRight: Radius.circular(10),
    bottomRight: Radius.circular(0),
    bottomLeft: Radius.circular(10),
  ),
);