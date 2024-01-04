class DoctorInfo {
  final String uid,
      name,
      nmcNo,
      contact,
      qualifications,
      affiliations,
      experience,
      specialization;
  final bool validity;
  String? imgUrl = '';
  double? avgRating = 0.0;
  int? noOfReviews = 0;

  DoctorInfo(
      {required this.uid,
      required this.name,
      required this.nmcNo,
      required this.contact,
      required this.qualifications,
      required this.affiliations,
      required this.experience,
      required this.specialization,
      required this.validity,
      this.imgUrl,
      this.avgRating,
      this.noOfReviews});
}
