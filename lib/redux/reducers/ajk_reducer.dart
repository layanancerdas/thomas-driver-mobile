import 'package:redux/redux.dart';
import 'package:tomas_driver/redux/actions/ajk_action.dart';
import 'package:tomas_driver/redux/modules/ajk_state.dart';

final ajkReducer = combineReducers<AjkState>([
  TypedReducer<AjkState, dynamic>(_setAjkState),
]);

AjkState _setAjkState(AjkState state, dynamic action) {
  if (action is SetMyTrip) {
    return state.copyWith(myTrip: action.myTrip);
  } else if (action is SetSelectedMyTrip) {
    return state.copyWith(selectedMyTrip: action.selectedMyTrip);
  } else if (action is SetAssignedTrip) {
    return state.copyWith(assignedTrip: action.assignedTrip);
  } else if (action is SetOngoingTrip) {
    return state.copyWith(ongoingTrip: action.ongoingTrip);
  } else if (action is SetCompletedTrip) {
    return state.copyWith(completedTrip: action.completedTrip);
  } else if (action is SetSelectedPassanger) {
    return state.copyWith(selectedPassanger: action.selectedPassanger);
  } else if (action is SetResolveDate) {
    return state.copyWith(resolveDate: action.resolveDate);
  } else if (action is SetStatusSelectedTrip) {
    return state.copyWith(statusSelectedTrip: action.statusSelectedTrip);
  } else if (action is SetButtonSelectedTrip) {
    return state.copyWith(buttonSelectedTrip: action.buttonSelectedTrip);
  } else if (action is SetLastHistoryTransation) {
    return state.copyWith(
        lastHistorySelectedTrip: action.lastHistorySelectedTrip);
  }
  return state;
}
