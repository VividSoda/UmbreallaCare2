import 'package:flutter/material.dart';
import 'package:umbrella_care/Constants/colors.dart';

class CheckboxOption extends StatelessWidget {
  final String optionText;
  final String optionImage;
  final String selectedOption;
  final Function(String) onOptionSelected;

  const CheckboxOption({
    super.key,
    required this.optionText,
    required this.optionImage,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onOptionSelected(optionText);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(color: primary),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: selectedOption == optionText
                    ? const Icon(
                        Icons.check,
                        size: 20,
                        color: primary,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Image.asset(optionImage),
          ],
        ),
      ),
    );
  }
}
