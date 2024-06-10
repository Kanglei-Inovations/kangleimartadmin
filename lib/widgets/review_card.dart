import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import 'rating_bar.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // CircleAvatar(backgroundColor: AssetImage('assets/icon/user.png'),)
                Icon(Icons.supervised_user_circle, size: 50,),
                Text("John Doe", style: Theme.of(context).textTheme.titleLarge,),


              ],
            ),
            IconButton(onPressed: (){}, icon: Icon(Icons.more_vert))

          ],
        ),
        Row(
          children: [
            KRatingBar(value: 4),
            SizedBox(width: 10,),
            Text('01 Nov, 2023', style: Theme.of(context).textTheme.bodyMedium,),
          ],
        ),
        const SizedBox(height: 10,),
        ReadMoreText(
          'This user interface of the app is quite intuitive. I was able to naviaate and make purchases seamlessly. Great Job!, This user interface of the app is quite intuitive. I was able to naviaate and make purchases seamlessly. Great Job!',
          trimLines: 2,
          trimMode: TrimMode.Line,
          trimExpandedText: '  SHOW LESS',
          trimCollapsedText: '...SHOW MORE',
          moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          lessStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color:  Colors.black),

        ),
        const SizedBox(height: 10,),
        Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black12),
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("KangleiMart Store", style: Theme.of(context).textTheme.titleMedium,),
                        Text("02 Nov, 2023", style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    ReadMoreText(
                      'This user interface of the app is quite intuitive. I was able to naviaate and make purchases seamlessly. Great Job!, This user interface of the app is quite intuitive. I was able to naviaate and make purchases seamlessly. Great Job!',
                      trimLines: 2,
                      trimMode: TrimMode.Line,
                      trimExpandedText: '  SHOW LESS',
                      trimCollapsedText: '...SHOW MORE',
                      moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                      lessStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color:  Colors.black),

                    ),
                  ],
                )
            )
        ),
        SizedBox(height: 10,)
      ],
    );
  }
}
