import 'package:flutter/material.dart';
import 'package:genesis/models/payroll_details.dart';
import 'package:get/get.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/models/deducton_item.dart';
import 'package:genesis/services/network_adapter.dart';

class PayrollController extends GetxController {
  RxDouble grossTotal = 0.0.obs;
  RxBool findingEmployees = RxBool(false);
  RxList<User> employees = RxList([]);

  Future<void> findEmployees({
    int page = 1,
    int limit = 1000,
    String query = '',
  }) async {
    findingEmployees.value = true;
    grossTotal.value = 0;
    final response = await Net.get(
      "/chats/users?search=$query&page=$page&limit=$limit",
    );
    findingEmployees.value = false;
    if (response.hasError) {
      return Future.value();
    }
    employees.clear();
    employees.addAll(
      (response.body['list'] as List<dynamic>?)?.map((e) {
            var user = User.fromJSON(e);
            user.finalPayment = NumberUtils.calculatePriceFold(
              user,
              [],
              user.insurance,
            );
            grossTotal.value += user.payment;
            return user;
          }).toList() ??
          [],
    );
    fetchLastPayroll();
    return Future.value();
  }

  RxBool updatingUserPayroll = false.obs;
  Future<bool> updateUserPayroll(
    double newAmount,
    List<DeductionItem> insurances,
    String userId,
  ) async {
    updatingUserPayroll.value = true;
    final response = await Net.put(
      "/payroll/user",
      data: {"amount": newAmount, "userId": userId, "insurances": insurances},
    );
    updatingUserPayroll.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    findEmployees();
    return true;
  }

  RxBool paymentProceeding = false.obs;
  void proceedPayment() async {
    if (paymentProceeding.value) {
      Toaster.showError("Payment queue is still on!Please wait");
      return;
    }
    paymentProceeding.value = true;
    final List<dynamic> payrolls = List.empty(growable: true);
    for (final em in employees) {
      if (em.payment <= 0) continue;
      final splitDeductions = NumberUtils.splitDeductions(em.insurance);
      final insuranceFees =
          splitDeductions.totalValue +
          (em.payment * (splitDeductions.totalPercent / 100));
      double amount = em.payment - insuranceFees;
      payrolls.add({
        "tax": 0,
        "userId": em.id,
        "payment": em.payment,
        "insurance": insuranceFees,
        "netPayment": amount,
      });
    }
    final response = await Net.post(
      "/payroll/payment",
      data: {"payrolls": payrolls, "grossTotal": grossTotal.value},
    );
    paymentProceeding.value = false;
    if (response.hasError) {
      return Toaster.showError(response.response);
    }
    Toaster.showSuccess2(
      "Payment Success",
      "payroll have been emitted for all events",
    );
  }

  Rx<PayrollDetails?> lastPayrollDetails = Rx<PayrollDetails?>(null);
  RxBool fetchingLastPayroll = false.obs;
  void fetchLastPayroll() async {
    if (fetchingLastPayroll.value) return;
    fetchingLastPayroll.value = true;
    final response = await Net.get("/payroll/last-payroll");
    fetchingLastPayroll.value = false;
    if (response.hasError) return;
    lastPayrollDetails.value = PayrollDetails.fromJSON(
      response.body['lastPayroll'],
    );
  }

  RxList<PayrollDetails> payrollHistory = RxList<PayrollDetails>();
  RxDouble totalGrossHistory = 0.0.obs;
  RxBool fetchingPayrollHistory = false.obs;
  void fetchPayRowHistory(DateTimeRange range) async {
    payrollHistory.clear();
    fetchingPayrollHistory.value = true;
    final response = await Net.get(
      "/payroll/range?startDate=${range.start.toIso8601String()}&endDate=${range.end.toIso8601String()}",
    );
    fetchingPayrollHistory.value = false;
    if (response.hasError) return;
    payrollHistory.value =
        (response.body['list'] as List<dynamic>?)
            ?.map((e) => PayrollDetails.fromJSON(e))
            .toList() ??
        [];
    totalGrossHistory.value = payrollHistory.fold(
      0.0,
      (prev, data) => prev + data.grossTotal,
    );
  }
}
