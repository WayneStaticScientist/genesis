import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis/utils/theme.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sms_sender/sms_sender.dart';
import 'package:permission_handler/permission_handler.dart';

class TrackerIntegrationScreen extends StatefulWidget {
  const TrackerIntegrationScreen({super.key});

  @override
  State<TrackerIntegrationScreen> createState() => _TrackerIntegrationScreenState();
}

class _TrackerIntegrationScreenState extends State<TrackerIntegrationScreen> {
  int _selectedBrandIndex = 0;
  final String _serverIp = '167.86.107.113';
  final String _serverPort = '5013';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTheme.surface(context),
      appBar: AppBar(
        title: const Text(
          "Hardware Tracker Integration",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 24),
            const Text(
              "SELECT HARDWARE BRAND",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildBrandSelector(),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildSelectedBrandView(context),
            ),
            const SizedBox(height: 24),
            _buildGeneralNotes(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GTheme.primary(context),
            GTheme.primary(context).withBlue(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: GTheme.primary(context).withAlpha(60),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LineIcons.locationArrow,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Live Tracking Architecture",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Configure and register hardware GPS trackers directly with the Genesis TCP socket handler, featuring intelligent mobile fallback.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSelector() {
    final List<Map<String, dynamic>> brands = [
      {'name': 'SinoTrack', 'icon': LineIcons.satelliteDish},
      {'name': 'Coban', 'icon': LineIcons.broadcastTower},
      {'name': 'Concox', 'icon': LineIcons.mobilePhone},
      {'name': 'Traccar / Webhook', 'icon': LineIcons.laptopCode},
    ];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedBrandIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBrandIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : GTheme.cardColor(context),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.blueAccent : Colors.grey.withAlpha(20),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blueAccent.withAlpha(100),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    brands[index]['icon'],
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    brands[index]['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade300,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedBrandView(BuildContext context) {
    switch (_selectedBrandIndex) {
      case 0:
        return _buildSinoTrackView(context);
      case 1:
        return _buildCobanView(context);
      case 2:
        return _buildConcoxView(context);
      case 3:
        return _buildWebhookView(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSinoTrackView(BuildContext context) {
    return Column(
      key: const ValueKey('sinotrack'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          context,
          title: "SinoTrack Integration (ST-901 / ST-902)",
          description: "SinoTrack hardware communicates via TCP packets. Ensure you configure the tracker to connect directly to our high-performance TCP socket stream.",
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildConnectionSpecs(context, protocol: "TCP", port: _serverPort, ip: _serverIp),
        const SizedBox(height: 16),
        const Text(
          "REQUIRED CONFIGURATION COMMANDS",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        _buildCodeBox(context, "1. Set IP and Port (SMS)", "8040000 $_serverIp $_serverPort"),
        _buildCodeBox(context, "2. Set Heartbeat / Interval (180s)", "1050000 180"),
        _buildCodeBox(context, "3. Set Timezone (UTC 00:00)", "8960000E00"),
        _buildCodeBox(context, "4. Enable GPRS Mode", "GPRS0000"),
        const SizedBox(height: 20),
        _buildSmsWizardButton(context, brandName: "SinoTrack ST-901", commandTemplate: "8040000 $_serverIp $_serverPort"),
      ],
    );
  }

  Widget _buildCobanView(BuildContext context) {
    return Column(
      key: const ValueKey('coban'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          context,
          title: "Coban Integration (TK103 / TK303)",
          description: "Coban trackers are highly reliable GPS units using raw text communication formats. Follow these setup configurations.",
          color: Colors.purple,
        ),
        const SizedBox(height: 16),
        _buildConnectionSpecs(context, protocol: "TCP", port: _serverPort, ip: _serverIp),
        const SizedBox(height: 16),
        const Text(
          "REQUIRED CONFIGURATION COMMANDS",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        _buildCodeBox(context, "1. Set IP and Port (SMS)", "adminip123456 $_serverIp $_serverPort"),
        _buildCodeBox(context, "2. Enable GPRS Mode", "gprs123456"),
        _buildCodeBox(context, "3. Set Timezone (UTC 00:00)", "time zone123456 0"),
        const SizedBox(height: 20),
        _buildSmsWizardButton(context, brandName: "Coban TK103", commandTemplate: "adminip123456 $_serverIp $_serverPort"),
      ],
    );
  }

  Widget _buildConcoxView(BuildContext context) {
    return Column(
      key: const ValueKey('concox'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          context,
          title: "Concox Integration (GT06 / WeTrack)",
          description: "Concox protocol uses binary headers over TCP/UDP channels. Best configured with GPRS activated and standard parameters set.",
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildConnectionSpecs(context, protocol: "TCP", port: _serverPort, ip: _serverIp),
        const SizedBox(height: 16),
        const Text(
          "REQUIRED CONFIGURATION COMMANDS",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        _buildCodeBox(context, "1. Set IP and Port (SMS)", "SERVER,1,$_serverIp,$_serverPort,0#"),
        _buildCodeBox(context, "2. Activate GPRS Data Link", "GPRS#"),
        _buildCodeBox(context, "3. Configure Heartbeat (3m)", "HBT,3#"),
        const SizedBox(height: 20),
        _buildSmsWizardButton(context, brandName: "Concox GT06", commandTemplate: "SERVER,1,$_serverIp,$_serverPort,0#"),
      ],
    );
  }

  Widget _buildWebhookView(BuildContext context) {
    const String webhookUrl = "https://api.genesiserp.co.zw/webhook/tracker/ping";
    const String payloadExample = '''{
  "trackerId": "358941092837261",
  "lat": -17.8292,
  "lng": 31.0522,
  "speed": 60.5,
  "heading": 180,
  "battery": 85
}''';

    return Column(
      key: const ValueKey('webhook'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          context,
          title: "Custom Traccar / HTTP Webhook",
          description: "For other hardware trackers or gateways (e.g. Traccar, GPSWOX), you can forward GPS location updates directly via REST API endpoints.",
          color: Colors.teal,
        ),
        const SizedBox(height: 16),
        const Text(
          "WEBHOOK ENDPOINT",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        _buildCodeBox(context, "HTTP POST URL", webhookUrl),
        const SizedBox(height: 16),
        const Text(
          "EXPECTED JSON PAYLOAD",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        _buildPayloadBox(context, payloadExample),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required String description, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionSpecs(BuildContext context, {required String protocol, required String port, required String ip}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSpecItem("PROTOCOL", protocol, Colors.greenAccent),
          _buildSpecItem("SERVER IP", ip, Colors.blueAccent),
          _buildSpecItem("PORT", port, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value, Color accent) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: accent),
        ),
      ],
    );
  }

  Widget _buildCodeBox(BuildContext context, String label, String code) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LineIcons.copy, color: Colors.grey, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Copied to clipboard: $code"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: GTheme.primary(context),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildPayloadBox(BuildContext context, String payload) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              payload,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.tealAccent.shade200,
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(LineIcons.copy, color: Colors.grey, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: payload));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Payload copied!"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: GTheme.primary(context),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildSmsWizardButton(BuildContext context, {required String brandName, required String commandTemplate}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _showAutoConfigSheet(context, brandName, commandTemplate),
        icon: const Icon(LineIcons.sms, color: Colors.white),
        label: Text("Configure $brandName via SMS", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: Colors.blueAccent.withAlpha(100),
        ),
      ),
    );
  }

  Widget _buildGeneralNotes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withAlpha(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LineIcons.infoCircle, color: Colors.grey, size: 20),
              SizedBox(width: 10),
              Text(
                "Integration Steps Summary",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildBulletItem("1. Assign Tracker to Vehicle", "Open the Vehicles panel on the Genesis Admin portal and register the tracker's hardware IMEI to the vehicle."),
          const Divider(height: 24, color: Colors.grey),
          _buildBulletItem("2. Trip Start Syncing", "Once a driver launches a route, Genesis links the live tracking session directly to the corresponding tracker ID."),
          const Divider(height: 24, color: Colors.grey),
          _buildBulletItem("3. Mobile Phone GPS Fallback", "If the hardware tracker goes offline or fails, the driver's phone app acts as an automatic fallback, pushing location streams in the background."),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12, height: 1.4),
        ),
      ],
    );
  }

  void _showAutoConfigSheet(BuildContext context, String brandName, String commandTemplate) {
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SMS Config Wizard ($brandName)",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "This will transmit the required setup command directly to the SIM card installed inside the GPS tracker.",
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "PAYLOAD COMMAND:",
                      style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      commandTemplate,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: phoneController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Tracker SIM Phone Number",
                  labelStyle: TextStyle(color: Colors.white.withAlpha(150)),
                  hintText: "+263...",
                  hintStyle: TextStyle(color: Colors.white.withAlpha(80)),
                  filled: true,
                  fillColor: Colors.white.withAlpha(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (phoneController.text.isEmpty) return;

                    var status = await Permission.sms.status;
                    if (!status.isGranted) {
                      status = await Permission.sms.request();
                    }

                    if (status.isGranted) {
                      try {
                        await SmsSender.sendSms(
                          phoneNumber: phoneController.text,
                          message: commandTemplate,
                          simSlot: 0,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Configuration SMS Sent Successfully!"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: $e"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    } else {
                      final uri = Uri.parse("sms:${phoneController.text}?body=${Uri.encodeComponent(commandTemplate)}");
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    }
                    if (context.mounted) {
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text("Send Configuration SMS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
