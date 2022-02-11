import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/ui/size_config.dart';
import 'package:to_do_app/ui/theme.dart';

class InputField extends StatelessWidget {
  const InputField(
      {Key? key,
      required this.title,
      required this.hint,
      this.controller,
      this.widget})
      : super(key: key);

  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      margin: const EdgeInsets.only(top: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle,
          ),
          Container(
              padding: const EdgeInsets.only(top: 8, right: 10, left: 14),
              margin: const EdgeInsets.only(top: 3),
              height: 52,
              width: SizeConfig.screenWidth,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: controller,
                    autofocus: false,
                    cursorColor:
                        Get.isDarkMode ? Colors.grey[100] : Colors.grey[700],
                    readOnly: widget != null ? true : false,
                    style: subTitleStyle,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: subTitleStyle,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              width: 10,
                              color: Theme.of(context).backgroundColor)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              width: 0,
                              color: Theme.of(context).backgroundColor)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              width: 0,
                              color: Theme.of(context).backgroundColor)),
                    ),
                  )),
                  widget ?? Container()
                ],
              )),
        ],
      ),
    );
  }
}
