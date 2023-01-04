import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomas_driver/configs/config.dart';

class Providers {
  static String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$CLIENT_ID:$CLIENT_SECRET'));

  static Future signIn({String phoneNumber, String password}) async {
    return Dio().post('$BASE_API/ajk/drivers/login',
        data: {'phone_number': phoneNumber, 'password': password},
        options: Options(
            headers: {'authorization': basicAuth},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future getBookingByTripId({String tripId}) async {
    return Dio().get('$BASE_API/ajk/booking',
        queryParameters: {"trip_id": tripId},
        options: Options(
            headers: {'authorization': basicAuth},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future forgotPassword({String phoneNumber}) async {
    return Dio().post('$BASE_API/ajk/drivers/forgot_password',
        data: {'phone_number': phoneNumber},
        options: Options(
            headers: {'authorization': basicAuth},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future changePassword(
      {String password, String driverId, String token}) async {
    return Dio().put('$BASE_API/ajk/drivers/login',
        data: {'driver_id': driverId, 'password': password},
        options: Options(
            headers: {'authorization': basicAuth, 'token': token},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future getUserDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String driverId = prefs.getString("driverId");

    return Dio().get('$BASE_API/ajk/drivers',
        queryParameters: {"driver_id": driverId},
        options: Options(
            headers: {'authorization': basicAuth},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future getPassengers({String tripGroupId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("jwtToken");

    return Dio().get('$BASE_API/ajk/trips/$tripGroupId/passengers',
        options: Options(
            headers: {'authorization': basicAuth, 'token': jwtToken},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future getNotifByUserId({int limit, int offset}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("jwtToken");
    String driverId = prefs.getString("driverId");

    return Dio().get('$BASE_API/notification/notifications',
        queryParameters: {
          'user_id': driverId,
          'actor': "DRIVER",
          "limit": limit ?? 10,
          "offset": offset ?? 0,
        },
        options: Options(
            headers: {'authorization': basicAuth, 'token': jwtToken},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future updateNotif({List notif}) async {
    return Dio().put('$BASE_API/notification/notifications',
        data: notif,
        options: Options(
            headers: {'authorization': basicAuth},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future subscribeNotification(
      {String firebaseToken, String language}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("jwtToken");

    Map userData = JwtDecoder.decode(jwtToken);

    return Dio().post('$BASE_API/notification/subscribers',
        data: {
          'user_id': userData['driver_id'],
          'firebase_token': firebaseToken,
          'actor': "DRIVER",
          'language': language ?? "ENGLISH"
        },
        options: Options(
            headers: {'authorization': basicAuth},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future getBookingByDriverId({String startDate, String endDate}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("jwtToken");
    String driverId = prefs.getString("driverId");
    return Dio().get('$BASE_API/ajk/trip_order',
        queryParameters: {
          "driver_id": driverId,
          "start_date": startDate,
          "end_date": endDate
        },
        options: Options(
            headers: {'authorization': basicAuth, 'token': jwtToken},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future getResolveDate() async {
    return Dio().get('$BASE_API/ajk/trips/resolve_date',
        options: Options(
            headers: {'authorization': basicAuth},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future getTripByTripId({String tripId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("jwtToken");
    return Dio().get('$BASE_API/ajk/trip_order',
        queryParameters: {"trip_order_id": tripId},
        options: Options(
            headers: {'authorization': basicAuth, 'token': jwtToken},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future manageTrip(
      {String tripOrderId, String type, String pickupPointId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("jwtToken");
    return Dio().post('$BASE_API/ajk/trip_histories',
        data: {
          "trip_order_id": tripOrderId,
          "pickup_point_id": pickupPointId,
          "type": type
        },
        options: Options(
            headers: {'authorization': basicAuth, 'token': jwtToken},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future sendAttendance({String url}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("jwtToken");
    return Dio().get(url,
        options: Options(
            headers: {'authorization': basicAuth, 'token': jwtToken},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future getTripByStatus({String status, int limit, int offset}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("jwtToken");
    String driverId = prefs.getString("driverId");
    return Dio().get('$BASE_API/ajk/trip_order',
        queryParameters: {
          "driver_id": driverId,
          "limit": limit,
          "offset": offset,
          "status": status
        },
        options: Options(
            headers: {'authorization': basicAuth, 'token': jwtToken},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future getETATime({Map origin, Map destination}) async {
    return Dio().get(
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${origin['lat']},${origin['lng']}&destinations=${destination['lat']},${destination['lng']}&key=$GOOGLE_API_KEY',
        options: Options(
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future getTripHistoryById({String tripId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Dio().get('$BASE_API/ajk/trip_histories',
        queryParameters: {"trip_history_id": tripId},
        options: Options(
            headers: {'authorization': basicAuth},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }

  static Future getBookingByTrip({String tripId}) async {
    return Dio().get('$BASE_API/ajk/booking',
        queryParameters: {"trip_order_id": tripId},
        options: Options(
            headers: {'authorization': basicAuth},
            followRedirects: false,
            validateStatus: (status) {
              return status < 1000;
            }));
  }
}
