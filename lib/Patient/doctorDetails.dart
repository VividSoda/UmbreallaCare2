import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Patient/appointmentView.dart';

class DoctorDetails extends StatefulWidget {
  final String uid;

  const DoctorDetails({Key? key, required this.uid}) : super(key: key);

  @override
  State<DoctorDetails> createState() => _DoctorDetailsState();
}

class _DoctorDetailsState extends State<DoctorDetails> {
  String? _name;
  String? _qualifications;
  String? _affiliations;
  String? _experience;
  String? _specialization;
  bool _isLoading = true;
  int? _noOfCheckedPatients;
  double _averageRating = 0;
  String _imgUrl = '';

  Future<DocumentSnapshot<Map<String, dynamic>>?> fetchDoctorDetails() async {
    final userDoc =
        FirebaseFirestore.instance.collection('doctors').doc(widget.uid);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      _name = data['name'];
      _qualifications = data['qualifications'];
      _affiliations = data['affiliations'];
      _experience = data['experience'];
      _specialization = data['specialization'];
      _noOfCheckedPatients = data['no_of_checked_patients'];
      if (data.containsKey('averageRating')) {
        _averageRating = data['averageRating'];
      }
      if (data.containsKey('img url')) {
        _imgUrl = data['img url'];
      }
      setState(() {
        _isLoading = false;
      });
      return await userDoc.get();
    }
    return null;
  }

  @override
  void initState() {
    fetchDoctorDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5E1A84),
              Color(0xFF5E1A84),
              Colors.white,
              Colors.white
            ],
            stops: [0.0, 0.25, 0.25, 1.0],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(15)),
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back_sharp,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 60),
                        const Text(
                          'Details',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          width: 319,
                          height: 109,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(0, 3),
                                    blurRadius: 6.0,
                                    spreadRadius: 2.0)
                              ]),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 77,
                                  height: 77,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: _imgUrl != ''
                                        ? Image.network(_imgUrl)
                                        : Image.asset(
                                            'assets/doctorImages/doctorPic.png'),
                                  )),
                              const SizedBox(width: 20),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _name!,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF5E1A84)),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _specialization!,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF5E1A84)),
                                    ),
                                    const SizedBox(height: 10),
                                    Flexible(
                                      child: Text(
                                        _affiliations!,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF5E1A84)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                    const SizedBox(height: 50),
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  width: 98,
                                  height: 95,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFE8EBED),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Exp.',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: primary),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '$_experience yr',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  width: 98,
                                  height: 95,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFE8EBED),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Patients',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: primary),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        _noOfCheckedPatients.toString(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  width: 98,
                                  height: 95,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFE8EBED),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Rating',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: primary),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: starFill,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '$_averageRating',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: primary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'About',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: primary),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _qualifications!,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: primary),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _affiliations!,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: primary),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _specialization!,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: primary),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            width: MediaQuery.of(context).size.width,
                            height: 85,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0xFFD7DEEA)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFE8EBED),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: const Center(
                                      child: Icon(
                                    Icons.watch_later,
                                    color: primary,
                                  )),
                                ),
                                const SizedBox(width: 20),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Availability',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: primary),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '10 AM - 5 PM',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: primary),
                                    ),
                                  ],
                                ),
                                const Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: primary,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AppointmentView(
                                              uid: widget.uid,
                                            )));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: const Text(
                                'Book Now',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          )
                        ],
                      ),
                    ))
                  ],
                ),
        ),
      ),
    );
  }
}
