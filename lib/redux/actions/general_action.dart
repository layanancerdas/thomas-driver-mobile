class SetDisableNavbar {
  final bool disableNavbar;

  SetDisableNavbar({this.disableNavbar});
}

class SetNotifications {
  final List notifications;
  final int limitNotif;

  SetNotifications({this.notifications, this.limitNotif});
}

class SetSelectedNotification {
  final Map selectedNotification;

  SetSelectedNotification({this.selectedNotification});
}

class SetIsLoading {
  final bool isLoading;

  SetIsLoading({this.isLoading});
}