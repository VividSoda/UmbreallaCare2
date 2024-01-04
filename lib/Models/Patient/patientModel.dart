class PatientInfo {
  final String uid, name, contact;
  String? imgUrl = '';

  PatientInfo(
      {required this.uid,
      required this.name,
      required this.contact,
      this.imgUrl});
}
