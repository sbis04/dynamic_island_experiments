import 'package:flutter/material.dart';

class DynamicIslandPullPlaceholder extends StatelessWidget {
  const DynamicIslandPullPlaceholder({
    Key? key,
    required this.color,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            height: 36,
            width: 125,
          ),
          Positioned(
            top: 36 / 2,
            child: ClipPath(
              clipper: CurveClipper(),
              child: Container(
                color: Colors.black,
                height: 50,
                width: 125,
              ),
            ),
          ),
        ],
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
    path.lineTo(w / 6, 0); // 2
    path.quadraticBezierTo(w / 2, h, w * (5 / 6), 0);
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
