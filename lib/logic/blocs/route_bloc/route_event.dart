part of 'route_bloc.dart';

@immutable
sealed class RouteEvent {}

final class InitializeRoute extends RouteEvent {}