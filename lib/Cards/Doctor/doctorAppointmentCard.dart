import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Models/Patient/doctorAppointmentInfo.dart';

class DoctorAppointmentCard extends StatelessWidget {
  final DoctorAppointmentInfo appointment;

  const DoctorAppointmentCard({Key? key, required this.appointment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String formattedTime =
        '${appointment.bookedTime} : 00 ${appointment.bookedTime > 11 ? "PM" : "AM"}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                formattedTime,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: primary),
              ),
              const Expanded(
                child: DottedLine(
                  dashColor: primary,
                  lineThickness: 1.5,
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                height: 112,
                decoration: BoxDecoration(
                    color: primary, borderRadius: BorderRadius.circular(30)),
                child: Row(
                  children: [
                    //Image
                    SizedBox(
                      height: 57,
                      width: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: appointment.imgUrl != ''
                            ? Image.network('${appointment.imgUrl}')
                            : Image.asset(
                                'assets/doctorImages/doctorPic.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formattedTime,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Dr. ${appointment.name}',
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          appointment.speciality,
                          softWrap: true,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const Positioned(
                top: 10,
                right: 20,
                child: Text(
                  '...',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
