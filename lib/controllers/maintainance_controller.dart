import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/models/maintainance_model.dart';
import 'package:genesis/services/network_adapter.dart';

class MaintainanceController extends GetxController {
  RxBool addingMaintainance = RxBool(false);
  Future<bool> addMantainance(dynamic data) async {
    if (addingMaintainance.value) return false;
    addingMaintainance.value = true;
    final response = await Net.post("/maintainance/new", data: data);
    addingMaintainance.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    fetchAllMaintainances();
    return true;
  }

  RxInt page = RxInt(1);
  RxInt totalPages = RxInt(0);
  RxBool loadingMaintainances = RxBool(false);
  RxList<MaintainanceModel> maintainances = RxList([]);
  RxString mantainanceFetchingStatus = RxString("");
  Future<void> fetchAllMaintainances({
    int page = 1,
    int limit = 20,
    String search = '',
    String status = '',
  }) async {
    if (loadingMaintainances.value) {
      Toaster.showError("loading please wait");
      return;
    }
    if (page == 1) {
      maintainances.clear();
    }
    mantainanceFetchingStatus.value = "";
    loadingMaintainances.value = true;
    final response = await Net.get(
      "/maintainances?page=${page}&limit=${limit}&$search=${search}&status=$status",
    );
    loadingMaintainances.value = false;
    if (response.hasError) {
      mantainanceFetchingStatus.value = response.response;
      return;
    }
    totalPages.value = response.body['totalPages'];
    maintainances.addAll(
      (response.body['list'] as List<dynamic>?)
              ?.map((e) => MaintainanceModel.fromJSON(e))
              .toList() ??
          [],
    );
    this.page.value = page;
    return;
  }

  Future<bool> updateMantainance(dynamic data, String id) async {
    if (addingMaintainance.value) return false;
    addingMaintainance.value = true;
    final response = await Net.put("/maintainance/structure/$id", data: data);
    addingMaintainance.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    fetchAllMaintainances();
    return true;
  }

  RxBool updatingMaintainance = RxBool(false);
  Future<bool> markAsCompleted(String id) async {
    if (updatingMaintainance.value) return false;
    updatingMaintainance.value = true;
    final response = await Net.put("/maintainance/status/$id");
    updatingMaintainance.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    maintainance.value = MaintainanceModel.fromJSON(
      response.body['maintainance'],
    );
    fetchAllMaintainances();
    return true;
  }

  RxBool gettingMaintainance = RxBool(false);
  Rx<MaintainanceModel?> maintainance = Rx<MaintainanceModel?>(null);
  Future<bool> getMantainance(String id) async {
    if (gettingMaintainance.value) return false;
    final response = await Net.get("/maintainance/$id");
    gettingMaintainance.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    maintainance.value = MaintainanceModel.fromJSON(response.body);
    return true;
  }

  void updateMaintainanceStatus({
    required String id,
    required bool accepted,
  }) async {
    if (updatingMaintainance.value) return;
    updatingMaintainance.value = true;
    final response = await Net.put(
      "/maintainance/complete/$id",
      data: {"accepted": accepted},
    );
    updatingMaintainance.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return;
    }
    getMantainance(id);
    Toaster.showSuccess2(
      "Mantainance Alert",
      "Maintainance has been succefully ${accepted ? "accepted" : "rejected"}",
    );
  }

  RxBool findingMaintainancesForVehicle = false.obs;
  RxList<MaintainanceModel> maintainancesForVehicle =
      RxList<MaintainanceModel>();
  void findMaintainanceForVehicle(
    String vehicleId,
    DateTimeRange dateRange,
  ) async {
    if (findingMaintainancesForVehicle.value) return;
    findingMaintainancesForVehicle.value = true;
    final response = await Net.get(
      "/maintainances/vehicle/$vehicleId?start=${dateRange.start.toIso8601String()}&end=${dateRange.end.toIso8601String()}",
    );
    findingMaintainancesForVehicle.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return;
    }
    maintainancesForVehicle.clear();
    maintainancesForVehicle.addAll(
      (response.body as List<dynamic>?)
              ?.map((e) => MaintainanceModel.fromJSON(e))
              .toList() ??
          [],
    );
    return;
  }
}
