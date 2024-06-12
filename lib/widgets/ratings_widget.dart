import 'package:flutter/material.dart';
import 'package:kangleimartadmin/widgets/rating_bar.dart';
import 'package:kangleimartadmin/widgets/rating_progress_indicator.dart';
import 'package:kangleimartadmin/widgets/review_card.dart';

class RatingsWidget extends StatelessWidget {
  const RatingsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
          children: [
            Text(
                'Ratings and reviews are verified and are from people who use the same type of devices that you use.'),
            SizedBox(
              height: 10,
            ),


            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    '4.8',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      KRatingProgressIndicator(text: "5", value: 1.0,),
                      KRatingProgressIndicator(text: "4", value: 0.8,),
                      KRatingProgressIndicator(text: "3", value: 0.6,),
                      KRatingProgressIndicator(text: "2", value: 0.4,),
                      KRatingProgressIndicator(text: "1", value: 0.2,),
                    ],
                  ),
                )
              ],
            ),
            KRatingBar(value: 3.5,),
            Text("12, 611", style: Theme.of(context).textTheme.bodySmall,),
            SizedBox(height: 20,),
            ReviewCard(),
            ReviewCard(),
            ReviewCard(),
            ReviewCard(),
            ReviewCard(),
          ]

      ),
    );
  }
}

