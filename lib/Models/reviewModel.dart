class ReviewModel {
  final String name, patientId;
  final double rating;
  final String review;
  String? imgUrl = '';

  ReviewModel(
      {required this.name,
      required this.review,
      required this.rating,
      required this.patientId,
      this.imgUrl});
}
