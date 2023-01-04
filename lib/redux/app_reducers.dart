import 'package:tomas_driver/redux/reducers/general_reducer.dart';
import 'package:tomas_driver/redux/reducers/ajk_reducer.dart';

import 'app_state.dart';
import 'reducers/user_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    ajkState: ajkReducer(state.ajkState, action),
    userState: userReducer(state.userState, action),
    generalState: generalReducer(state.generalState, action),
  );
}
