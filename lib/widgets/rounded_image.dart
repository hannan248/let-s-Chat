
import 'package:flutter/material.dart';
import 'dart:io';

class RoundedImageNetwork extends StatelessWidget {
  final String imagePath;
  final double size;

  const RoundedImageNetwork(
      {required Key key, required this.imagePath, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(
          Radius.circular(size),
        ),
        image:
            DecorationImage(image: NetworkImage(imagePath), fit: BoxFit.cover),
      ),
    );
  }
}

class RoundedImageFile extends StatelessWidget {
  final File image;
  final double size;

  const RoundedImageFile({
    required Key key,
    required this.image,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // image: DecorationImage(
        //   fit: BoxFit.cover,
        //   image: Image.file()
        // ),
        borderRadius: BorderRadius.all(Radius.circular(size)),
        color: Colors.black,
      ),
      child: Image.file(
        image!,
        fit: BoxFit.fill,
      ),
    );
  }
}

class RoundedImageNetworkWithStatusIndicator extends RoundedImageNetwork {
  final bool isActive;

  const RoundedImageNetworkWithStatusIndicator({
    required Key key,
    required String imagePath,
    required double size,
    required this.isActive,
  }) : super(
          key: key,
          imagePath: imagePath,
          size: size,
        );

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        super.build(context),
        Container(
          height: size * 0.20,
          width: 0.20,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(size),
          ),
        )
      ],
    );
  }
}
