import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tomas_driver/localization/app_translations.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:tomas_driver/widgets/qr_scan.dart';

class ScanAttendance extends StatefulWidget {
  final String title, text, tripOrderId;
  final List content;

  final detailFunction;

  ScanAttendance(
      {this.title,
      this.content,
      this.text,
      this.detailFunction,
      this.tripOrderId});

  @override
  _ScanAttendanceState createState() => _ScanAttendanceState();
}

class _ScanAttendanceState extends State<ScanAttendance> {
  bool stretch = false;

  void toggleStretch() {
    setState(() {
      stretch = !stretch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Color(0xFF75C1D4), width: 1),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      onPressed: () {
        Navigator.push(context,
                MaterialPageRoute(builder: (_) => QRScan(widget.tripOrderId)))
            .then((value) => {widget.detailFunction(widget.tripOrderId)});
      },
      child: Container(
        height: 44,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset("assets/images/scan_icon_blue.svg"),
              SizedBox(
                width: 8,
              ),
              CustomText(
                AppTranslations.of(context).text("detail_scan"),
                color: Color(0xFF75C1D4),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
