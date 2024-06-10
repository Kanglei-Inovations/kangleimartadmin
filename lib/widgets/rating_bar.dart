import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class KRatingBar extends StatelessWidget {
  const KRatingBar({
    super.key, required this.value
  });
final double value;
  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: value,
      itemSize: 20,
      unratedColor: Colors.grey,
      itemBuilder: (_,__)=> Icon(Icons.star, color: Colors.red),
    );
  }
}