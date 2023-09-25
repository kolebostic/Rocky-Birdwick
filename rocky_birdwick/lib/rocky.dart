import 'package:flutter/material.dart';

class Rocky extends StatelessWidget {
  final double birdY;
  final double rockyWidth;
  final double rockyHeight;

  const Rocky(
      {super.key,
      required this.birdY,
      required this.rockyWidth,
      required this.rockyHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(0, (2 * birdY + rockyHeight) / (2 - rockyHeight)),
        child: Image.asset('lib/images/rocky.png',
            width: MediaQuery.of(context).size.height * rockyWidth / 2,
            height:
                MediaQuery.of(context).size.height * 3 / 4 * rockyHeight / 2,
            fit: BoxFit.fill));
  }
}
