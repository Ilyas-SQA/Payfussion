import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc() : super(RouteInitial()) {
    on<RouteEvent>((RouteEvent event, Emitter<RouteState> emit) {
      // Add event handling logic here
    });
  }
}