import 'package:redux/redux.dart';
import 'package:tomas_driver/redux/actions/user_action.dart';
import 'package:tomas_driver/redux/modules/user_state.dart';

final userReducer = combineReducers<UserState>([
  TypedReducer<UserState, dynamic>(_setUserState),
]);

UserState _setUserState(UserState state, dynamic action) {
  if (action is SetUserDetail) {
    return state.copyWith(userDetail: action.userDetail);
  }
  return state;
}
