class PatientUploadedReport {
  final String patientId;
  final List<String> reportIds;
  final DateTime dateCreated;
  final String name;
  final String contact;
  String? imgUrl = '';

  PatientUploadedReport(
      {required this.patientId,
      required this.reportIds,
      required this.dateCreated,
      required this.name,
      required this.contact,
      this.imgUrl});
}
