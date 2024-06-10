import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:readmore/readmore.dart';
import '../widgets/rating_bar.dart';
import '../widgets/rating_progress_indicator.dart';
import '../widgets/review_card.dart';

class ProductReviewScreen extends StatelessWidget {
  const ProductReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review and Rating'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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


              
            ],
          ),
        ),
      ),
    );
  }
}




