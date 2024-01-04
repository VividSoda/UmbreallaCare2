class DoctorAppointmentInfo {
  final DateTime appointmentDate;
  final String name;
  final String speciality;
  final int bookedTime;
  String? imgUrl = '';

  DoctorAppointmentInfo(
      {required this.appointmentDate,
      required this.name,
      required this.speciality,
      required this.bookedTime,
      this.imgUrl});
}
