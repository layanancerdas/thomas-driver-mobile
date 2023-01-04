import 'package:meta/meta.dart';

@immutable
class GeneralState {
  GeneralState({
    this.disableNavbar,
    this.selectedNotification,
    this.notifications,
    this.limitNotif,
    this.isLoading
  });

  final bool disableNavbar, isLoading;
  final Map selectedNotification;
  final List notifications;
  final int limitNotif;

  factory GeneralState.initial() {
    return GeneralState(
      disableNavbar: false,
      isLoading: false,
      limitNotif: 10,
      notifications: [],
      selectedNotification: {}
    );
  }

  GeneralState copyWith({
    bool disableNavbar,
    Map selectedNotification,
    List notifications,
    int limitNotif,
    bool isLoading,
  }) {
    return GeneralState(
      disableNavbar: disableNavbar ?? this.disableNavbar,
      limitNotif: limitNotif ?? this.limitNotif,
      selectedNotification: selectedNotification ?? this.selectedNotification,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneralState &&
          runtimeType == other.runtimeType &&
          disableNavbar == other.disableNavbar &&
          isLoading == other.isLoading &&
          limitNotif == other.limitNotif &&
          notifications == other.notifications &&
          selectedNotification == other.selectedNotification;

  @override
  int get hashCode => disableNavbar.hashCode;
}
