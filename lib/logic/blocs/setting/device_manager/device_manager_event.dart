import 'package:payfussion/data/models/device_manager/deevice_manager_model.dart';

abstract class DeviceEvent {}

class FetchDevices extends DeviceEvent {}

class AddOrUpdateDevice extends DeviceEvent {
  final DeviceModel device;
  AddOrUpdateDevice(this.device);
}

class MarkDeviceInactive extends DeviceEvent {}
