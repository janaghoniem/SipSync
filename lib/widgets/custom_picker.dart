import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPicker extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> options;
  final String selectedValue;
  final Function(String) onChanged;

  const CustomPicker({
    Key? key,
    required this.label,
    required this.icon, // Icon parameter
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align label and picker
      children: [
        // Label with Icon
        Row(
          children: [
            Icon(icon, size: 20, color: const Color.fromARGB(255, 15, 94, 140)), // Themed icon color
            const SizedBox(width: 8), // Spacing between icon and text
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ],
        ),

        // Picker container
        Container(
          width: 170,
          height: 120, // Adjusted for better visibility
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Wrap CupertinoPicker inside CupertinoTheme
              CupertinoTheme(
                data: const CupertinoThemeData(
                  brightness: Brightness.light,
                  primaryColor: Colors.transparent,
                  scaffoldBackgroundColor: Colors.transparent,
                  barBackgroundColor: Colors.transparent,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: options.indexOf(selectedValue),
                    ),
                    itemExtent: 35,
                    onSelectedItemChanged: (index) {
                      onChanged(options[index]);
                    },
                    backgroundColor: Colors.transparent,
                    children: options.map((option) {
                      bool isSelected = option == selectedValue;
                      return Center(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: isSelected ? 18 : 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? const Color.fromARGB(255, 15, 94, 140)
                                : Colors.black.withOpacity(0.5),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Shorter blue selection lines with padding
              Positioned(
                top: 35,
                left: 15,
                right: 15,
                child: Divider(color: const Color.fromARGB(255, 15, 94, 140), thickness: 2),
              ),
              Positioned(
                bottom: 35,
                left: 15,
                right: 15,
                child: Divider(color: const Color.fromARGB(255, 15, 94, 140), thickness: 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
