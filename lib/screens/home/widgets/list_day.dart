import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/providers/providers.dart';
import 'package:tomas_driver/redux/actions/ajk_action.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/screens/home/widgets/button_date.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:intl/intl.dart';

class ListDay extends StatefulWidget {
  final getTripByDriverId;

  ListDay({this.getTripByDriverId});

  @override
  _ListDayState createState() => _ListDayState();
}

class _ListDayState extends State<ListDay> {
  Store<AppState> store;
  int selectedId = 0;
  List date = [];

  List monthArray = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  List monthArrayId = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember"
  ];

  void onSelect(int value) {
    setState(() {
      selectedId = value;
    });
    getTripBySelected();
  }

  void getTripBySelected() {
    var newMA = AppTranslations.of(context).currentLanguage == 'en'
        ? monthArray
        : monthArrayId;
    var vDate = date[selectedId]['date'].toString().length == 1
        ? "0${date[selectedId]['date']}"
        : "${date[selectedId]['date']}";
    var vMonth = newMA.indexOf(date[selectedId]['month']) + 1;
    var finalVMonth =
        vMonth.toString().length == 1 ? "0${vMonth}" : "${vMonth}";

    var stringDate = "${date[selectedId]['year']}-${finalVMonth}-${vDate}";
    widget.getTripByDriverId(
        DateTime.parse(stringDate + " 00:00:00.000")
            .millisecondsSinceEpoch
            .toString(),
        DateTime.parse(stringDate + " 23:59:59.000")
            .millisecondsSinceEpoch
            .toString());
  }

  Future<void> initDate() async {
    print("huhu");

    dynamic res = await Providers.getResolveDate();

    int startDate = DateTime.parse(res.data['data']['start_date'])
        .subtract(Duration(days: 8))
        .day;

    int endDate = DateTime.parse(res.data['data']['end_date'])
        .subtract(Duration(days: 8))
        .day;

    // List _date = [];

    DateTime theDate = DateTime.parse(res.data['data']['start_date'])
        .subtract(Duration(days: 8));
    List _date = [];
    int o = 0;
    for (int i = startDate; i <= endDate; i++) {
      if (date.length <= 7) {
        if (i == DateTime.now().day) {
          setState(() {
            selectedId = o;
          });
        }
        _date.add({
          'id': o,
          'date': theDate.add(Duration(days: o)).day,
          'day': DateFormat.E(AppTranslations.of(context).currentLanguage)
              .format(theDate.add(Duration(days: o))),
          'days': DateFormat.EEEE(AppTranslations.of(context).currentLanguage)
              .format(theDate.add(Duration(days: o))),
          'month': DateFormat.MMMM(AppTranslations.of(context).currentLanguage)
              .format(theDate.add(Duration(days: o))),
          'year': theDate.add(Duration(days: o)).year,
          'isToday': i == DateTime.now().day
        });
        o++;
      }
      // }
    }
    setState(() {
      date = _date;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = StoreProvider.of(context);
      Future.delayed(Duration(milliseconds: 5), () {
        initDate();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          width: double.infinity,
          child: Row(
            children: date
                .map((e) => Expanded(
                      child: ButtonDate(
                          data: e, onPress: onSelect, selectedId: selectedId),
                    ))
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          child: Row(
            children: [
              CustomText(
                date.length > 0 && date[selectedId]['isToday']
                    ? "${AppTranslations.of(context).text("home_today")}, "
                    : "",
                color: ColorsCustom.generalText,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
              CustomText(
                date.length > 0
                    ? "${date[selectedId]['days']}, ${date[selectedId]['date']} ${date[selectedId]['month']} ${date[selectedId]['year']}"
                    : "",
                fontWeight: FontWeight.w400,
                color: ColorsCustom.black,
              )
            ],
          ),
        )
      ],
    );
  }
}

// DateFormat.MMMM().format(DateTime.now())
