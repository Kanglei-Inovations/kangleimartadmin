import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

class NetworkImageWidget extends StatelessWidget {
  const NetworkImageWidget({
    super.key,
    required this.image,
  });

  final String image;

  @override
  Widget build(BuildContext context) {

    if (kIsWeb) {
      // Display image using Image.network for web
      return Image.network(
        image,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return FancyShimmerImage(imageUrl: image,);
        },
        errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
      );
    } else {
      // Display image using CachedNetworkImage for other platforms
      return CachedNetworkImage(
        imageUrl: image,
        progressIndicatorBuilder: (_, __, downloadProgress) =>
            Center(child: FancyShimmerImage(imageUrl: image,)),
            //CircularProgressIndicator(value: downloadProgress.progress, color: Colors.green)),
      );
    }
  }
}
