import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Cards/Hospital/hospitalCard.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Hospital/hospitalDoctors.dart';
import 'package:umbrella_care/Models/Hospital/hospitalModel.dart';
class HospitalListView extends StatefulWidget {
  const HospitalListView({Key? key}) : super(key: key);
  @override
  State<HospitalListView> createState() => _HospitalListViewState();
}
class _HospitalListViewState extends State<HospitalListView> {
  List<HospitalModel> hospitals = [];
  List<HospitalModel> filteredHospitals = [];
  List<HospitalModel> generalHospitals = [];
  bool _isLoading  = true;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchHospitals();
  }
  Future<void> fetchHospitals() async {
    List<HospitalModel> fetchedHospitals = await getHospitalsFromFirebase();
    setState(() {
      hospitals = fetchedHospitals;
      generalHospitals = fetchedHospitals.where(
              (hospital) => hospital.specialization.toLowerCase().contains('general'))
          .toList();
      _isLoading = false;
    });
  }
  Future<List<HospitalModel>> getHospitalsFromFirebase() async {
    List<HospitalModel> hospitals = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('hospitals').get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      String name = data!['Name'];
      String specialization = data['Specialization'];
      String location = data['Location'];
      HospitalModel hospital = HospitalModel(
          name: name,
          specialization: specialization,
          location: location
      );
      hospitals.add(hospital);
    }
    return hospitals;
  }
  void filterHospitals() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      filteredHospitals = hospitals
          .where((hospital) => hospital.specialization.toLowerCase().contains(searchTerm))
          .toList();
      filteredHospitals.addAll(generalHospitals);
    });
  }
  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    bool isSearching = _searchController.text.isNotEmpty;
    bool listItemsExist = (filteredHospitals.isNotEmpty||!isSearching);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed:() {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: primary,
            )
        ),
        title: const Text(
          'Hospitals',
          style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              color: primary
          ),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 56,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF5E1A84)
                    )
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5, horizontal: 10),
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
                              disabledBorder: InputBorder.none
                          ),
                          controller: _searchController,
                          onChanged: (value){
                            filterHospitals();
                          },
                        ),
                      ),
                      IconButton(
                          onPressed: () {

                          },
                          icon: Image.asset(
                              'assets/logos/Filter.png'
                          )
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Popular Hospitals',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5E1A84)
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: (){

                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                          color: Color(0xFF5E1A84),
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w400,
                          decorationThickness: 1,
                          fontSize: 14
                      ),
                    ),
                  )
                ],
              ),
              _isLoading? const Center(
                child: CircularProgressIndicator(),
              ) : Expanded(
                child: SingleChildScrollView(
                  child: listItemsExist? Column(
                    children: [
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:isSearching? filteredHospitals.length : hospitals.length ,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () async{
                              Navigator.push(
                                  context, 
                                MaterialPageRoute(builder: (context) => HospitalDoctors(hospitalName: isSearching? filteredHospitals[index].name : hospitals[index].name))
                              );
                            },
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child:isSearching? HospitalCard(
                                  hospital: filteredHospitals[index]
                              ) : HospitalCard(
                                  hospital: hospitals[index]
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ) : const Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5E1A84)
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }
}
