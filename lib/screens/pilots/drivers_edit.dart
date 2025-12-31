import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';

class AdminEditDriver extends StatefulWidget {
  final Map<String, dynamic> driver;
  const AdminEditDriver({super.key, required this.driver});

  @override
  State<AdminEditDriver> createState() => _AdminEditDriverState();
}

class _AdminEditDriverState extends State<AdminEditDriver> {
  final _formKey = GlobalKey<FormState>();

  // Form State initialized with current driver data
  late String _name;
  late String _status;
  late String _experience;
  late double _rating;
  late int _safety;

  @override
  void initState() {
    super.initState();
    _name = widget.driver['name'];
    _status = widget.driver['status'];
    _experience = widget.driver['experience'];
    _rating = widget.driver['rating'];
    _safety = widget.driver['safety'];
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedDriver = {
        ...widget.driver,
        "name": _name,
        "status": _status,
        "experience": _experience,
        "rating": _rating,
        "safety": _safety,
      };

      Navigator.pop(context, updatedDriver);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTheme.color(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: GTheme.reverse()),
          onPressed: () => Navigator.pop(context),
        ),
        title: "Edit Pilot".text(
          style: TextStyle(
            color: GTheme.reverse(),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
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
              child: "Update".text(
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                        color: widget.driver['color'].withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.driver['color'],
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: widget.driver['avatar'].toString().text(
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: widget.driver['color'],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    "ID: PRT-${widget.driver['trips']}".text(
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _sectionHeader("Personal Details"),
              _buildField(
                label: "Full Name",
                initialValue: _name,
                hint: "Driver Name",
                icon: Icons.person_outline_rounded,
                onSaved: (val) => _name = val ?? "",
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              _buildField(
                label: "Years of Experience",
                initialValue: _experience,
                hint: "e.g. 5 Years",
                icon: Icons.history_edu_rounded,
                onSaved: (val) => _experience = val ?? "",
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
                      onSaved: (val) =>
                          _rating = double.tryParse(val ?? "0") ?? 0.0,
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
                      onSaved: (val) => _safety = int.tryParse(val ?? "0") ?? 0,
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
          color: GTheme.reverse().withAlpha(128),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    String? initialValue,
    TextInputType? keyboardType,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GTheme.reverse().withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        initialValue: initialValue,
        onSaved: onSaved,
        validator: validator,
        keyboardType: keyboardType,
        style: TextStyle(color: GTheme.reverse()),
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
            color: GTheme.reverse().withAlpha(100),
            fontSize: 14,
          ),
        ),
      ),
    );
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
            color: GTheme.reverse().withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
              labelStyle: const TextStyle(fontSize: 14),
            ),
            dropdownColor: GTheme.color(),
            style: TextStyle(color: GTheme.reverse(), fontSize: 14),
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
