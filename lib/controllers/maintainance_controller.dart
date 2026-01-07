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
      "/maintainances?page=${page}&limit=${limit}&$search=${search}",
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
    final response = await Net.put("/maintainance/$id", data: data);
    addingMaintainance.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    fetchAllMaintainances();
    return true;
  }
}
