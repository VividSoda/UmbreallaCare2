import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Cards/Doctor/doctorCard.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Models/Doctor/doctorAverageReview.dart';
import 'package:umbrella_care/Models/Doctor/doctorModel.dart';
import 'package:umbrella_care/Patient/doctorDetails.dart';

class HospitalDoctors extends StatefulWidget {
  final String hospitalName;

  const HospitalDoctors({Key? key, required this.hospitalName})
      : super(key: key);

  @override
  State<HospitalDoctors> createState() => _HospitalDoctorsState();
}

class _HospitalDoctorsState extends State<HospitalDoctors> {
  bool _isLoading = true;
  List<DoctorInfo> affiliatedDoctors = [];
  List<DoctorAverageReview> reviews = [];

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  void fetchDoctors() async {
    List<DoctorInfo> fetchedDoctors = await getDoctorsFromFirebase();
    setState(() {
      affiliatedDoctors = fetchedDoctors;
      _isLoading = false;
    });
  }

  Future<List<DoctorInfo>> getDoctorsFromFirebase() async {
    List<DoctorInfo> doctors = [];
    final documents = FirebaseFirestore.instance.collection('doctors');
    QuerySnapshot snapshot = await documents.get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data!.containsKey('validity')) {
        String affiliations = data['affiliations'].toString().toLowerCase();
        if (affiliations.contains(widget.hospitalName.toLowerCase())) {
          String uid = doc.id;
          String name = data['name'];
          String nmcNo = data['nmc no'];
          String contact = data['contact'];
          String qualifications = data['qualifications'];
          String experience = data['experience'];
          String specialization = data['specialization'];
          bool validity = data['validity'];
          String imgUrl = '';
          if (data.containsKey('img url')) {
            imgUrl = data['img url'];
          }
          double averageRating = 0;
          int noOfReviews = 0;
          if (data.containsKey('averageRating')) {
            dynamic avg = data['averageRating'];
            averageRating = avg.toDouble();
            noOfReviews = data['noOfReviews'];
          }
          DoctorInfo doctor = DoctorInfo(
              uid: uid,
              name: name,
              nmcNo: nmcNo,
              contact: contact,
              qualifications: qualifications,
              affiliations: affiliations,
              experience: experience,
              specialization: specialization,
              validity: validity,
              imgUrl: imgUrl,
              avgRating: averageRating,
              noOfReviews: noOfReviews);
          doctors.add(doctor);
        }
      }
    }
    return doctors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: primary,
            )),
        title: const Text(
          'Available Doctors',
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.w700, color: primary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: affiliatedDoctors.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DoctorDetails(
                                  uid: affiliatedDoctors[index].uid)));
                    },
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: DoctorCard(
                          doctor: affiliatedDoctors[index],
                        )),
                  );
                },
              ),
      ),
    );
  }
}
