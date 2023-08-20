import 'package:flutter/material.dart';
import 'package:insta_clone/utils/global_variables.dart';

class FollowButton extends StatelessWidget {
  final Function()? function;
  final Color baclgroundColor;
  final Color borderColor;
  final Color textColor;
  final String text;
  const FollowButton(
      {super.key,
      this.function,
      required this.baclgroundColor,
      required this.borderColor,
      required this.textColor,
      required this.text});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: function,
        child: Container(
          decoration: BoxDecoration(
            color: baclgroundColor,
            border: Border.all(
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          width: width > webScreenSize ? 150 : 250,
          height: 27,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
