import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:redux/redux.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/redux/modules/ajk_state.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:tomas_driver/screens/detail_trip/widgets/modal_passenger_list.dart';
import 'package:tomas_driver/widgets/passengers_body.dart';
import 'package:tomas_driver/widgets/qr_scan.dart';

class PassengerList extends StatefulWidget {
  final String title, text, icon, tripGroupId;
  final bool isCompleted;

  PassengerList(
      {this.title, this.text, this.icon, this.isCompleted, this.tripGroupId});

  @override
  _PassengerListState createState() => _PassengerListState();
}

class _PassengerListState extends State<PassengerList> {
  bool stretch = false;

  Store<AppState> store;

  // void showModalBottom(BuildContext bsc, content) {
  //   showModalBottomSheet(
  //     context: bsc,
  //     builder: (btsc) {
  //       return ModalPassengerList();
  //     },
  //   );
  // }

  PersistentBottomSheetController _controller; // <------ Instance variable
  bool isScanned = false;
  // bool isCompleted = false;
  bool isNone = false;
  // List content1 = [];
  // List content2 = [];

  void makeData() {}

  // void changeIsScanned(bool value) {
  //   setState(() {
  //     isScanned = value;
  //   });
  // }

  void showModalBottom(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black.withOpacity(0.20),
        isDismissible: true,
        isScrollControlled: true,
        builder: (context) {
          return PassengerBody(
              isCompleted: widget.isCompleted, tripGroupId: widget.tripGroupId);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 0),
                spreadRadius: 1,
                blurRadius: 4,
                color: ColorsCustom.black.withOpacity(0.15))
          ]),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => showModalBottom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    widget.icon == null
                        ? SizedBox()
                        : SvgPicture.asset(
                            "assets/images/${widget.icon}.svg",
                            height: 16,
                            width: 16,
                          ),
                    SizedBox(width: 12),
                    CustomText(
                      "${AppTranslations.of(context).text("detail_list")}",
                      color: ColorsCustom.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    )
                  ],
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
                    onPressed: () => showModalBottom(context),
                    child: SvgPicture.asset(
                      "assets/images/info_outline.svg",
                      width: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = StoreProvider.of<AppState>(context);
      // getTripdByTripId(store.state.ajkState.selectedMyTrip['trip_order_id']);
      // getCountdown();
      makeData();
    });
  }
}
