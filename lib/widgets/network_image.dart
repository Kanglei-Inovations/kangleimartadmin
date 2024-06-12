
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImage extends StatelessWidget {
  const NetworkImage({
    super.key,
    required this.image,
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      progressIndicatorBuilder: (_, __, downloadProgress) =>
          Center(child: CircularProgressIndicator(value: downloadProgress.progress, color: Colors.green)),
    );
  }
}