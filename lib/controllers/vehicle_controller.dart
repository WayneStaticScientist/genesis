import 'dart:developer';

import 'package:genesis/models/vehicle_model.dart';
import 'package:genesis/services/network_adapter.dart';
import 'package:genesis/utils/toast.dart';
import 'package:get/get.dart';

class VehicleControler extends GetxController {
  RxBool registeringVehicle = RxBool(false);
  Future<bool> registerVehicle(dynamic data) async {
    if (registeringVehicle.value) return false;
    registeringVehicle.value = true;
    final response = await Net.post("/vehicle/register", data: data);
    registeringVehicle.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    fetchAllVehicles();
    return true;
  }

  RxInt page = RxInt(1);
  RxInt totalPages = RxInt(0);
  RxBool loadingVehicles = RxBool(false);
  RxList<VehicleModel> vehicles = RxList([]);
  RxString vehicleFetchingStatus = RxString("");
  Future<void> fetchAllVehicles({
    int page = 1,
    int limit = 20,
    String search = '',
    String driverId = '',
  }) async {
    if (loadingVehicles.value) {
      Toaster.showError("loading please wait");
      return;
    }
    if (page == 1) {
      vehicles.clear();
    }
    vehicleFetchingStatus.value = "";
    loadingVehicles.value = true;
    final response = await Net.get(
      "/vehicles?page=${page}&limit=${limit}&search=${search}&driver=$driverId",
    );
    loadingVehicles.value = false;
    if (response.hasError) {
      vehicleFetchingStatus.value = response.response;
      return;
    }
    totalPages.value = response.body['totalPages'];
    this.page.value = response.body['page'] as int;
    log("Total Pages: ${totalPages.value} | Current Page: ${this.page.value}");

    vehicles.addAll(
      (response.body['list'] as List<dynamic>?)
              ?.map((e) => VehicleModel.fromJSON(e))
              .toList() ??
          [],
    );
    this.page.value = page;
    return;
  }

  Future<bool> updateVehicle(dynamic data, String id) async {
    if (registeringVehicle.value) return false;
    registeringVehicle.value = true;
    final response = await Net.put("/vehicle/$id", data: data);
    registeringVehicle.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    fetchAllVehicles();
    return true;
  }

  Future<VehicleModel?> updateFuelLevel(double level) async {
    final response = await Net.post("/driver/fuel", data: {"level": level});
    if (response.hasError) {
      Toaster.showError(response.response);
      return null;
    }
    Toaster.showSuccess("fuel updated");
    return VehicleModel.fromJSON(response.body);
  }

  Future<VehicleModel?> refuelVehicle({
    required double level,
    required double cost,
  }) async {
    final response = await Net.post(
      "/driver/refuel",
      data: {"level": level, "cost": cost},
    );
    if (response.hasError) {
      Toaster.showError(response.response);
      return null;
    }
    Toaster.showSuccess("fuel updated");
    return VehicleModel.fromJSON(response.body);
  }
}
