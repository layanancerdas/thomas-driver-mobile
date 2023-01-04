import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/widgets/custom_text.dart';

class PassengerUnscanned extends StatefulWidget {
  final String name;
  final String istd;
  final String asal;
  PassengerUnscanned({this.name, this.istd, this.asal});
  @override
  _PassengerUnscannedState createState() => _PassengerUnscannedState();
}

class _PassengerUnscannedState extends State<PassengerUnscanned> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, bottom: 16, top: 16),
          child: CustomText(
            "${widget.asal}",
            color: ColorsCustom.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          width: screenSize.width,
          child: ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (context, int index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 5),
                    child: CustomText(
                      "${widget.name}",
                      color: ColorsCustom.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 5, right: 16),
                    child: CustomText(
                      "${widget.istd}",
                      color: ColorsCustom.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
