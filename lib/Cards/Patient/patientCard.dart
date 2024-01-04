import 'package:flutter/material.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Doctor/globalPatientReport.dart';
import 'package:umbrella_care/Models/Patient/patientModel.dart';

class PatientCard extends StatelessWidget {
  final PatientInfo patient;

  const PatientCard({Key? key, required this.patient}) : super(key: key);

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
            child: patient.imgUrl != ''
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network('${patient.imgUrl}'))
                : Image.asset('assets/patientImages/patient.png'),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                patient.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5E1A84),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                patient.contact,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF5E1A84),
                ),
              ),
              const SizedBox(height: 5),
              InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                GlobalPatientReport(patientId: patient.uid)));
                  },
                  child: const Text(
                    'view report',
                    style: TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        color: primary),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}
