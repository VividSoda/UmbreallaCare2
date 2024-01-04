import 'package:flutter/material.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Models/Hospital/hospitalModel.dart';

class HospitalCard extends StatelessWidget {
  final HospitalModel hospital;

  const HospitalCard({Key? key, required this.hospital}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/hospital/hospital.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hospital.name,
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
                  hospital.specialization,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5E1A84),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  hospital.location,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
