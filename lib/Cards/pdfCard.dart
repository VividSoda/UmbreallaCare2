import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Models/pdfModel.dart';

class PdfCard extends StatelessWidget {
  final PdfModel pdfModel;
  final bool sameDate;

  const PdfCard({Key? key, required this.pdfModel, required this.sameDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat("d MMMM yyyy").format(pdfModel.dateCreated);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            width: MediaQuery.of(context).size.width,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: containerFill),
            child: Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf_sharp,
                  color: primary,
                  size: 25,
                ),
                const SizedBox(width: 5),
                Text(
                  pdfModel.name,
                  style: const TextStyle(
                      color: primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
