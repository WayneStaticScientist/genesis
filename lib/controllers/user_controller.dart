import 'package:get/get.dart';
import 'package:flutter/scheduler.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/tokens_model.dart';
import 'package:genesis/services/interceptor.dart';
import 'package:genesis/services/network_adapter.dart';
import 'package:genesis/screens/auth/login_screen.dart';

class UserController extends GetxController {
  Rx<User?> user = Rx(null);
  RxBool loading = RxBool(false);
  @override
  void onInit() {
    super.onInit();
    user.value = User.fromStorage();
    validateUser();
  }

  Future<bool> loginUser(email, password) async {
    if (loading.value) {
      Toaster.showError("loading please wait");
      return false;
    }
    loading.value = true;
    final response = await Net.post(
      "/user/login",
      data: {"email": email, "password": password},
    );
    loading.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    final dataUser = User.fromJSON(response.body['user']);
    final tokens = TokenModel.fromJSON(response.body['tokens']);
    user.value = dataUser;
    dataUser.saveUser();
    tokens.saveToStorage();
    return true;
  }

  Future<bool> registerUser(User user, String company) async {
    if (loading.value) {
      Toaster.showError("loading please wait");
      return false;
    }
    loading.value = true;
    final response = await Net.post(
      "/user/register",
      data: {"user": user.toJSON(), "company": company},
    );
    loading.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    final dataUser = User.fromJSON(response.body['user']);
    final tokens = TokenModel.fromJSON(response.body['tokens']);
    this.user.value = dataUser;
    dataUser.saveUser();
    tokens.saveToStorage();
    return true;
  }

  void validateUser() async {
    if (user.value == null) return;
    loading.value = true;
    final response = await AuthenticationInterceptor.requestToken();
    loading.value = false;
    if (response.statusCode == 401) {
      user.value = null;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => LoginScreen());
      });
      Toaster.showError(
        "There was error in authorization please login again to continue",
      );
    }
    if (!response.hasError) {
      user.value = User.fromJSON(response.body['user']);
      user.value!.saveUser();
    }
  }

  Rx<bool> registeringDriver = RxBool(false);
  Future<bool> registerDriver(User user) async {
    if (registeringDriver.value) {
      Toaster.showError("loading please wait");
      return false;
    }
    registeringDriver.value = true;
    final response = await Net.post(
      "/driver/register",
      data: {"user": user.toJSON()},
    );
    registeringDriver.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    fetchDrivers(page: 1);
    return true;
  }

  RxList<User> drivers = RxList([]);
  RxInt driverTotalPages = RxInt(0);
  RxInt driverPage = RxInt(1);
  Rx<bool> loadingDrivers = RxBool(false);
  RxString driversResponse = RxString('');
  Future<void> fetchDrivers({
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    if (loadingDrivers.value) {
      Toaster.showError("loading please wait");
      return;
    }
    if (page == 1) {
      drivers.clear();
    }
    driversResponse.value = "";
    loadingDrivers.value = true;
    final response = await Net.get(
      "/drivers?page=${page}&limit=${limit}&$search=${search}",
    );
    loadingDrivers.value = false;
    if (response.hasError) {
      driversResponse.value = response.response;
      return;
    }
    driverTotalPages.value = response.body['totalPages'] as int;
    driverPage.value = response.body['page'] as int;
    drivers.addAll(
      (response.body['list'] as List<dynamic>?)
              ?.map((e) => User.fromJSON(e))
              .toList() ??
          [],
    );
    this.driverPage.value = page;
    return;
  }

  Future<bool> updateDriver({
    required Map<String, dynamic> data,
    required String id,
  }) async {
    if (registeringDriver.value) {
      Toaster.showError("loading please wait");
      return false;
    }
    registeringDriver.value = true;
    final response = await Net.put("/driver/$id", data: data);
    registeringDriver.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    fetchDrivers(page: 1);
    return true;
  }

  Future<User?> fetchUser(String id) async {
    final response = await Net.get("/user/$id");
    if (response.hasError) {
      Toaster.showError(response.response);
      return null;
    }
    return User.fromJSON(response.body);
  }
}
