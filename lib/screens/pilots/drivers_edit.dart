import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:exui/material.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/licence_model.dart';
import 'package:genesis/models/passport_model.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';

class AdminEditDriver extends StatefulWidget {
  final User driver;
  const AdminEditDriver({super.key, required this.driver});

  @override
  State<AdminEditDriver> createState() => _AdminEditDriverState();
}

class _AdminEditDriverState extends State<AdminEditDriver> {
  final _formKey = GlobalKey<FormState>();
  final _userController = Get.find<UserController>();
  // Form State initialized with current driver data
  late TextEditingController _name = TextEditingController(
    text: widget.driver.firstName + ' ' + widget.driver.lastName,
  );
  late String _status = widget.driver.status ?? 'Offline';
  late TextEditingController _safety = TextEditingController(
    text: widget.driver.safety.toString(),
  );
  late TextEditingController _rating = TextEditingController(
    text: widget.driver.rating.toString(),
  );
  late TextEditingController _experience = TextEditingController(
    text: widget.driver.experience,
  );
  late DateTime? expiryDate = widget.driver.licence?.expiryDate;
  late TextEditingController _licenceNumber = TextEditingController(
    text: widget.driver.licence?.licenceNumber ?? '',
  );
  late TextEditingController _licenceClass = TextEditingController(
    text: widget.driver.licence?.licenceClass.toString() ?? '',
  );
  late TextEditingController _expiryDate = TextEditingController(
    text: GenesisDate.formatNormalDateN(widget.driver.licence?.expiryDate),
  );

  late TextEditingController _passportNumber = TextEditingController(
    text: widget.driver.passport?.passportNumber ?? '',
  );
  late TextEditingController _issuingCountry = TextEditingController(
    text: widget.driver.passport?.issuingCountry ?? '',
  );
  late DateTime? passportExpiryDate = widget.driver.passport?.expiryDate;
  late TextEditingController _passportExpiryDateStr = TextEditingController(
    text: GenesisDate.formatNormalDateN(widget.driver.passport?.expiryDate),
  );

  @override
  void initState() {
    super.initState();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final filteredName = _name.text.replaceAll(RegExp('\\s{2,}'), ' ');
      final firstName = filteredName.trim().split(" ")[0];
      final lastName = filteredName.trim().split(" ")[1];

      int? licenceClass = int.tryParse(_licenceClass.text);
      if (licenceClass == null && expiryDate != null) {
        Toaster.showError("Invalide licence class Number , Valid are 1-5");
      }
      String licenceNumber = _licenceNumber.text.trim().toLowerCase();
      if (licenceNumber.isEmpty && expiryDate != null) {
        return Toaster.showError(
          "Invalid licence number , it should not be empty",
        );
      }
      final updatedDriver = {
        "firstName": firstName,
        "lastName": lastName,
        "status": _status,
        "experience": _experience.text,
        "rating": double.tryParse(_rating.text) ?? 0,
        "safety": _safety.text,
        "licence": expiryDate != null
            ? LicenceModel(
                expiryDate: expiryDate!,
                licenceClass: licenceClass!,
                licenceNumber: licenceNumber,
              ).toJson()
            : null,
        "passport": _passportNumber.text.isNotEmpty
            ? PassportModel(
                passportNumber: _passportNumber.text.trim(),
                issuingCountry: _issuingCountry.text.trim(),
                expiryDate: passportExpiryDate ?? DateTime.now(),
              ).toJson()
            : null,
      };
      final result = await _userController.updateDriver(
        data: updatedDriver,
        id: widget.driver.id,
      );
      if (result) {
        Toaster.showSuccess("driver updated succesfully");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTheme.color(context),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: "Edit Pilot".text(
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Obx(
                () => _userController.registeringDriver.value
                    ? WhiteLoader()
                    : "Update".text(
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Avatar Profile
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(70),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: Center(
                        child: widget.driver.firstName[0].toString().text(
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    "ID: PRT-${widget.driver.trips ?? 0}".text(
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _sectionHeader("Personal Details"),
              _buildField(
                label: "Full Name",
                hint: "Driver Name",
                controller: _name,
                icon: Icons.person_outline_rounded,
                validator: (String? input) {
                  if (input == null) return "This field should not be empty";
                  String filteredName = input.replaceAll(
                    RegExp('\\s{2,}'),
                    ' ',
                  );
                  if (filteredName.trim().split(" ").length < 2)
                    return "please enter full name e.g like John Doe";
                  return null;
                },
              ),
              _buildField(
                label: "Years of Experience",
                hint: "e.g. 5 Years",
                controller: _experience,
                icon: Icons.history_edu_rounded,
              ),

              const SizedBox(height: 24),
              _sectionHeader("Performance Metrics"),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      label: "Rating",
                      initialValue: _rating.toString(),
                      hint: "0.0",
                      icon: Icons.star_outline_rounded,
                      keyboardType: TextInputType.number,
                      controller: _rating,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      label: "Safety Score %",
                      initialValue: _safety.toString(),
                      hint: "100",
                      icon: Icons.security_rounded,
                      keyboardType: TextInputType.number,
                      controller: _safety,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _buildDropdown(
                label: "Duty Status",
                value: _status,
                items: ["On Trip", "Available", "Offline"],
                onChanged: (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: 24),
              _sectionHeader("Licence Information"),
              _buildField(
                label: "Licence Number",
                hint: "16digit number",
                controller: _licenceNumber,
                icon: Icons.shield,
              ),
              _buildField(
                label: "Licence Class",
                hint: "1-5",
                controller: _licenceClass,
                icon: Icons.numbers,
              ),
              _buildField(
                label: "Expiry Date",
                hint: "Tap to select",
                editable: false,
                controller: _expiryDate,
                icon: Icons.calendar_month,
                ontap: () => selectDate(context),
              ),
              if (expiryDate != null) ...[
                "Revoke Licence"
                    .text()
                    .elevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(side: BorderSide.none),
                      ),
                      onPressed: () {
                        setState(() {
                          expiryDate = null;
                          _licenceClass.text = '';
                          _licenceNumber.text = '';
                          _expiryDate.text = '';
                        });
                      },
                    )
                    .sizedBox(width: double.infinity),
              ],
              const SizedBox(height: 24),
              _sectionHeader("Passport Details"),
              _buildField(
                label: "Passport Number",
                hint: "Enter passport number",
                controller: _passportNumber,
                icon: Icons.badge_outlined,
              ),
              _buildField(
                label: "Issuing Country",
                hint: "e.g. Zimbabwe",
                controller: _issuingCountry,
                icon: Icons.flag_outlined,
              ),
              _buildField(
                label: "Passport Expiry Date",
                hint: "Tap to select",
                editable: false,
                controller: _passportExpiryDateStr,
                icon: Icons.calendar_today_outlined,
                ontap: () => selectPassportDate(context),
              ),
              const SizedBox(height: 40),
              // Retention Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withAlpha(25)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          "Changes to safety scores affect the driver's monthly insurance premium tier."
                              .text(
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: title.text(
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: GTheme.reverse(context).withAlpha(128),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    bool editable = true,
    String? initialValue,
    TextInputType? keyboardType,
    TextEditingController? controller,
    FormFieldValidator<String>? validator,
    VoidCallback? ontap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GTheme.reverse(context).withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        onTap: () => ontap?.call(),
        readOnly: !editable,
        keyboardType: keyboardType,
        style: TextStyle(color: GTheme.reverse(context)),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          labelStyle: const TextStyle(fontSize: 14),
          hintStyle: TextStyle(
            color: GTheme.reverse(context).withAlpha(100),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _expiryDate.text = GenesisDate.formatNormalDateN(picked);
        expiryDate = picked;
      });
    }
  }

  Future<void> selectPassportDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: passportExpiryDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _passportExpiryDateStr.text = GenesisDate.formatNormalDateN(picked);
        passportExpiryDate = picked;
      });
    }
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: GTheme.reverse(context).withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
              labelStyle: const TextStyle(fontSize: 14),
            ),
            dropdownColor: GTheme.color(context),
            style: TextStyle(color: GTheme.reverse(context), fontSize: 14),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: e.text()))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
