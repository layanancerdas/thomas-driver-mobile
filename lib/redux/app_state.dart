import 'package:meta/meta.dart';
import 'package:tomas_driver/redux/modules/general_state.dart';
import 'package:tomas_driver/redux/modules/user_state.dart';
import 'package:tomas_driver/redux/modules/ajk_state.dart';

@immutable
class AppState {
  final AjkState ajkState;
  final UserState userState;
  final GeneralState generalState;

  AppState({this.ajkState, this.userState, this.generalState});

  factory AppState.initial() {
    return AppState(
      ajkState: AjkState.initial(),
      userState: UserState.initial(),
      generalState: GeneralState.initial(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          ajkState == other.ajkState &&
          userState == other.userState &&
          generalState == other.generalState;

  @override
  int get hashCode => userState.hashCode ^ generalState.hashCode;
}
