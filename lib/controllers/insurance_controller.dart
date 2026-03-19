import 'package:flutter/material.dart';
import 'package:genesis/models/insurance_model.dart';
import 'package:get/get.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/models/deducton_item.dart';
import 'package:genesis/services/network_adapter.dart';

class InsuranceController extends GetxController {
  RxBool payingInsurances = false.obs;
  void payInsurances(String vehicleId, List<DeductionItem> insurances) async {
    if (payingInsurances.value) return;
    payingInsurances.value = true;
    final response = await Net.post(
      "/vehicle/insurance",
      data: {
        "insurances": insurances.map((e) => e.toJson()).toList(),
        "vehicleId": vehicleId,
      },
    );
    payingInsurances.value = false;
    if (response.hasError) {
      return Toaster.showError(response.response);
    }
    Get.back();
    return Toaster.showSuccess2(
      "Payment Succeed",
      "Payment for insurance for the vehicle has been proceed success",
    );
  }

  RxBool findingInsurances = false.obs;
  RxList<InsuranceModel> insuraceModel = RxList<InsuranceModel>();
  void fetchInsurances(String vehicleId, DateTimeRange range) async {
    if (findingInsurances.value) return;
    findingInsurances.value = true;
    final response = await Net.get(
      "/vehicle/insurance?startDate=${range.start.toIso8601String()}&endDate=${range.end.toIso8601String()}&vehicleId=$vehicleId",
    );
    findingInsurances.value = false;
    if (response.hasError) {
      return Toaster.showError(response.response);
    }
    insuraceModel.value =
        (response.body as List<dynamic>?)
            ?.map((e) => InsuranceModel.fromJSON(e))
            .toList() ??
        [];
  }
}
