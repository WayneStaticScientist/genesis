import 'dart:developer';

import 'package:genesis/controllers/socket_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/scheduler.dart';
import 'package:genesis/utils/toast.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:genesis/models/trip_model.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/tokens_model.dart';
import 'package:genesis/services/interceptor.dart';
import 'package:genesis/utils/database_carrier.dart';
import 'package:genesis/services/network_adapter.dart';
import 'package:genesis/screens/auth/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:genesis/controllers/messaging_controller.dart';

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
    validateUser();
    return true;
  }

  Future<bool> registerUser(dynamic user, String company) async {
    if (loading.value) {
      Toaster.showError("loading please wait");
      return false;
    }
    loading.value = true;
    final response = await Net.post(
      "/user/register",
      data: {"user": user, "company": company},
    );
    loading.value = false;
    if (response.hasError) {
      log(response.response);
      Toaster.showError(response.response);
      return false;
    }
    final dataUser = User.fromJSON(response.body['user']);
    final tokens = TokenModel.fromJSON(response.body['tokens']);
    this.user.value = dataUser;
    dataUser.saveUser();
    tokens.saveToStorage();
    await validateUser();
    return true;
  }

  Future<void> validateUser() async {
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
      final socket = Get.find<SocketController>();
      socket.listenToUserSocket();
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      if (token != null && token != user.value!.chatToken) {
        await Net.put("/user/update-chat-token", data: {"chatToken": token});
      }
      final messgaeController = Get.find<MessagingController>();
      messgaeController.initializeMessaging();
    }
  }

  Rx<bool> registeringDriver = RxBool(false);
  Future<bool> registerDriver(dynamic user, dynamic licence) async {
    if (registeringDriver.value) {
      Toaster.showError("loading please wait");
      return false;
    }
    registeringDriver.value = true;
    final response = await Net.post(
      "/driver/register",
      data: {"user": user, "licence": licence},
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
      "/drivers?page=${page}&limit=${limit}&search=${search}",
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
    bool updateCurrent = false,
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

  Future<bool> updateMyStatus({
    required Map<String, dynamic> data,
    required String id,
    bool updateCurrent = false,
  }) async {
    if (registeringDriver.value) {
      Toaster.showError("loading please wait");
      return false;
    }
    registeringDriver.value = true;
    final response = await Net.put("/user/$id", data: data);
    registeringDriver.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    user.value = User.fromJSON(response.body['user']);
    user.value?.saveUser();
    return true;
  }

  Future<User?> getArgumentedUser(String id) async {
    final isar = IsarStatic.isar;
    if (isar == null) return null;
    final localUser = isar.users.where().idEqualTo(id).findFirst();
    if (localUser != null) {
      return localUser;
    }
    return fetchUser(id);
  }

  Future<User?> fetchUser(String id) async {
    final response = await Net.get("/user/$id");
    if (response.hasError) {
      Toaster.showError(response.response);
      return null;
    }
    return User.fromJSON(response.body);
  }

  Future updateUser({
    required String firstName,
    required String lastName,
    String? password,
  }) async {}

  void logout() {
    user.value = null;
    User.clearStorage();
  }

  RxBool processingTrip = RxBool(false);
  Future<bool> startTrip({required Map<String, dynamic> data}) async {
    if (processingTrip.value) {
      Toaster.showError("loading please wait");
      return false;
    }
    processingTrip.value = true;
    final response = await Net.post("/trip", data: data);
    processingTrip.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    return true;
  }

  Future<bool> confirmStartTrip() async {
    if (processingTrip.value) {
      Toaster.showError("loading please wait");
      return false;
    }
    processingTrip.value = true;
    final response = await Net.put("/trip-confirm");
    processingTrip.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    final user = await fetchUser(this.user.value?.id ?? '');
    if (user != null) {
      this.user.value = user;
      this.user.value?.saveUser();
      this.user.refresh();
    }
    return true;
  }

  Future<bool> endTrip({required Map<String, dynamic> data}) async {
    if (processingTrip.value) {
      Toaster.showError("loading please wait");
      return false;
    }
    processingTrip.value = true;
    final response = await Net.put("/trip", data: data);
    processingTrip.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    final user = await fetchUser(this.user.value?.id ?? '');
    if (user != null) {
      this.user.value = user;
      this.user.value?.saveUser();
      this.user.refresh();
    }
    return true;
  }

  Future<bool> finalizeTrip({
    required String tripId,
    required String tripAction,
  }) async {
    if (processingTrip.value) {
      Toaster.showError("loading please wait");
      return false;
    }
    processingTrip.value = true;
    final response = await Net.delete(
      "/trip",
      data: {"tripId": tripId, "tripAction": tripAction},
    );
    processingTrip.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    fetchDrivers();
    await findTrip(tripId);
    return true;
  }

  RxBool fetchingTrip = RxBool(false);
  Rx<TripModel?> trip = Rx(null);
  Future<void> findTrip(String id) async {
    fetchingTrip.value = true;
    final response = await Net.get("/trip/$id");
    fetchingTrip.value = false;
    if (response.hasError) {
      log("The error is ${response.response}");
      return Future.value();
    }
    trip.value = TripModel.fromJson(response.body);
    return Future.value();
  }

  RxBool findingChats = RxBool(false);
  RxList<User> foundChats = RxList([]);
  Future<void> findChats({
    int page = 1,
    int limit = 20,
    String query = '',
  }) async {
    findingChats.value = true;
    final response = await Net.get(
      "/chats/users?search=$query&page=$page&limit=$limit",
    );
    findingChats.value = false;
    if (response.hasError) {
      return Future.value();
    }
    foundChats.clear();
    foundChats.addAll(
      (response.body['list'] as List<dynamic>?)
              ?.map((e) => User.fromJSON(e))
              .toList() ??
          [],
    );
    return Future.value();
  }

  Rx<bool> registeringEmployee = RxBool(false);
  Future<bool> registerEmployee(dynamic user) async {
    if (registeringEmployee.value) {
      Toaster.showError("loading please wait");
      return false;
    }
    registeringEmployee.value = true;
    final response = await Net.post("/employee/register", data: {"user": user});
    registeringEmployee.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    return true;
  }

  Future<bool> updateEmployee(dynamic user, String userId) async {
    if (registeringEmployee.value) {
      Toaster.showError("loading please wait");
      return false;
    }
    registeringEmployee.value = true;
    final response = await Net.put("/employee/$userId", data: {"user": user});
    registeringEmployee.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    return true;
  }
}
