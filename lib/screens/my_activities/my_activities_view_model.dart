import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:redux/redux.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/providers/providers.dart';
import 'package:tomas_driver/redux/actions/ajk_action.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/widgets/modal_no_location.dart';
import './my_activities.dart';

abstract class MyActivitiesViewModel extends State<MyActivities> {
  // Add your state and logic here
  Store<AppState> store;
  StreamSubscription<Position> positionStream;

  RefreshController refreshControllerAssigned =
      RefreshController(initialRefresh: false);
  RefreshController refreshControllerOngoing =
      RefreshController(initialRefresh: false);
  RefreshController refreshControllerComplete =
      RefreshController(initialRefresh: false);

  int currentIndex = 0;

  List<Placemark> placemark = List();

  bool isLoading = false;

  void toggleLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  // Future<void> getCurrentLocation() async {
  //   try {
  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.best);
  //     List<Placemark> _placemark =
  //         await placemarkFromCoordinates(position.latitude, position.longitude);

  //     setState(() {
  //       placemark = _placemark;
  //     });
  //   } catch (e) {
  //     print(e);
  //   } finally {
  //     toggleLoading(false);
  //   }
  // }

  // void locationListener(Position position) {}

  // Future listenForPermissionStatus() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();

  //   if (!serviceEnabled) {
  //     showModalBottomSheet(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return ModalNoLocation();
  //         });
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //         'Location permissions are permantly denied, we cannot request permissions.');
  //   }

  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission != LocationPermission.whileInUse &&
  //         permission != LocationPermission.always) {
  //       await Geolocator.openLocationSettings();
  //     }
  //   }
  //   // await getCurrentLocation();
  // }

  // void showDialogComingSoon() {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return ModalComingSoon();
  //       });
  // }

  Future<void> onLoadingAssigned() async {
    try {
      dynamic res = await Providers.getTripByStatus(
          status: "ASSIGNED",
          limit: 10,
          offset: store.state.ajkState.assignedTrip.length);

      if (res.data['data'].length > 0 &&
          (res.data['code'] == '00' || res.data['code'] == 'SUCCESS')) {
        List _sortingData = [
          ...store.state.ajkState.assignedTrip,
          ...res.data['data']
        ];

        _sortingData.sort((a, b) =>
            a['trip']['departure_time'].compareTo(b['trip']['departure_time']));
        await store.dispatch(SetAssignedTrip(assignedTrip: _sortingData));
        refreshControllerAssigned.loadComplete();
      } else {
        refreshControllerAssigned.loadNoData();
      }
    } catch (e) {
      print("onLoading Active:");
      print(e);
    }
  }

  Future<void> onRefreshAssigned() async {
    try {
      dynamic res = await Providers.getTripByStatus(
          status: "ASSIGNED", limit: 10, offset: 0);

      if (res.data['data'].length > 0 &&
          (res.data['code'] == '00' || res.data['code'] == 'SUCCESS')) {
        List _sortingData = res.data['data'];
        _sortingData.sort((a, b) =>
            a['trip']['departure_time'].compareTo(b['trip']['departure_time']));
        await store.dispatch(SetAssignedTrip(assignedTrip: _sortingData));
        refreshControllerAssigned.refreshCompleted();
      } else {
        refreshControllerAssigned.refreshToIdle();
      }
    } catch (e) {
      print("onRefresh Active:");
      print(e);
    }
  }

  Future<void> onLoadingOnGoing() async {
    try {
      dynamic res = await Providers.getTripByStatus(
          status: "ONGOING",
          limit: 10,
          offset: store.state.ajkState.ongoingTrip.length);

      if (res.data['data'].length > 0 &&
          (res.data['code'] == '00' || res.data['code'] == 'SUCCESS')) {
        List _sortingData = [
          ...store.state.ajkState.ongoingTrip,
          ...res.data['data']
        ];
        _sortingData.sort((a, b) =>
            a['trip']['departure_time'].compareTo(b['trip']['departure_time']));

        await store.dispatch(SetOngoingTrip(ongoingTrip: _sortingData));
        refreshControllerOngoing.loadComplete();
      } else {
        refreshControllerOngoing.loadNoData();
      }
    } catch (e) {
      print("onLoading Active:");
      print(e);
    }
  }

  Future<void> onRefreshOnGoing() async {
    try {
      dynamic res = await Providers.getTripByStatus(
          status: "ONGOING", limit: 10, offset: 0);

      if (res.data['data'].length > 0 &&
          (res.data['code'] == '00' || res.data['code'] == 'SUCCESS')) {
        List _sortingData = res.data['data'];
        _sortingData.sort((a, b) =>
            a['trip']['departure_time'].compareTo(b['trip']['departure_time']));
        await store.dispatch(SetOngoingTrip(ongoingTrip: _sortingData));
        refreshControllerOngoing.refreshCompleted();
      } else {
        refreshControllerOngoing.refreshToIdle();
      }
    } catch (e) {
      print("onRefresh Active:");
      print(e);
    }
  }

  Future<void> onLoadingCompleted() async {
    print('COMPLETED');
    try {
      dynamic res = await Providers.getTripByStatus(
          status: "COMPLETED",
          limit: 10,
          offset: store.state.ajkState.completedTrip.length);

      if (res.data['data'].length > 0 &&
          (res.data['code'] == '00' || res.data['code'] == 'SUCCESS')) {
        List _sortingData = [
          ...store.state.ajkState.completedTrip,
          ...res.data['data']
        ];
        _sortingData.sort((a, b) =>
            a['trip']['departure_time'].compareTo(b['trip']['departure_time']));
        await store.dispatch(SetCompletedTrip(completedTrip: _sortingData));
        refreshControllerComplete.loadComplete();
      } else {
        refreshControllerComplete.loadNoData();
      }
    } catch (e) {
      print("onLoading Active:");
      print(e);
    }
  }

  Future<void> onRefreshCompleted() async {
    try {
      dynamic res = await Providers.getTripByStatus(
          status: "COMPLETED", limit: 10, offset: 0);

      if (res.data['data'].length > 0 &&
          (res.data['code'] == '00' || res.data['code'] == 'SUCCESS')) {
        List _sortingData = res.data['data'];
        _sortingData.sort((a, b) =>
            a['trip']['departure_time'].compareTo(b['trip']['departure_time']));
        await store.dispatch(SetCompletedTrip(completedTrip: _sortingData));
        refreshControllerComplete.refreshCompleted();
      } else {
        refreshControllerComplete.refreshToIdle();
      }
    } catch (e) {
      print("onRefresh Active:");
      print(e);
    }
  }

  Future<void> getAssignedTrip() async {
    try {
      dynamic res = await Providers.getTripByStatus(
          limit: 10, offset: 0, status: "ASSIGNED");
      if (res.data['message'] == 'SUCCESS') {
        List _sortingData = res.data['data'];
        _sortingData.sort((a, b) =>
            a['trip']['departure_time'].compareTo(b['trip']['departure_time']));

        store.dispatch(SetAssignedTrip(assignedTrip: _sortingData));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getOngoingTrip() async {
    try {
      dynamic res = await Providers.getTripByStatus(
          limit: 10, offset: 0, status: "ONGOING");
      if (res.data['message'] == 'SUCCESS') {
        List _sortingData = res.data['data'];
        _sortingData.sort((a, b) =>
            a['trip']['departure_time'].compareTo(b['trip']['departure_time']));

        store.dispatch(SetOngoingTrip(ongoingTrip: _sortingData));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getCompletedTrip() async {
    try {
      dynamic res = await Providers.getTripByStatus(
          limit: 10, offset: 0, status: "COMPLETED");
      print(res.data);
      if (res.data['message'] == 'SUCCESS') {
        List _sortingData = res.data['data'];
        _sortingData.sort((a, b) =>
            a['trip']['departure_time'].compareTo(b['trip']['departure_time']));

        store.dispatch(SetCompletedTrip(completedTrip: _sortingData));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    // currentIndex = widget.index;
    // listenForPermissionStatus();
    // getCurrentLocation();
    getAssignedTrip();
    getOngoingTrip();
    getCompletedTrip();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = StoreProvider.of<AppState>(context);
      // Future.delayed(Duration(milliseconds: 200), () => widget.tab = null);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (positionStream != null) {
      positionStream.cancel();
      positionStream = null;
    }
  }
}
