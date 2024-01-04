import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Models/reviewModel.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            border: Border.all(color: greyBorders),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: review.imgUrl != ''
                        ? Image.network('${review.imgUrl}').image
                        : const AssetImage(
                            'assets/patientImages/patient.png',
                          ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: primary),
                      ),
                      const SizedBox(width: 5),
                      RatingBar.builder(
                          allowHalfRating: true,
                          ignoreGestures: true,
                          initialRating: review.rating,
                          minRating: 0,
                          unratedColor: Colors.grey,
                          itemCount: 5,
                          itemSize: 15,
                          itemPadding: const EdgeInsets.only(right: 2),
                          updateOnDrag: false,
                          itemBuilder: (context, index) {
                            return const Icon(
                              Icons.star,
                              color: starFill,
                            );
                          },
                          onRatingUpdate: (rating) {}),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text(
                review.review,
                style: const TextStyle(color: primary),
              )
            ],
          )),
    );
  }
}
