import 'package:image_picker/image_picker.dart' show XFile;

abstract class ProfileEvent {}

class UpdateFirstName extends ProfileEvent {
  final String firstName;
  UpdateFirstName({required this.firstName});
}

class UpdateLastName extends ProfileEvent {
  final String lastName;
  UpdateLastName({required this.lastName});
}

class UpdateProfileImage extends ProfileEvent {
  final XFile? profileImage;
  UpdateProfileImage({this.profileImage});
}

class Logout extends ProfileEvent {}