import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    required this.image,
    this.width = 600,
    this.height = 240,
  });

  final String image;
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    return Image.network(
      image,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}
