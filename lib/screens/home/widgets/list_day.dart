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
  List date = [
    // {
    //   'id': 0,
    //   'date': DateTime.now().day,
    //   'day': DateFormat.E().format(DateTime.now()),
    //   'days': DateFormat.EEEE().format(DateTime.now()),
    //   'month': DateFormat.MMMM().format(DateTime.now()),
    //   'year': DateTime.now().add(Duration(days: 1)).year,
    // },
    // {
    //   'id': 1,
    //   'date': DateTime.now().add(Duration(days: 1)).day,
    //   'day': DateFormat.E().format(DateTime.now().add(Duration(days: 1))),
    //   'days': DateFormat.EEEE().format(DateTime.now().add(Duration(days: 1))),
    //   'month': DateFormat.MMMM().format(DateTime.now().add(Duration(days: 1))),
    //   'year': DateTime.now().add(Duration(days: 1)).year,
    // },
    // {
    //   'id': 2,
    //   'date': DateTime.now().add(Duration(days: 2)).day,
    //   'day': DateFormat.E().format(DateTime.now().add(Duration(days: 2))),
    //   'days': DateFormat.EEEE().format(DateTime.now().add(Duration(days: 2))),
    //   'month': DateFormat.MMMM().format(DateTime.now().add(Duration(days: 2))),
    //   'year': DateTime.now().add(Duration(days: 2)).year,
    // },
    // {
    //   'id': 3,
    //   'date': DateTime.now().add(Duration(days: 3)).day,
    //   'day': DateFormat.E().format(DateTime.now().add(Duration(days: 3))),
    //   'days': DateFormat.EEEE().format(DateTime.now().add(Duration(days: 3))),
    //   'month': DateFormat.MMMM().format(DateTime.now().add(Duration(days: 3))),
    //   'year': DateTime.now().add(Duration(days: 3)).year,
    // },
    // {
    //   'id': 4,
    //   'date': DateTime.now().add(Duration(days: 4)).day,
    //   'day': DateFormat.E().format(DateTime.now().add(Duration(days: 4))),
    //   'days': DateFormat.EEEE().format(DateTime.now().add(Duration(days: 4))),
    //   'month': DateFormat.MMMM().format(DateTime.now().add(Duration(days: 4))),
    //   'year': DateTime.now().add(Duration(days: 4)).year,
    // },
    // {
    //   'id': 5,
    //   'date': DateTime.now().add(Duration(days: 5)).day,
    //   'day': DateFormat.E().format(DateTime.now().add(Duration(days: 5))),
    //   'days': DateFormat.EEEE().format(DateTime.now().add(Duration(days: 5))),
    //   'month': DateFormat.MMMM().format(DateTime.now().add(Duration(days: 5))),
    //   'year': DateTime.now().add(Duration(days: 5)).year,
    // }
  ];

  // Future<void> getTripByDriverId() async {
  //   try {
  //     dynamic res = await Providers.getBookingByDriverId(
  //       startDate: "1627862400000",
  //       endDate: "1629910799000"
  //       //1628208000000
  //     );
  //     print(res.data);
  //     if (res.data['message'] == 'SUCCESS') {
  //       store.dispatch(SetMyTrip(
  //         myTrip: res.data['data']));
  //       // SharedPreferences prefs = await SharedPreferences.getInstance();
  //       // await prefs.setString('jwtToken', res.data['data']['token']);
  //       // await prefs.setString('driverId', res.data['data']['driver_id']);

  //       // Navigator.push(context, MaterialPageRoute(builder: (_) => Home()));
  //     } else {
  //       // if (res.data['message'].contains("phone_number")) {
  //       //   setError(type: "phoneNumber", value: "Invalid phone number");
  //       // } else if (res.data['message'].contains("user")) {
  //       //   setError(
  //       //       type: "phoneNumber",
  //       //       value: "Your phone number is not registered");
  //       // }
  //     }
  //   } catch (e) {
  //     print(e);
  //     // setError(type: "login", value: e);
  //   } finally {
  //     // toggleLoading(false);
  //   }
  // }

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
    // print("huhu");

    dynamic res = await Providers.getResolveDate();

    int startDate = DateTime.parse(res.data['data']['start_date'])
        .subtract(Duration(days: 7))
        .day;

    int endDate = DateTime.parse(res.data['data']['end_date'])
        .subtract(Duration(days: 7))
        .day;

    // List _date = [];

    DateTime theDate = DateTime.parse(res.data['data']['start_date'])
        .subtract(Duration(days: 7));

    // for (int i = startDate; i < endDate; i++) {
    //   print("IIiiii");
    //   print(i);
    //   if (date.length < 5) {
    //     if (DateFormat('EEEE', 'en_US')
    //                 .format(theDate.add(Duration(days: i))) !=
    //             "Sunday" &&
    //         DateFormat('EEEE', 'en_US')
    //                 .format(theDate.add(Duration(days: i))) !=
    //             "Saturday") {
    //       _date.add({
    //         'id': _date.length,
    //         'date': theDate.add(Duration(days: i)).day,
    //         'day': DateFormat.E(AppTranslations.of(context).currentLanguage)
    //             .format(theDate.add(Duration(days: i))),
    //         'days': DateFormat.EEEE(AppTranslations.of(context).currentLanguage)
    //             .format(theDate.add(Duration(days: i))),
    //         'month':
    //             DateFormat.MMMM(AppTranslations.of(context).currentLanguage)
    //                 .format(theDate.add(Duration(days: i))),
    //         'year': theDate.add(Duration(days: i)).year,
    //         'isToday': i == 0
    //       });
    //     }
    //   }
    // }

    // var nowDate = DateTime.now();
    List _date = [];
    int o = 0;
    for (int i = startDate; i <= endDate; i++) {
      if (date.length <= 7) {
        // if (DateFormat('EEEE', 'en_US')
        //             .format(theDate.add(Duration(days: o))) !=
        //         "Sunday" &&
        //     DateFormat('EEEE', 'en_US')
        //             .format(theDate.add(Duration(days: o))) !=
        //         "Saturday") {
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
