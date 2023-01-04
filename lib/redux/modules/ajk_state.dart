import 'package:meta/meta.dart';

@immutable
class AjkState {
  AjkState(
      {this.myTrip,
      this.selectedPassanger,
      this.selectedMyTrip,
      this.assignedTrip,
      this.ongoingTrip,
      this.completedTrip,
      this.statusSelectedTrip,
      this.buttonSelectedTrip,
      this.lastHistorySelectedTrip,
      this.resolveDate});

  final List myTrip,
      assignedTrip,
      ongoingTrip,
      completedTrip,
      selectedPassanger;
  final Map selectedMyTrip, resolveDate, lastHistorySelectedTrip;
  final String statusSelectedTrip, buttonSelectedTrip;

  factory AjkState.initial() {
    return AjkState(
        myTrip: [],
        selectedPassanger: [],
        selectedMyTrip: {},
        assignedTrip: [],
        ongoingTrip: [],
        completedTrip: [],
        resolveDate: {},
        lastHistorySelectedTrip: {},
        statusSelectedTrip: "",
        buttonSelectedTrip: "");
  }

  AjkState copyWith(
      {List myTrip,
      List selectedPassanger,
      List assignedTrip,
      List ongoingTrip,
      List completedTrip,
      Map selectedMyTrip,
      Map resolveDate,
      Map lastHistorySelectedTrip,
      String statusSelectedTrip,
      String buttonSelectedTrip}) {
    return AjkState(
        selectedMyTrip: selectedMyTrip ?? this.selectedMyTrip,
        myTrip: myTrip ?? this.myTrip,
        selectedPassanger: selectedPassanger ?? this.selectedPassanger,
        assignedTrip: assignedTrip ?? this.assignedTrip,
        ongoingTrip: ongoingTrip ?? this.ongoingTrip,
        completedTrip: completedTrip ?? this.completedTrip,
        resolveDate: resolveDate ?? this.resolveDate,
        lastHistorySelectedTrip:
            lastHistorySelectedTrip ?? this.lastHistorySelectedTrip,
        statusSelectedTrip: statusSelectedTrip ?? this.statusSelectedTrip,
        buttonSelectedTrip: buttonSelectedTrip ?? this.buttonSelectedTrip);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AjkState &&
          runtimeType == other.runtimeType &&
          selectedMyTrip == other.selectedMyTrip &&
          assignedTrip == other.assignedTrip &&
          ongoingTrip == other.ongoingTrip &&
          completedTrip == other.completedTrip &&
          selectedPassanger == other.selectedPassanger &&
          myTrip == other.myTrip &&
          resolveDate == other.resolveDate &&
          lastHistorySelectedTrip == other.lastHistorySelectedTrip &&
          statusSelectedTrip == other.statusSelectedTrip &&
          buttonSelectedTrip == other.buttonSelectedTrip;

  @override
  int get hashCode =>
      selectedMyTrip.hashCode ^
      assignedTrip.hashCode ^
      ongoingTrip.hashCode ^
      completedTrip.hashCode ^
      selectedPassanger.hashCode ^
      myTrip.hashCode ^
      resolveDate.hashCode ^
      lastHistorySelectedTrip.hashCode ^
      statusSelectedTrip.hashCode ^
      buttonSelectedTrip.hashCode;
}
