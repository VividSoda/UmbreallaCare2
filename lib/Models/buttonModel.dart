class ButtonModel {
  final String uid;
  bool isSelected;
  final String day, weekDay;

  ButtonModel(
      {required this.uid,
      this.isSelected = false,
      required this.day,
      required this.weekDay});
}
