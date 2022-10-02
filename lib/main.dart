import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int dragDownValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      // body: DynamicIslandWrapper(
      // ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (dragDownValue + details.delta.dy.toInt() >= 0) {
            setState(() {
              dragDownValue += details.delta.dy.toInt();
            });
          }
        },
        onVerticalDragEnd: (details) {
          setState(() {
            dragDownValue = 0;
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: 12.0 + dragDownValue.toDouble() / 3),
                    child: CircleAvatar(
                      maxRadius: 18,
                      backgroundColor: Colors.black,
                      child: Opacity(
                        opacity: min(dragDownValue.toDouble() / 200, 1),
                        child: Transform.rotate(
                          angle: min(pi * (dragDownValue.toDouble() / 200), pi),
                          child: dragDownValue.toDouble() > 250
                              ? SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.arrow_downward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Container(
                      color: Colors.black38,
                      child: Center(
                        child: Text(
                          '$dragDownValue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: AlignmentDirectional.center,
                    children: [
                      // Dynamic Island
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 36,
                        width: 125,
                      ),
                      // Beizer Curved Container
                      Positioned(
                        top: 36 / 1.2, // dynamic island height
                        child: ClipPath(
                          clipper: CurveClipper(),
                          child: Container(
                            color: Colors.black,
                            height: min(dragDownValue.toDouble() / 2, 60),
                            width: min(dragDownValue.toDouble() / 1, 125 / 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    final path = Path();
    // path.lineTo(w / 6, 0); // 2
    path.quadraticBezierTo(w / 2, h, w, 0);
    // path.lineTo(w, h); // 3
    // path.lineTo(w, 0); // 5
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
