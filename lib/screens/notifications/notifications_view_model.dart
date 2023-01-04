import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/providers/providers.dart';
import 'package:tomas_driver/redux/actions/ajk_action.dart';
import 'package:tomas_driver/redux/actions/general_action.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/screens/home/home.dart';
import 'package:tomas_driver/screens/lifecycle_manager/lifecycle_manager.dart';
import 'package:tomas_driver/widgets/custom_toast.dart';
import './notifications.dart';

abstract class NotificationsViewModel extends State<Notifications> {
  Store<AppState> store;
  List selected = List();
  List dummy = [];

  List dummy2 = [];

  bool disableShow = false;

  // Future<void> getNotification() async {
  //   try {
  //     dynamic res = await Providers.getNotifByUserId(limit: 10, offset: 0);

  //     store.dispatch(SetNotifications(
  //         notifications: res.data['data'],
  //         limitNotif: store.state.generalState.limitNotif + 10));

  //     if (res.data['data'].length > 0 &&
  //         (res.data['code'] == '00' || res.data['code'] == 'SUCCESS')) {
  //       setState(() {
  //         disableShow = false;
  //       });
  //     } else {
  //       setState(() {
  //         disableShow = true;
  //       });
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future<void> onShowMore() async {
    try {
      dynamic res = await Providers.getNotifByUserId(
          limit: store.state.generalState.limitNotif + 10,
          offset: store.state.generalState.notifications.length);

      if (res.data['data'].length > 0 &&
          (res.data['code'] == '00' || res.data['code'] == 'SUCCESS')) {
        List _temp = res.data['data']
            .where((e) => e['is_active'].toString() == 'true')
            .toList();

        store.dispatch(SetNotifications(notifications: [
          ...store.state.generalState.notifications,
          ..._temp
        ], limitNotif: store.state.generalState.limitNotif + 10));

        setState(() {
          disableShow = false;
        });
      } else {
        setState(() {
          disableShow = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void onClearSelected() {
    setState(() {
      selected = [];
    });
  }

  Future<void> onUpdate(String type) async {
    if (selected.length <= 0) {
      return onError();
    }
    store.dispatch(SetIsLoading(isLoading: true));
    try {
      List _temp = selected.map((e) {
        return {
          "notification_id": e['notification_id'],
          'is_read': true,
          'is_active': type == 'delete' ? false : true
        };
      }).toList();

      dynamic res = await Providers.updateNotif(notif: _temp);

      print("updateNotif");
      print(_temp);
      print(res);

      if (res.data['code'] == '00' || res.data['code'] == 'SUCCESS') {
        await LifecycleManager.of(context).getNotifications();
        setState(() {
          selected = [];
        });
        if (type != 'read') {
          store.dispatch(SetDisableNavbar(
              disableNavbar: !store.state.generalState.disableNavbar));
        }
      }
    } catch (e) {
      print(e);
    } finally {
      await LifecycleManager.of(context).getNotifications();
      store.dispatch(SetIsLoading(isLoading: false));
    }
  }

  void onClickNotification(Map data) async {
    selected.add(data);
    onUpdate('read');
    if (data['type'] == "DRIVER_GOT_ASSIGNMENT") {
      Home.of(context).onTabTapped(1);
    } else if (data['type'] == "DRIVER_MISSING_SCHEDULE") {
      //Home.of(context).onTabTapped(1);
    } else {
      Map newData = json.decode(data['data']);
      getTripdByTripId(newData['trip_history_id']);
    }
  }

  Future<void> getTripdByTripId(String tripId) async {
    store.dispatch(SetIsLoading(isLoading: true));
    try {
      dynamic res = await Providers.getTripHistoryById(tripId: tripId);

      dynamic res2 = await Providers.getTripByTripId(
          tripId: res.data['data']['trip_order_id']);
      store.dispatch(SetSelectedMyTrip(selectedMyTrip: res2.data['data']));
      Navigator.pushNamed(context, "/DetailTrip");
    } catch (e) {
      print(e);
    } finally {
      store.dispatch(SetIsLoading(isLoading: false));
    }
  }

  // void onMarkAsRead() {
  //   if (selected.length <= 0) {
  //     return onError();
  //   }

  //   setState(() {
  //     store.state.generalState.notifications.forEach((e) {
  //       selected.forEach((item) {
  //         if (e == item) {
  //           item['is_read'] = true;
  //         }
  //       });
  //     });
  //     // selected = [];
  //   });
  //   store.dispatch(SetDisableNavbar(
  //       disableNavbar: !store.state.generalState.disableNavbar));
  //   onUpdate("read");
  // }

  void onError() {
    showDialog(
        context: context,
        barrierColor: Colors.white24,
        builder: (BuildContext context) {
          return CustomToast(
            title: AppTranslations.of(context).currentLanguage == 'id'
                ? "Silahkan pilih satu atau lebih notifikasi terlebih dahulu."
                : "Please select one or more notifications first.",
            color: ColorsCustom.primary,
            duration: Duration(seconds: 1),
          );
        });
  }

  // void onDelete() {
  //   if (selected.length <= 0) {
  //     return onError();
  //   }

  //   setState(() {
  //     selected.forEach((element) {
  //       store.state.generalState.notifications.remove(element);
  //     });
  //     // selected = [];
  //   });
  //   store.dispatch(SetDisableNavbar(
  //       disableNavbar: !store.state.generalState.disableNavbar));
  //   onUpdate("delete");
  // }

  void onSelectAll() {
    setState(() {
      if (selected.length == store.state.generalState.notifications.length) {
        selected = [];
      } else {
        selected = store.state.generalState.notifications;
      }
    });
  }

  void onSelect(Map data) {
    setState(() {
      if (selected.contains(data)) {
        selected.remove(data);
      } else {
        selected.add(data);
      }
    });
  }

  void toggleMoreMode() {
    if (store.state.generalState.disableNavbar) {
      onClearSelected();
    }
    store.dispatch(SetDisableNavbar(
        disableNavbar: !store.state.generalState.disableNavbar));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = StoreProvider.of<AppState>(context);
      LifecycleManager.of(context).getNotifications();
    });
  }
}
