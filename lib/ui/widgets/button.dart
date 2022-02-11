import 'package:flutter/material.dart';
import 'package:to_do_app/ui/theme.dart';

class MyButton extends StatelessWidget {
  const MyButton({required this.label, required this.onTap, Key? key})
      : super(key: key);

  final String label;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: primaryClr, borderRadius: BorderRadius.circular(10)),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
