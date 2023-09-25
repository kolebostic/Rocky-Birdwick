// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

class Barricades extends StatelessWidget {
  final barricadeWidth; // out of 2, where 2 is the width of the screen
  final barricadeHeight; // proportion of the screenheight
  final barricadeX;
  final bool isBottomBarrier;

  const Barricades(
      {super.key,
      this.barricadeHeight,
      this.barricadeWidth,
      required this.isBottomBarrier,
      this.barricadeX});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(
          (2 * barricadeX + barricadeWidth) / (2 - barricadeWidth),
          isBottomBarrier ? 1 : -1),
      child: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('lib/images/woodplanks.png'),
                fit: BoxFit.cover)),
        width: MediaQuery.of(context).size.width * barricadeWidth / 2,
        height:
            MediaQuery.of(context).size.height * 3 / 4 * barricadeHeight / 2,
      ),
    );
  }
}
