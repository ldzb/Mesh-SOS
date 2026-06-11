import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MeshSosApp());
}

class MeshSosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mesh-SOS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
