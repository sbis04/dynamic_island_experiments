import 'package:flutter/material.dart';

class DynamicIslandPlaceholder extends StatelessWidget {
  const DynamicIslandPlaceholder({
    Key? key,
    required this.color,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        height: 36,
        width: 125,
      ),
    );
  }
}
