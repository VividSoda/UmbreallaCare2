import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Cards/Doctor/doctorCard.dart';
import 'package:umbrella_care/Models/Doctor/doctorAverageReview.dart';
import 'package:umbrella_care/Models/Doctor/doctorModel.dart';
import 'package:umbrella_care/Patient/doctorDetails.dart';
import 'package:umbrella_care/Patient/filterCategories.dart';

class DoctorSearch extends StatefulWidget {
  const DoctorSearch({Key? key}) : super(key: key);

  @override
  State<DoctorSearch> createState() => _DoctorSearchState();
}

class _DoctorSearchState extends State<DoctorSearch> {
  List<DoctorInfo> doctors = [];
  List<DoctorInfo> filteredDoctors = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isCategorySelected = false;

  Future<List<DoctorInfo>> getDoctorsFromFirebase() async {
    List<DoctorInfo> doctors = [];
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('doctors').get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data!.containsKey('validity')) {
        String uid = doc.id;
        String name = data['name'];
        String nmcNo = data['nmc no'];
        String contact = data['contact'];
        String qualifications = data['qualifications'];
        String affiliations = data['affiliations'];
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
        DoctorInfo doctorInfo = DoctorInfo(
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
        doctors.add(doctorInfo);
      }
    }
    return doctors;
  }

  Future<void> fetchDoctors() async {
    List<DoctorInfo> fetchedDoctors = await getDoctorsFromFirebase();
    setState(() {
      doctors = fetchedDoctors;
      _isLoading = false;
    });
  }

  void filterDoctors() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      filteredDoctors = doctors
          .where((doctor) =>
              doctor.specialization.toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<List<DoctorAverageReview>> getReviewData() async {
    List<DoctorAverageReview> reviews = [];
    final doctors = FirebaseFirestore.instance.collection('doctors');
    QuerySnapshot snapshot = await doctors.get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      String specialization = data!['specialization'];
      String affiliations = data['affiliations'];
      String uid = doc.id;

      if (data.containsKey('averageRating')) {
        dynamic avgRating = data['averageRating'];
        double averageRating = avgRating.toDouble();
        int noOfReviews = data['noOfReviews'];
        DoctorAverageReview doctorAverageReview = DoctorAverageReview(
            averageRating: averageRating,
            noOfReviews: noOfReviews,
            specialization: specialization,
            affiliations: affiliations,
            uid: uid);
        reviews.add(doctorAverageReview);
      } else {
        DoctorAverageReview doctorAverageReview = DoctorAverageReview(
            specialization: specialization,
            affiliations: affiliations,
            uid: uid);
        reviews.add(doctorAverageReview);
      }
    }
    return reviews;
  }

  void fetchData() async {
    fetchDoctors();
  }

  void filterData() {
    filterDoctors();
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = _searchController.text.isNotEmpty;
    bool listItemsExist = (filteredDoctors.isNotEmpty || !isSearching);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(15)),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF5E1A84)),
                  ),
                ),
                const SizedBox(width: 60),
                const Text(
                  'Search Results',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5E1A84)),
                )
              ],
            ),
            const SizedBox(height: 30),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 56,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF5E1A84))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            hintText: 'What are you looking for?',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF5E1A84),
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none),
                        controller: _searchController,
                        onChanged: (value) {
                          filterData();
                        },
                        enabled: !_isCategorySelected,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const FilterCategories()))
                              .then((category) {
                            print(category + '--------------');
                            setState(() {
                              _isCategorySelected = true;
                            });
                          });
                        },
                        icon: Image.asset('assets/logos/Filter.png')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Popular Doctors',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5E1A84)),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    'See All',
                    style: TextStyle(
                        color: Color(0xFF5E1A84),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w400,
                        decorationThickness: 1,
                        fontSize: 14),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: SingleChildScrollView(
                      child: listItemsExist
                          ? Column(
                              children: [
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: isSearching
                                      ? filteredDoctors.length
                                      : doctors.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DoctorDetails(
                                                        uid: isSearching
                                                            ? filteredDoctors[
                                                                    index]
                                                                .uid
                                                            : doctors[index]
                                                                .uid)));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: isSearching
                                            ? DoctorCard(
                                                doctor: filteredDoctors[index],
                                              )
                                            : DoctorCard(
                                                doctor: doctors[index],
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            )
                          : const Center(
                              child: Text(
                                'No results found',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF5E1A84)),
                              ),
                            ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
