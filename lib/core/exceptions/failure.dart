abstract class Failure {
  final String message;
  Failure(this.message);
}

class AuthFailure extends Failure {
  AuthFailure(super.message);
}

class PlatformFailure extends Failure {
  PlatformFailure(super.message);
}

class FirebaseFailure extends Failure {
  FirebaseFailure(super.message);
}

class FormatFailure extends Failure {
  FormatFailure(super.message);
}
