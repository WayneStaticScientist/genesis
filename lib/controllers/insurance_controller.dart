import 'package:get/get.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/models/deducton_item.dart';
import 'package:genesis/services/network_adapter.dart';

class InsuranceController extends GetxController {
  RxBool payingInsurances = false.obs;
  void payInsurances(String vehicleId, List<DeductionItem> insurances) async {
    if (payingInsurances.value) return;
    final response = await Net.post(
      "/vehicle/insurance",
      data: {
        "insurances": insurances.map((e) => e.toJson()).toList(),
        "vehicleId": vehicleId,
      },
    );
    if (response.hasError) {
      return Toaster.showError(response.response);
    }
    Get.back();
    return Toaster.showSuccess2(
      "Payment Succeed",
      "Payment for insurance for the vehicle has been proceed success",
    );
  }
}
