class DoctorAverageReview {
  double averageRating;
  int noOfReviews;
  final String specialization;
  final String affiliations;
  final String uid;

  DoctorAverageReview(
      {this.averageRating = 0,
      this.noOfReviews = 0,
      required this.specialization,
      required this.affiliations,
      required this.uid});
}
