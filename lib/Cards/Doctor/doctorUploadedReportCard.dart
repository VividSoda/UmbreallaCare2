import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Models/Doctor/doctorUploadedReport.dart';

String latestResponse = "no";

class DoctorUploadedReportCard extends StatelessWidget {
  final DoctorUploadedReport doctorUploadedReport;
  final bool sameDate;

  const DoctorUploadedReportCard(
      {Key? key, required this.doctorUploadedReport, required this.sameDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat("d MMMM yyyy").format(doctorUploadedReport.dateCreated);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          if (!sameDate)
            Row(
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primary),
                ),
                const Expanded(
                  child: DottedLine(
                    dashColor: primary,
                    lineThickness: 1.5,
                  ),
                )
              ],
            ),
          if (!sameDate) const SizedBox(height: 20),
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
                        child: doctorUploadedReport.imgUrl != ''
                            ? Image.network('${doctorUploadedReport.imgUrl}')
                            : Image.asset(
                                'assets/doctorImages/doctorPic.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Dr. ${doctorUploadedReport.name}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            doctorUploadedReport.affiliation,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            doctorUploadedReport.specialization,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                          ),
                        ],
                      ),
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
