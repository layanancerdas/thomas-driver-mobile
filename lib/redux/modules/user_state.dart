import 'package:meta/meta.dart';

@immutable
class UserState {
  UserState({
    this.userDetail
  });

  final Map userDetail;

  factory UserState.initial() {
    return UserState(
        userDetail: {});
  }

  UserState copyWith({
    Map userDetail
  }) {
    return UserState(
      userDetail: userDetail ?? this.userDetail,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserState &&
          runtimeType == other.runtimeType &&
          userDetail == other.userDetail;

  @override
  int get hashCode =>
      userDetail.hashCode;
}
