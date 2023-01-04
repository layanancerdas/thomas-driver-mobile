import 'package:flutter/material.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:webview_flutter/webview_flutter.dart';
import './webview_view_model.dart';

class WebviewView extends WebviewViewModel {
  @override
  Widget build(BuildContext context) {
    // Replace this with your build function
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: ColorsCustom.primary,
        centerTitle: false,
        title: CustomText(
          "${widget.title ?? ""}",
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      // url: '${widget.link}',
      // hidden: true,
      // withLocalStorage: true,
      // allowFileURLs: true,
      // withJavascript: true,
      // withZoom: false,

      // initialChild: Container(
      //     width: double.infinity,
      //     height: double.infinity,
      //     child: Center(
      //         child: Loading(
      //             indicator: BallSpinFadeLoaderIndicator(),
      //             color: ColorsCustom.primary,
      //             size: 30.0))),

      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: WebView(
              initialUrl: '${widget.link}',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                controller.complete(webViewController);
              },
            ),
          ),
          // BackButtonCustom()
        ],
      ),
    );
  }
}
