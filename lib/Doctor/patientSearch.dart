import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Cards/Patient/patientCard.dart';
import 'package:umbrella_care/Doctor/patientInformation.dart';
import 'package:umbrella_care/Models/Patient/patientModel.dart';

class PatientSearch extends StatefulWidget {
  const PatientSearch({Key? key}) : super(key: key);

  @override
  State<PatientSearch> createState() => _PatientSearchState();
}

class _PatientSearchState extends State<PatientSearch> {
  List<PatientInfo> patients = [];
  List<PatientInfo> filteredPatients = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  Future<List<PatientInfo>> getPatientsFromFirebase() async {
    List<PatientInfo> patients = [];
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('patients').get();

    for (var patient in snapshot.docs) {
      Map<String, dynamic>? data = patient.data() as Map<String, dynamic>?;
      if (data!.containsKey('validity')) {
        String uid = patient.id;
        String name = data['name'];
        String contact = data['contact'];
        String imgUrl = '';
        if (data.containsKey('img url')) {
          imgUrl = data['img url'];
        }
        PatientInfo patientInfo =
            PatientInfo(uid: uid, name: name, contact: contact, imgUrl: imgUrl);
        patients.add(patientInfo);
      }
    }
    return patients;
  }

  Future<void> fetchPatients() async {
    List<PatientInfo> fetchedPatients = await getPatientsFromFirebase();
    setState(() {
      patients = fetchedPatients;
      _isLoading = false;
    });
  }

  void filterPatients() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      filteredPatients = patients
          .where((doctor) => doctor.name.toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = _searchController.text.isNotEmpty;
    bool listItemsExist = (filteredPatients.isNotEmpty || !isSearching);
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
                  'Search Patients',
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
                          filterPatients();
                        },
                      ),
                    ),
                    IconButton(
                        onPressed: () {},
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
                  'Relevant Results',
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
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
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
                                      ? filteredPatients.length
                                      : patients.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PatientInformation(
                                                        uid: isSearching
                                                            ? filteredPatients[
                                                                    index]
                                                                .uid
                                                            : patients[index]
                                                                .uid)));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: isSearching
                                            ? PatientCard(
                                                patient:
                                                    filteredPatients[index])
                                            : PatientCard(
                                                patient: patients[index]),
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
