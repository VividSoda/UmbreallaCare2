class PatientAppointmentInfo {
  final DateTime appointmentDate;
  final String name;
  final String contact;
  final int bookedTime;
  String? imgUrl = '';

  PatientAppointmentInfo(
      {required this.appointmentDate,
      required this.name,
      required this.contact,
      required this.bookedTime,
      this.imgUrl});
}
