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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  double dragDownValue = 0;
  late final AnimationController animationController;
  late final Animation<double> animation;
  bool isRefreshing = false;
  bool hasDragEnded = false;
  bool afterRefreshAnim = false;
  final scrollController = ScrollController();
  bool isScrollNegative = false;
  bool isStart = false;

  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    final Animation<double> curve =
        CurvedAnimation(parent: animationController, curve: Curves.easeOutSine);
    animation = Tween<double>(begin: 60, end: 0).animate(curve)
      ..addListener(() {
        if (animationController.isCompleted && hasDragEnded) {
          print('reset');
          animationController.reset();
        }
        // print('STATUS: ${animationController.status}');
      });

    super.initState();
  }

  startAction() async {
    setState(() => isRefreshing = true);
    await Future.delayed(const Duration(seconds: 4), () {});
    setState(() {
      isRefreshing = false;
      afterRefreshAnim = true;
      isScrollNegative = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // body: DynamicIslandWrapper(
      // ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (details) {
          if (isRefreshing) return;
          if (dragDownValue + details.delta.dy.toInt() >= 0) {
            setState(() {
              dragDownValue += details.delta.dy.toInt();
              hasDragEnded = false;
            });
            if (dragDownValue >= 220 &&
                ![AnimationStatus.forward, AnimationStatus.completed]
                    .contains(animationController.status)) {
              animationController.forward();
            }
          }
        },
        onVerticalDragEnd: (details) {
          if (dragDownValue > 250) {
            startAction();
          }
          if (animationController.isCompleted) {
            print('reset');
            animationController.reset();
          }
          setState(() {
            dragDownValue = 0;
            hasDragEnded = true;
          });
        },
        child: IgnorePointer(
          ignoring: isScrollNegative,
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 11.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: AlignmentDirectional.center,
                      children: [
                        // Dynamic Island
                        AnimatedContainer(
                          onEnd: () {
                            setState(() {
                              afterRefreshAnim = false;
                            });
                          },
                          curve: Curves.easeInOut,
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: 37,
                          width: afterRefreshAnim
                              ? 150
                              : 125 +
                                  25 *
                                      (min(dragDownValue.toDouble() / 1.4, 80) /
                                          220),
                        ),
                        // Beizer Curved Container
                        Positioned(
                          top: 36 / 1.1, // dynamic island height
                          child: ClipPath(
                            clipper: CurveClipper(),
                            child: Container(
                              color: Colors.black,
                              height: [
                                AnimationStatus.forward,
                                AnimationStatus.completed
                              ].contains(animationController.status)
                                  ? animation.value / 1.6
                                  : min(dragDownValue.toDouble() / 1.6, 70),
                              width:
                                  min(dragDownValue.toDouble() / 1, 125 / 1.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedPadding(
                      onEnd: () {
                        if (!isRefreshing) {
                          print(
                              'Padding anim end, isRefreshing: $isRefreshing');
                        }
                      },
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.only(
                          top: isRefreshing
                              ? 80
                              : 12.0 + min(dragDownValue.toDouble() / 3, 100)),
                      child: CircleAvatar(
                        maxRadius: 18,
                        backgroundColor: Colors.black,
                        child: Opacity(
                          opacity: isRefreshing
                              ? 1
                              : min(dragDownValue.toDouble() / 200, 1),
                          child: Transform.rotate(
                            angle:
                                min(pi * (dragDownValue.toDouble() / 200), pi),
                            child: dragDownValue.toDouble() > 250 ||
                                    isRefreshing
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.arrow_downward_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollStartNotification) {
                              print(
                                  'START, ${scrollNotification.metrics.pixels}');
                              isStart = true;
                            }
                            print('isStart: $isStart');
                            if (scrollNotification
                                is ScrollUpdateNotification) {
                              print(
                                  'UPDATE, ${scrollNotification.metrics.pixels}');
                              if (isStart &&
                                  scrollNotification.metrics.pixels < 0) {
                                setState(() => isScrollNegative = true);
                                isStart = false;
                              }
                            }
                            // if (scrollNotification is ScrollEndNotification) {
                            //   setState(() => isScrollNegative = false);
                            // }
                            return true;
                          },
                          // onNotification: (scrollNotification) {
                          //   if (scrollNotification is ScrollStartNotification) {
                          //   } else if (scrollNotification
                          //       is ScrollUpdateNotification) {
                          //     print(
                          //         'UPDATE, ${scrollNotification.metrics.pixels}');
                          //     double scrollValue =
                          //         scrollNotification.metrics.pixels;
                          //     if (scrollValue > 0 || isRefreshing) return true;
                          //     double scrollValueAbs = scrollValue.abs();
                          //     setState(() {
                          //       dragDownValue = scrollValueAbs;
                          //       hasDragEnded = false;
                          //     });
                          //     if (dragDownValue >= 220 &&
                          //         ![
                          //           AnimationStatus.forward,
                          //           AnimationStatus.completed
                          //         ].contains(animationController.status)) {
                          //       animationController.forward();
                          //     }
                          //   } else if (scrollNotification
                          //       is ScrollEndNotification) {
                          //     print('END, ${scrollNotification.metrics.pixels}');
                          //     if (dragDownValue > 250) {
                          //       startAction();
                          //     }
                          //     if (animationController.isCompleted) {
                          //       print('reset');
                          //       animationController.reset();
                          //     }
                          //     setState(() {
                          //       dragDownValue = 0;
                          //       hasDragEnded = true;
                          //     });
                          //   }
                          //   return true;
                          // },
                          child: ListView.builder(
                            // physics: const NeverScrollableScrollPhysics(),
                            controller: scrollController,
                            shrinkWrap: true,
                            itemCount: 10,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Card(
                                color: Colors.blue.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.ac_unit_rounded),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Item ${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Some description of this card item',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Drag Down Value: ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                              ),
                            ),
                            Container(
                              width: 40,
                              child: Text(
                                '$dragDownValue',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
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
