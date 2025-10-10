import 'package:bloc/bloc.dart';

class RouteCubit extends Cubit<int> {
  RouteCubit() : super(0);

  void changeScreen(int index) {
    emit(index);
  }
}