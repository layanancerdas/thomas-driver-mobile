import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/helpers/utils.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/redux/modules/general_state.dart';
// import 'package:tomas_driver/screens/review/review.dart';
import 'package:tomas_driver/widgets/custom_text.dart';

class NotifList extends StatefulWidget {
  final Map data;
  final List listSelected;
  final onSelected;
  final onClickNotification;

  NotifList(
      {this.data,
      this.onSelected,
      this.listSelected,
      this.onClickNotification});

  @override
  _NotifListState createState() => _NotifListState();
}

class _NotifListState extends State<NotifList> {
  String formatTime() {
    if (DateTime.fromMillisecondsSinceEpoch(
                int.parse(widget.data['created_date']))
            .day ==
        DateTime.now().day) {
      return DateFormat('HH:mm', AppTranslations.of(context).currentLanguage)
          .format(DateTime.fromMillisecondsSinceEpoch(
              int.parse(widget.data['created_date'])));
    } else if (DateTime.fromMillisecondsSinceEpoch(
                int.parse(widget.data['created_date']))
            .day ==
        DateTime.now().day - 1) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM', AppTranslations.of(context).currentLanguage)
          .format(DateTime.fromMillisecondsSinceEpoch(
              int.parse(widget.data['created_date'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, GeneralState>(
        converter: (store) => store.state.generalState,
        builder: (context, state) {
          return Row(
            children: [
              state.disableNavbar
                  ? Container(
                      margin: EdgeInsets.symmetric(horizontal: 14),
                      width: 24,
                      height: 24,
                      child: TextButton(
                          style: TextButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () => widget.onSelected(widget.data),
                          child: widget.listSelected.contains(widget.data)
                              ? SvgPicture.asset('assets/images/check.svg')
                              : SvgPicture.asset(
                                  "assets/images/rectangle.svg")),
                    )
                  : SizedBox(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        // highlightColor: Colors.black12,
                        backgroundColor: widget.data['is_read']
                            ? Colors.white
                            : Color(0xFFFFF7ED),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: state.disableNavbar
                            ? RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ))
                            : null,
                      ),
                      onPressed: () {
                        widget.onClickNotification(widget.data);
                      },
                      //  => Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (_) => Review(),
                      //         fullscreenDialog: true)),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color:
                                    ColorsCustom.primaryLow.withOpacity(0.64),
                                borderRadius: BorderRadius.circular(10)),
                            child: SvgPicture.asset(
                              'assets/images/steeringwheel.svg',
                              height: 14,
                              width: 14,
                            ),
                          ),
                          SizedBox(width: 16),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      // "${Utils.capitalizeFirstofEach(widget.data['type'])}",
                                      "AJK",
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: ColorsCustom.generalText,
                                    ),
                                    CustomText(
                                      "${formatTime()}",
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: ColorsCustom.generalText,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                CustomText(
                                  AppTranslations.of(context).currentLanguage ==
                                          "en"
                                      ? Utils.capitalizeFirstofEach(
                                          widget.data['title_en'])
                                      : Utils.capitalizeFirstofEach(
                                          widget.data['title_id']),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: ColorsCustom.black,
                                ),
                                SizedBox(height: 4),
                                CustomText(
                                  AppTranslations.of(context).currentLanguage ==
                                          "en"
                                      ? Utils.capitalizeFirstofEach(
                                          widget.data['message_en'])
                                      : Utils.capitalizeFirstofEach(
                                          widget.data['message_id']),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: ColorsCustom.black,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 1,
                      color: ColorsCustom.border,
                      width: double.infinity,
                      margin: state.disableNavbar
                          ? EdgeInsets.only(left: 16)
                          : EdgeInsets.zero,
                    )
                  ],
                ),
              ),
            ],
          );
        });
  }
}
