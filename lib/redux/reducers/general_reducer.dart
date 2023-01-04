import 'package:redux/redux.dart';
import 'package:tomas_driver/redux/actions/general_action.dart';
import 'package:tomas_driver/redux/modules/general_state.dart';

final generalReducer = combineReducers<GeneralState>([
  TypedReducer<GeneralState, dynamic>(_setGeneralState),
]);

GeneralState _setGeneralState(GeneralState state, dynamic action) {
  if (action is SetDisableNavbar) {
    return state.copyWith(disableNavbar: action.disableNavbar);
  }else if (action is SetSelectedNotification) {
    return state.copyWith(selectedNotification: action.selectedNotification);
  } else if (action is SetNotifications) {
    return state.copyWith(
        notifications: action.notifications, limitNotif: action.limitNotif);
  }else if (action is SetIsLoading) {
    return state.copyWith(isLoading: action.isLoading);
  }
  return state;
}
