import 'package:flutter/material.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Doctor/reviewsPage.dart';
import 'package:umbrella_care/Models/Doctor/doctorModel.dart';
import 'package:umbrella_care/Patient/doctorReview.dart';

class DoctorCard extends StatelessWidget {
  final DoctorInfo doctor;

  const DoctorCard({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          height: 115,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 3),
                  blurRadius: 6.0,
                  spreadRadius: 2.0)
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                  height: 80,
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: doctor.imgUrl != ''
                        ? Image.network('${doctor.imgUrl}')
                        : Image.asset('assets/doctorImages/doctorPic.png'),
                  )),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      doctor.name,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5E1A84),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      doctor.specialization,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF5E1A84),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        doctor.noOfReviews != 0
                            ? const Icon(
                                Icons.star,
                                size: 14,
                                color: starFill,
                              )
                            : const Icon(
                                Icons.star_border,
                                size: 14,
                                color: greyBorders,
                              ),
                        const SizedBox(width: 5),
                        Text(
                          doctor.noOfReviews != 0 ? '${doctor.avgRating}' : '0',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: doctor.noOfReviews != 0
                                  ? primary
                                  : greyBorders),
                        ),
                        const SizedBox(width: 5),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ReviewsPage(uid: doctor.uid)));
                          },
                          child: Text(
                            doctor.noOfReviews != 0
                                ? '(${doctor.noOfReviews} reviews)'
                                : '(0 reviews)',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: doctor.noOfReviews != 0
                                    ? primary
                                    : greyBorders),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
            top: 15,
            right: 15,
            child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DoctorReview(doctor: doctor)));
                },
                icon: const Icon(
                  Icons.star,
                  color: starFill,
                )))
      ],
    );
  }
}
