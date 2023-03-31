import 'dart:io';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:tomas_driver/configs/config.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/helpers/utils.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/providers/providers.dart';
import 'package:tomas_driver/redux/actions/ajk_action.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:tomas_driver/widgets/custom_toast.dart';

import 'image_scanner_animation.dart';

class QRScan extends StatefulWidget {
  String tripGroupId;
  QRScan(this.tripGroupId);

  @override
  State<StatefulWidget> createState() => _QRScanState();
}

class _QRScanState extends State<QRScan> with SingleTickerProviderStateMixin {
  Store<AppState> store;
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  AnimationController _animationController;
  bool _animationStopped = false;

  bool isScanned = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
        title: CustomText(
          AppTranslations.of(context).text("qr_title"),
          color: Color(0xFF26282B),
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(),
            child: CustomText(
              AppTranslations.of(context).text("qr_cancel"),
              color: Color(0xFF75C1D4),
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.15,
                color: Colors.white,
                child: CustomText(
                  AppTranslations.of(context).text("qr_info"),
                  textAlign: TextAlign.center,
                  color: Color(0xFF26282B),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              Expanded(flex: 4, child: _buildQrView(context)),
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.15,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CustomText(
                  AppTranslations.of(context).text("qr_reload"),
                  textAlign: TextAlign.center,
                  color: Color(0xFF448FA2),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Center(
            child: DottedBorder(
              borderType: BorderType.RRect,
              color: Color(0xFF75C1D4),
              radius: Radius.circular(30),
              dashPattern: [8, 4],
              strokeWidth: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                height: 304,
                width: 256,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Center(
                    //   child: Container(
                    //     height: 80,
                    //     width: 80,
                    //     decoration: BoxDecoration(
                    //         image: DecorationImage(
                    //             image: AssetImage("assets/images/qr_code.png"),
                    //             fit: BoxFit.cover)),
                    //   ),
                    // ),
                    // Container(
                    //   height: 8,
                    //   width: 200,
                    //   decoration: BoxDecoration(
                    //       image: DecorationImage(
                    //           image:
                    //               AssetImage("assets/images/Rectangle135.png"),
                    //           fit: BoxFit.fill)),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 16, top: 24),
                    //   child: Container(
                    //     width: 147,
                    //     height: 36,
                    //     child: ElevatedButton(style: TextButton.styleFrom(),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(18.0),
                    //       ),
                    //       color: Color(0xFF75C1D4),
                    //       onPressed: () {
                    //         Navigator.of(context).pop();
                    //       },
                    //       child: Align(
                    //         alignment: Alignment.center,
                    //         child: CustomText(
                    //           "OK",
                    //           color: Colors.white,
                    //           fontWeight: FontWeight.w400,
                    //           fontSize: 12,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    // var scanArea = (MediaQuery.of(context).size.width < 300 ||
    //         MediaQuery.of(context).size.height < 400)
    //     ? 150.0
    //     : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
        ImageScannerAnimation(
          _animationStopped,
          screenSize.width,
          animation: _animationController,
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (!isScanned) {
        print(scanData.code);
        scanUser(scanData.code);
      }
    });
  }

  void animateScanAnimation(bool reverse) {
    if (reverse) {
      _animationController.reverse(from: 1.0);
    } else {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void initState() {
    _animationController =
        new AnimationController(duration: new Duration(seconds: 1), vsync: this)
          ..forward();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animateScanAnimation(true);
      } else if (status == AnimationStatus.dismissed) {
        animateScanAnimation(false);
      }
    });

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = StoreProvider.of<AppState>(context);
      getPassanger();
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    controller?.dispose();
    super.dispose();
  }

  Future<void> getPassanger() async {
    try {
      dynamic res =
          await Providers.getPassengers(tripGroupId: widget.tripGroupId);
      store.dispatch(SetSelectedPassanger(selectedPassanger: res.data['data']));
      print(res.data['data']);
    } catch (e) {
      print(e);
    }
  }

  Future<void> scanUser(String urlData) async {
    setState(() {
      isScanned = true;
    });
    try {
      String _urlData = urlData.contains(
              "https://tomas-api-dev.OutlinedButton(style: OutlinedButton.styleFrom(),")
          ? urlData.replaceAll('https://tomas-api-dev.geekco.id', BASE_URL)
          : urlData;

      print(_urlData);

      dynamic res = await Providers.sendAttendance(url: _urlData);

      if (res.data['message'] == 'SUCCESS') {
        await getPassanger();

        showDialog(
            context: context,
            barrierColor: Colors.white24,
            builder: (BuildContext context) {
              return CustomToast(
                image: "success_icon_white.svg",
                title: AppTranslations.of(context).currentLanguage == 'id'
                    ? "Kode QR telah dipindai."
                    : "The QR code has been scanned.",
                color: ColorsCustom.green,
                duration: Duration(seconds: 3),
              );
            });
      } else {
        showDialog(
            context: context,
            barrierColor: Colors.white24,
            builder: (BuildContext context) {
              return CustomToast(
                image: "warning.svg",
                title: Utils.capitalizeFirstofEach("Please try again."),
                color: ColorsCustom.yellow,
                duration: Duration(seconds: 3),
              );
            });
      }
    } catch (e) {
      print(e);
      // await showDialog(
      //   context: context,
      //   barrierColor: Colors.white24,
      //   builder: (BuildContext context) {
      //     return CustomToast(
      //       image: "warning.svg",
      //       title: "Something wrong",
      //       color: ColorsCustom.danger,
      //       duration: Duration(seconds: 1),
      //     );
      //   });
    } finally {
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          isScanned = false;
        });
      });
    }
  }
}
