import 'package:dynamic_island_experiments/dynamic_island_widgets/dynamic_island_widgets.dart';
import 'package:flutter/material.dart';

class DynamicIslandWrapper extends StatelessWidget {
  const DynamicIslandWrapper({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: DynamicIslandPullPlaceholder(
        color: Colors.black,
      ),
    );
  }
}
