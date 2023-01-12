import 'package:flutter/material.dart';
import './lifecycle_manager_view_model.dart';

class LifecycleManagerView extends LifecycleManagerViewModel {
  @override
  Widget build(BuildContext context) {
    return
        // Stack(
        //   children: [
        widget.child;
    //     isLoading
    //         ? Container(
    //             width: double.infinity,
    //             height: double.infinity,
    //             color: Colors.white70,
    //             alignment: Alignment.center,
    //             child: SizedBox(
    //               height: 50,
    //               width: 50,
    //               child: Loading(
    //                 color: ColorsCustom.primary,
    //                 indicator: BallSpinFadeLoaderIndicator(),
    //               ),
    //             ),
    //           )
    //         : SizedBox()
    //   ],
    // );
  }
}
