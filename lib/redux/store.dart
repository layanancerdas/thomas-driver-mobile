import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';

import 'app_reducers.dart';
import 'app_state.dart';

Future<Store<AppState>> createStore() async {
  return Store(appReducer,
      initialState: AppState.initial(),
      distinct: true,
      middleware: [LoggingMiddleware.printer()]);
}
