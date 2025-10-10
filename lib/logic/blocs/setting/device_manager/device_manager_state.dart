import '../../../../data/models/device_manager/deevice_manager_model.dart';

abstract class DeviceState {}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<DeviceModel> devices;
  DeviceLoaded(this.devices);
}

class DeviceError extends DeviceState {
  final String error;
  DeviceError(this.error);
}
