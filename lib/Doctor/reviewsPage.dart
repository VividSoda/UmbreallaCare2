import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Cards/reviewCard.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Models/reviewModel.dart';

class ReviewsPage extends StatefulWidget {
  final String uid;

  const ReviewsPage({Key? key, required this.uid}) : super(key: key);

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<ReviewModel> reviews = [];
  bool _isLoading = true;
  double _avgRating = 0;

  Future<void> fetchAvgRating() async {
    final user =
        FirebaseFirestore.instance.collection('doctors').doc(widget.uid);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await user.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      if (data['averageRating'] != null) {
        dynamic item = data['averageRating'];
        setState(() {
          _avgRating = item.toDouble();
        });
      }
    }
  }

  Future<List<ReviewModel>> getReviews() async {
    List<ReviewModel> reviews = [];
    final documents = FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.uid)
        .collection('reviews');
    QuerySnapshot snapshot = await documents.get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>;
      String name = data['name'];
      String patientId = data['patient id'];
      dynamic item = data['rating'];
      double rating = item.toDouble();
      String review = data['review'];
      String imgUrl = await fetchPatientDetails(patientId);
      ReviewModel reviewModel = ReviewModel(
          name: name,
          review: review,
          rating: rating,
          patientId: patientId,
          imgUrl: imgUrl);
      reviews.add(reviewModel);
    }
    return reviews;
  }

  Future<void> fetchReviews() async {
    List<ReviewModel> fetchedReviews = await getReviews();
    setState(() {
      reviews = fetchedReviews;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAvgRating();
    fetchReviews();
  }

  Future<String> fetchPatientDetails(String patientId) async {
    final document =
        FirebaseFirestore.instance.collection('patients').doc(patientId);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
    Map<String, dynamic>? data = snapshot.data();
    String imgUrl = '';
    if (data!.containsKey('img url')) {
      imgUrl = data['img url'];
    }
    return imgUrl;
  }

  @override
  Widget build(BuildContext context) {
    bool reviewsExists = reviews.isNotEmpty;
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
          'Reviews',
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.w700, color: primary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: starFill,
                ),
                const SizedBox(width: 5),
                Text(
                  '$_avgRating (Avg.)',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primary),
                )
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : reviewsExists
                    ? ListView.builder(
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          return ReviewCard(review: reviews[index]);
                        })
                    : const Center(
                        child: Text(
                          'No Reviews Yet',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: primary),
                        ),
                      )),
      ),
    );
  }
}
