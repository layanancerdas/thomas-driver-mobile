import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/widgets/custom_text.dart';

class ListFaq extends StatefulWidget {
  final String title, text;
  final List content;

  ListFaq({this.title, this.content, this.text});

  @override
  _ListFaqState createState() => _ListFaqState();
}

class _ListFaqState extends State<ListFaq> {
  bool stretch = false;

  void toggleStretch() {
    setState(() {
      stretch = !stretch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => toggleStretch(),
      child: AnimatedContainer(
          margin: EdgeInsets.symmetric(horizontal: 16),
          constraints: BoxConstraints(minHeight: stretch ? 10 : 0),
          padding: stretch
              ? EdgeInsets.only(top: 14)
              : EdgeInsets.symmetric(vertical: 14),
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(color: ColorsCustom.border, width: 1))
              // boxShadow: [
              //   BoxShadow(
              //       offset: Offset(0, 0),
              //       spreadRadius: 1,
              //       blurRadius: 4,
              //       color: ColorsCustom.black.withOpacity(0.15))
              // ]
              ),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomText(
                    "${widget.title}",
                    color: ColorsCustom.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      // highlightColor: ColorsCustom.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () => toggleStretch(),
                    child: SvgPicture.asset(
                      "assets/images/${stretch ? "arrow_up_black" : "arrow_down_black"}.svg",
                      height: 8,
                    ),
                  ),
                ),
              ],
            ),
            widget.content != null
                ? AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    width: double.infinity,
                    padding: stretch
                        ? EdgeInsets.symmetric(vertical: 8)
                        : EdgeInsets.zero,
                    child: stretch
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: widget.content
                                .map((e) => listPoint(e))
                                .toList(),
                          )
                        : SizedBox())
                : SizedBox(),
            widget.text != null
                ? AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    width: double.infinity,
                    padding: stretch
                        ? EdgeInsets.only(top: 14, bottom: 14)
                        : EdgeInsets.zero,
                    child: stretch
                        ? CustomText(
                            "${widget.text}",
                            color: ColorsCustom.generalText,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 1.8,
                          )
                        : SizedBox())
                : SizedBox()
          ])),
    );
  }

  Widget listPoint(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            width: 4,
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
                color: Color(0xFF75C1D4),
                borderRadius: BorderRadius.circular(2)),
          ),
          SizedBox(width: 10),
          Flexible(
            child: CustomText(
              "$value",
              color: ColorsCustom.generalText,
              fontWeight: FontWeight.w400,
              fontSize: 12,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}
