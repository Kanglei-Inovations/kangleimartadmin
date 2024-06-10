import 'package:flutter/material.dart';

class KRatingProgressIndicator extends StatelessWidget {
  const KRatingProgressIndicator({
    super.key, required this.text, required this.value,
  });
  final String text;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          flex: 11,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor:  Colors.grey,
              borderRadius: BorderRadius.circular(10),
              valueColor: AlwaysStoppedAnimation(Colors.red),

            ),
          ),
        )
      ],
    );
  }
}
