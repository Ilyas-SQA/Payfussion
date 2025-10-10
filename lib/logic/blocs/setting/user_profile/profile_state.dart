// Abstract base class
abstract class ProfileState {}

// Initial state when no action has been taken
class ProfileInitial extends ProfileState {}

// Loading state for actions like updating the profile or changing the name
class ProfileLoading extends ProfileState {}

// Success states for actions
class ProfileSucess extends ProfileState {}

class ProfileFailure extends ProfileState {
  final String message;
  ProfileFailure(this.message);
}

class LogoutSuccess extends ProfileState {}
