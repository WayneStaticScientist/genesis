import 'package:genesis/models/company_model.dart';
import 'package:genesis/services/network_adapter.dart';
import 'package:genesis/utils/toast.dart';
import 'package:get/get.dart';

class CompanyController extends GetxController {
  Rx<CompanyModel?> company = Rx<CompanyModel?>(null);
  @override
  void onInit() {
    super.onInit();
    company.value = CompanyModel.fromStorage();
  }

  Future<void> fetchCompany() async {
    final res = await Net.get("/company");
    if (res.hasError) {
      return;
    }
    company.value = CompanyModel.fromJson(res.body);
    company.value!.saveToStorage();
    return;
  }

  RxBool updatingCompanySettings = RxBool(false);
  Future<void> updateCompanySettings(Map<String, dynamic> data) async {
    if (updatingCompanySettings.value) return;
    updatingCompanySettings.value = true;
    final res = await Net.put("/company/settings", data: data);
    updatingCompanySettings.value = false;
    if (res.hasError) {
      Toaster.showErrorTop("Company Error", '${res.response}');
      return;
    }
    company.value = CompanyModel.fromJson(res.body);
    company.value!.saveToStorage();
    return;
  }
}
