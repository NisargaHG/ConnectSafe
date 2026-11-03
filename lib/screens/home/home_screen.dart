
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../services/emergency_message_service.dart';
import '../emergency/emergency_message_screen.dart';
import '../contacts/select_emergency_contacts_screen.dart';
import '../../services/emergency_contact_service.dart';
import '../../services/sms_service.dart';
import '../../services/mesh_service.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
int selectedIndex = 0;

bool isSendingEmergency = false;
int countdown = 3;
Timer? countdownTimer;

final ValueNotifier<int> countdownNotifier =
ValueNotifier<int>(3);

// ============================================================
// EMERGENCY
// ============================================================

String selectedEmergencyType = 'GENERAL';

List<int> selectedContactIds = [];

static const String emergencyMessage =
'Emergency! I need immediate assistance.';

// ============================================================
// BLE MESH NETWORK
// ============================================================

final MeshService _meshService = MeshService.instance;

List<ScanResult> meshDevices = [];

bool isMeshScanning = false;

String meshStatus = 'Ready to scan';

// ============================================================
// INIT
// ============================================================

@override
void initState() {
super.initState();

initializeMesh();
}

@override
void dispose() {
countdownTimer?.cancel();

countdownNotifier.dispose();

super.dispose();
}

// ============================================================
// SOS BUTTON
// ============================================================

Future<void> handleSOS() async {
if (isSendingEmergency) return;

// First choose the emergency type
final selectedType = await showEmergencyTypeDialog();

if (selectedType == null) return;

// ============================================================
// OTHER EMERGENCY
// ============================================================

if (selectedType == 'OTHER') {
final result = await Navigator.push<List<int>>(
context,
MaterialPageRoute(
builder: (_) =>
const SelectEmergencyContactsScreen(),
),
);

if (result == null || result.isEmpty) {
return;
}

selectedContactIds = result;

// OTHER is not sent to Django.
// PERSONAL_SAFETY is used because it is supported
// by the backend.
selectedEmergencyType = 'PERSONAL_SAFETY';
} else {
selectedEmergencyType = selectedType;

selectedContactIds = [];
}

if (!mounted) return;

setState(() {
isSendingEmergency = true;
});

// ============================================================
// START COUNTDOWN
// ============================================================

countdownNotifier.value = 3;

countdownTimer = Timer.periodic(
const Duration(seconds: 1),
(timer) {
if (countdownNotifier.value > 1) {
countdownNotifier.value--;
} else {
timer.cancel();
sendEmergency();
}
},
);

// ============================================================
// COUNTDOWN DIALOG
// ============================================================

await showDialog(
context: context,
barrierDismissible: false,
builder: (dialogContext) {
return AlertDialog(
title: const Text(
'Emergency SOS',
textAlign: TextAlign.center,
),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(
Icons.warning_rounded,
color: Colors.red,
size: 70,
),

const SizedBox(height: 15),

Text(
'Emergency type: '
'${selectedEmergencyType.replaceAll('_', ' ')}',
textAlign: TextAlign.center,
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 16,
),
),

const SizedBox(height: 10),

const Text(
'Emergency message will be sent automatically.',
textAlign: TextAlign.center,
),

const SizedBox(height: 20),

ValueListenableBuilder<int>(
valueListenable: countdownNotifier,
builder: (context, value, child) {
return Text(
'$value',
style: const TextStyle(
fontSize: 60,
fontWeight: FontWeight.bold,
color: Colors.red,
),
);
},
),

const SizedBox(height: 10),

const Text(
'Sending emergency...',
textAlign: TextAlign.center,
),
],
),
actions: [
TextButton(
onPressed: () {
cancelSOS();

Navigator.pop(dialogContext);
},
child: const Text(
'CANCEL',
style: TextStyle(
color: Colors.red,
fontWeight: FontWeight.bold,
),
),
),
],
);
},
);
}

// ============================================================
// EMERGENCY TYPE SELECTION
// ============================================================

Future<String?> showEmergencyTypeDialog() async {
return showDialog<String>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text(
'What happened?',
textAlign: TextAlign.center,
),
content: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
emergencyTypeButton(
dialogContext,
'FLOOD',
'🌊',
'Flood',
),

emergencyTypeButton(
dialogContext,
'FIRE',
'🔥',
'Fire',
),

emergencyTypeButton(
dialogContext,
'ROAD_ACCIDENT',
'🚗',
'Road Accident',
),

emergencyTypeButton(
dialogContext,
'MEDICAL',
'🏥',
'Medical Emergency',
),

emergencyTypeButton(
dialogContext,
'EARTHQUAKE',
'🌎',
'Earthquake',
),

emergencyTypeButton(
dialogContext,
'CYCLONE',
'🌀',
'Cyclone',
),

emergencyTypeButton(
dialogContext,
'LANDSLIDE',
'🪨',
'Landslide',
),

emergencyTypeButton(
dialogContext,
'OTHER',
'⚠️',
'Other',
),
],
),
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: const Text('CANCEL'),
),
],
);
},
);
}

// ============================================================
// EMERGENCY TYPE BUTTON
// ============================================================

Widget emergencyTypeButton(
BuildContext dialogContext,
String type,
String emoji,
String title,
) {
return SizedBox(
width: double.infinity,
child: Padding(
padding: const EdgeInsets.only(bottom: 8),
child: OutlinedButton(
onPressed: () {
Navigator.pop(dialogContext, type);
},
style: OutlinedButton.styleFrom(
padding: const EdgeInsets.symmetric(
vertical: 14,
horizontal: 12,
),
),
child: Row(
children: [
Text(
emoji,
style: const TextStyle(
fontSize: 24,
),
),

const SizedBox(width: 15),

Text(
title,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
),
),
],
),
),
),
);
}

// ============================================================
// CANCEL SOS
// ============================================================

void cancelSOS() {
countdownTimer?.cancel();

countdownNotifier.value = 3;

if (!mounted) return;

setState(() {
isSendingEmergency = false;
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('SOS cancelled'),
),
);
}

// ============================================================
// AI ROUTING RESULT
// ============================================================

Future<void> showAIResult(
Map<String, dynamic> result,
) async {
final dynamic aiData = result['ai'];

if (aiData == null || aiData is! Map) {
debugPrint('AI RESULT: No AI data found');
return;
}

final ai = Map<String, dynamic>.from(aiData);

final status =
ai['status']?.toString() ?? 'Unknown';

final bestNode =
ai['best_node']?.toString() ?? 'Not available';

String formatConfidence(dynamic value) {
if (value == null) return 'N/A';

final confidence =
double.tryParse(value.toString());

if (confidence == null) {
return value.toString();
}

final percentage = confidence <= 1
? confidence * 100
    : confidence;

return '${percentage.toStringAsFixed(1)}%';
}

final ranking = ai['ranking'];

String rankingText = '';

if (ranking is List) {
for (int i = 0; i < ranking.length; i++) {
final node = ranking[i];

if (node is Map) {
final nodeMap =
Map<String, dynamic>.from(node);

final nodeId =
nodeMap['node_id']?.toString() ??
nodeMap['node']?.toString() ??
'Unknown';

final score =
nodeMap['score']?.toString() ??
nodeMap['probability']?.toString() ??
'';

rankingText +=
'${i + 1}. $nodeId'
'${score.isNotEmpty ? '  •  $score' : ''}\n';
} else {
rankingText +=
'${i + 1}. ${node.toString()}\n';
}
}
} else if (ranking is Map) {
ranking.forEach((key, value) {
rankingText += '$key: $value\n';
});
}

if (!mounted) return;

await showDialog(
context: context,
barrierDismissible: false,
builder: (dialogContext) {
return AlertDialog(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
),
title: Row(
children: [
Container(
padding: const EdgeInsets.all(10),
decoration: BoxDecoration(
color:
AppColors.primary.withOpacity(0.12),
shape: BoxShape.circle,
),
child: const Icon(
Icons.smart_toy_rounded,
color: AppColors.primary,
size: 28,
),
),

const SizedBox(width: 12),

const Expanded(
child: Text(
'AI Routing Result',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),
],
),

content: SingleChildScrollView(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const SizedBox(height: 10),

// AI STATUS
Container(
width: double.infinity,
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color:
Colors.green.withOpacity(0.10),
borderRadius:
BorderRadius.circular(14),
),
child: Row(
children: [
const Icon(
Icons.check_circle_rounded,
color: Colors.green,
),

const SizedBox(width: 10),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Routing Status',
style: TextStyle(
fontSize: 12,
color:
AppColors.textSecondary,
),
),

const SizedBox(height: 3),

Text(
status.toUpperCase(),
style: const TextStyle(
fontWeight:
FontWeight.bold,
color: Colors.green,
),
),
],
),
),
],
),
),

const SizedBox(height: 16),

// BEST NODE
Container(
width: double.infinity,
padding:
const EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius:
BorderRadius.circular(14),
border: Border.all(
color: AppColors.border,
),
),
child: Column(
children: [
const Icon(
Icons.hub_rounded,
color: AppColors.primary,
size: 38,
),

const SizedBox(height: 8),

const Text(
'Best Communication Node',
style: TextStyle(
fontSize: 13,
color:
AppColors.textSecondary,
),
),

const SizedBox(height: 4),

Text(
bestNode,
style: const TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color:
AppColors.textPrimary,
),
),
],
),
),

const SizedBox(height: 16),

// CONFIDENCE
Row(
children: [
Expanded(
child: _aiInfoCard(
icon:
Icons.verified_rounded,
title: 'Confidence',
value: formatConfidence(
ai['confidence'],
),
),
),

const SizedBox(width: 12),

Expanded(
child: _aiInfoCard(
icon: Icons.route_rounded,
title: 'Selected Node',
value: bestNode,
),
),
],
),

if (rankingText.isNotEmpty) ...[
const SizedBox(height: 20),

const Text(
'AI Node Ranking',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color:
AppColors.textPrimary,
),
),

const SizedBox(height: 8),

Container(
width: double.infinity,
padding:
const EdgeInsets.all(14),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius:
BorderRadius.circular(12),
border: Border.all(
color: AppColors.border,
),
),
child: Text(
rankingText.trim(),
style: const TextStyle(
color:
AppColors.textSecondary,
height: 1.5,
),
),
),
],

const SizedBox(height: 18),

const Text(
'The AI selected the communication node '
'based on available network conditions.',
style: TextStyle(
fontSize: 12,
color:
AppColors.textSecondary,
),
),
],
),
),

actions: [
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () {
Navigator.pop(dialogContext);
},
style:
ElevatedButton.styleFrom(
backgroundColor:
AppColors.primary,
foregroundColor: Colors.white,
padding:
const EdgeInsets.symmetric(
vertical: 13,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(12),
),
),
child: const Text(
'Continue',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),
),
],
);
},
);
}

// ============================================================
// AI INFORMATION CARD
// ============================================================

Widget _aiInfoCard({
required IconData icon,
required String title,
required String value,
}) {
return Container(
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius:
BorderRadius.circular(14),
border: Border.all(
color: AppColors.border,
),
),
child: Column(
children: [
Icon(
icon,
color: AppColors.primary,
size: 25,
),

const SizedBox(height: 7),

Text(
title,
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 11,
color:
AppColors.textSecondary,
),
),

const SizedBox(height: 3),

Text(
value,
textAlign: TextAlign.center,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
fontWeight: FontWeight.bold,
color:
AppColors.textPrimary,
),
),
],
),
);
}

// ============================================================
// STORE & FORWARD RESULT
// ============================================================

Future<void> showStoreForwardResult(
Map<String, dynamic> result,
) async {
Map<String, dynamic> data = {};

if (result['data'] is Map) {
data =
Map<String, dynamic>.from(result['data']);
}

final status =
data['status']?.toString() ??
result['status']?.toString() ??
'STORED';

final retryCount =
data['retry_count']?.toString() ?? '0';

final storedAt =
data['stored_at']?.toString() ?? '';

final updatedAt =
data['updated_at']?.toString() ?? '';

final emergencyData =
data['emergency_message'];

String node = 'AI selected node';

if (result['ai'] is Map) {
final ai =
Map<String, dynamic>.from(result['ai']);

node =
ai['best_node']?.toString() ??
ai['selected_node']?.toString() ??
node;
}

if (!mounted) return;

await showDialog(
context: context,
barrierDismissible: false,
builder: (dialogContext) {
final normalizedStatus =
status.toUpperCase();

final forwarded =
normalizedStatus == 'FORWARDED' ||
normalizedStatus == 'DELIVERED';

final delivered =
normalizedStatus == 'DELIVERED';

return AlertDialog(
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(20),
),

title: Row(
children: [
Container(
padding:
const EdgeInsets.all(10),
decoration: BoxDecoration(
color:
AppColors.primary.withOpacity(
0.12,
),
shape: BoxShape.circle,
),
child: const Icon(
Icons.sync_alt_rounded,
color:
AppColors.primary,
size: 28,
),
),

const SizedBox(width: 12),

const Expanded(
child: Text(
'Store & Forward',
style: TextStyle(
fontWeight:
FontWeight.bold,
),
),
),
],
),

content:
SingleChildScrollView(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const SizedBox(height: 10),

// STATUS
Container(
width: double.infinity,
padding:
const EdgeInsets.all(16),
decoration:
BoxDecoration(
color: forwarded
? Colors.green
    .withOpacity(0.10)
    : Colors.orange
    .withOpacity(0.10),
borderRadius:
BorderRadius.circular(
14,
),
),
child: Row(
children: [
Icon(
forwarded
? Icons
    .check_circle_rounded
    : Icons
    .storage_rounded,
color: forwarded
? Colors.green
    : Colors.orange,
size: 30,
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
const Text(
'Message Status',
style: TextStyle(
fontSize: 12,
color: AppColors
    .textSecondary,
),
),

const SizedBox(height: 4),

Text(
normalizedStatus,
style: TextStyle(
fontWeight:
FontWeight.bold,
fontSize: 17,
color: forwarded
? Colors.green
    : Colors.orange,
),
),
],
),
),
],
),
),

const SizedBox(height: 20),

const Text(
'Communication Flow',
style: TextStyle(
fontSize: 16,
fontWeight:
FontWeight.bold,
color:
AppColors.textPrimary,
),
),

const SizedBox(height: 12),

_communicationStep(
icon:
Icons.check_circle,
title:
'Emergency Created',
subtitle:
'Emergency message accepted',
color:
Colors.green,
),

_flowLine(),

_communicationStep(
icon:
Icons.smart_toy_rounded,
title:
'AI Node Selected',
subtitle: node,
color:
AppColors.primary,
),

_flowLine(),

_communicationStep(
icon:
Icons.inventory_2_rounded,
title:
'Message Stored',
subtitle:
'Message saved for reliable delivery',
color:
Colors.green,
),

_flowLine(),

_communicationStep(
icon: forwarded
? Icons.check_circle
    : Icons.sync_rounded,
title: forwarded
? 'Message Forwarded'
    : 'Waiting for Forwarding',
subtitle: forwarded
? 'Message forwarded through the network'
    : 'Message is waiting for a network path',
color: forwarded
? Colors.green
    : Colors.orange,
),

_flowLine(),

_communicationStep(
icon: delivered
? Icons.check_circle
    : Icons
    .radio_button_unchecked,
title: 'Delivered',
subtitle: delivered
? 'Emergency reached destination'
    : 'Delivery confirmation pending',
color: delivered
? Colors.green
    : AppColors
    .textSecondary,
),

const SizedBox(height: 18),

// DETAILS
Container(
width: double.infinity,
padding:
const EdgeInsets.all(14),
decoration:
BoxDecoration(
color:
AppColors.surface,
borderRadius:
BorderRadius.circular(
14,
),
border: Border.all(
color:
AppColors.border,
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
const Text(
'Communication Details',
style: TextStyle(
fontWeight:
FontWeight.bold,
color:
AppColors
    .textPrimary,
),
),

const SizedBox(height: 10),

_detailRow(
'Selected Node',
node,
),

_detailRow(
'Retry Count',
retryCount,
),

if (storedAt.isNotEmpty)
_detailRow(
'Stored At',
_formatServerDate(
storedAt,
),
),

if (updatedAt.isNotEmpty)
_detailRow(
'Updated At',
_formatServerDate(
updatedAt,
),
),

if (emergencyData is Map)
_detailRow(
'Message ID',
emergencyData[
'id']
    ?.toString() ??
'Created',
),
],
),
),

const SizedBox(height: 16),

const Text(
'Store-and-forward allows the '
'emergency message to remain available '
'until a communication path is available.',
style: TextStyle(
fontSize: 12,
height: 1.4,
color:
AppColors.textSecondary,
),
),
],
),
),

actions: [
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () {
Navigator.pop(
dialogContext,
);
},
style:
ElevatedButton.styleFrom(
backgroundColor:
AppColors.primary,
foregroundColor:
Colors.white,
padding:
const EdgeInsets.symmetric(
vertical: 13,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
12,
),
),
),
child: const Text(
'Continue',
style: TextStyle(
fontWeight:
FontWeight.bold,
),
),
),
),
],
);
},
);
}

// ============================================================
// COMMUNICATION STEP
// ============================================================

Widget _communicationStep({
required IconData icon,
required String title,
required String subtitle,
required Color color,
}) {
return Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 34,
height: 34,
decoration: BoxDecoration(
color:
color.withOpacity(0.12),
shape: BoxShape.circle,
),
child: Icon(
icon,
color: color,
size: 20,
),
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
fontWeight:
FontWeight.bold,
color:
AppColors.textPrimary,
),
),

const SizedBox(height: 3),

Text(
subtitle,
style: const TextStyle(
fontSize: 12,
color:
AppColors.textSecondary,
),
),
],
),
),
],
);
}

// ============================================================
// FLOW LINE
// ============================================================

Widget _flowLine() {
return Container(
margin: const EdgeInsets.only(
left: 16,
top: 3,
bottom: 3,
),
height: 22,
width: 2,
color: AppColors.border,
);
}

// ============================================================
// DETAIL ROW
// ============================================================

Widget _detailRow(
String title,
String value,
) {
return Padding(
padding:
const EdgeInsets.only(bottom: 8),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
SizedBox(
width: 95,
child: Text(
title,
style: const TextStyle(
fontSize: 12,
color:
AppColors.textSecondary,
),
),
),

Expanded(
child: Text(
value,
style: const TextStyle(
fontSize: 12,
fontWeight:
FontWeight.w600,
color:
AppColors.textPrimary,
),
),
),
],
),
);
}

// ============================================================
// FORMAT SERVER DATE
// ============================================================

String _formatServerDate(
String date,
) {
try {
final parsed =
DateTime.parse(date).toLocal();

return '${parsed.day.toString().padLeft(2, '0')}/'
'${parsed.month.toString().padLeft(2, '0')}/'
'${parsed.year} '
'${parsed.hour.toString().padLeft(2, '0')}:'
'${parsed.minute.toString().padLeft(2, '0')}';
} catch (_) {
return date;
}
}

// ============================================================
// SEND EMERGENCY
// ============================================================

Future<void> sendEmergency() async {
try {
debugPrint(
'Starting emergency process...',
);

debugPrint(
'Emergency type: '
'$selectedEmergencyType',
);

// ========================================================
// LOCATION SERVICE
// ========================================================

final serviceEnabled =
await Geolocator
    .isLocationServiceEnabled();

if (!serviceEnabled) {
throw Exception(
'Location services are disabled. '
'Please enable GPS.',
);
}

// ========================================================
// LOCATION PERMISSION
// ========================================================

LocationPermission permission =
await Geolocator.checkPermission();

if (permission ==
LocationPermission.denied) {
permission =
await Geolocator.requestPermission();
}

if (permission ==
LocationPermission.denied) {
throw Exception(
'Location permission denied.',
);
}

if (permission ==
LocationPermission.deniedForever) {
throw Exception(
'Location permission permanently denied. '
'Please enable location permission from settings.',
);
}

// ========================================================
// GET CURRENT LOCATION
// ========================================================

debugPrint(
'Getting current location...',
);

final position =
await Geolocator.getCurrentPosition(
locationSettings:
const LocationSettings(
accuracy:
LocationAccuracy.high,
),
);

debugPrint(
'Location: '
'${position.latitude}, '
'${position.longitude}',
);

// ========================================================
// CREATE EMERGENCY
// ========================================================

final result =
await EmergencyMessageService
    .instance
    .createMessage(
message: emergencyMessage,
latitude: position.latitude,
longitude: position.longitude,
priority: 'HIGH',
emergencyType:
selectedEmergencyType,
contactIds:
selectedContactIds,
);

debugPrint(
'Emergency created successfully: '
'$result',
);

// ========================================================
// AI ROUTING RESULT
// ========================================================

await showAIResult(result);

// ========================================================
// STORE & FORWARD RESULT
// ========================================================

await showStoreForwardResult(
result,
);

// ========================================================
// EMERGENCY SMS
// ========================================================

await sendEmergencySMS(
latitude: position.latitude,
longitude: position.longitude,
);

// ========================================================
// RESET STATE
// ========================================================

if (!mounted) return;

setState(() {
isSendingEmergency = false;
});

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
'🚨 $selectedEmergencyType '
'emergency sent successfully!',
),
backgroundColor:
Colors.green,
duration:
const Duration(seconds: 4),
),
);

// ========================================================
// CLOSE COUNTDOWN DIALOG
// ========================================================

if (Navigator.canPop(context)) {
Navigator.pop(context);
}
} catch (e) {
debugPrint(
'Emergency sending failed: $e',
);

if (!mounted) return;

setState(() {
isSendingEmergency = false;
});

countdownTimer?.cancel();

if (Navigator.canPop(context)) {
Navigator.pop(context);
}

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
'Failed to send emergency: $e',
),
backgroundColor:
Colors.red,
duration:
const Duration(seconds: 5),
),
);
}
}

// ============================================================
// EMERGENCY SMS
// ============================================================

Future<void> sendEmergencySMS({
required double latitude,
required double longitude,
}) async {
try {
if (selectedContactIds.isEmpty) {
debugPrint(
'No emergency contacts selected.',
);

return;
}

// ========================================================
// GET CONTACTS
// ========================================================

final contacts =
await EmergencyContactService
    .instance
    .getContacts();

// ========================================================
// FILTER SELECTED CONTACTS
// ========================================================

final selectedContacts =
contacts.where((contact) {
final id = contact['id'];

return selectedContactIds.contains(
id is int
? id
    : int.tryParse(
id.toString(),
),
);
}).toList();

if (selectedContacts.isEmpty) {
debugPrint(
'No matching emergency contacts found.',
);

return;
}

// ========================================================
// GOOGLE MAPS LINK
// ========================================================

final mapLink =
'https://www.google.com/maps'
'?q=$latitude,$longitude';

// ========================================================
// SMS MESSAGE
// ========================================================

final smsMessage =
'''🚨 EMERGENCY ALERT 🚨

I need immediate assistance.

Emergency Type: ${selectedEmergencyType.replaceAll('_', ' ')}

Priority: HIGH

My current location:
$mapLink

Please contact me immediately.''';

// ========================================================
// SEND SMS
// ========================================================

int successCount = 0;

for (final contact
in selectedContacts) {
final phone =
contact['phone']?.toString();

if (phone == null ||
phone.trim().isEmpty) {
debugPrint(
'Skipping contact '
'${contact['name']} - '
'no phone number.',
);

continue;
}

final success =
await SmsService.instance
    .sendSMS(
phone: phone,
message: smsMessage,
);

if (success) {
successCount++;
}
}

debugPrint(
'SMS completed: '
'$successCount/'
'${selectedContacts.length}',
);
} catch (e) {
debugPrint(
'Emergency SMS error: $e',
);
}
}

// ============================================================
// BLE MESH NETWORK
// ============================================================

void initializeMesh() {
meshDevices =
List<ScanResult>.from(
_meshService.discoveredDevices,
);
}

// ============================================================
// BLE MESH DISCOVERY
// ============================================================

Future<void> startMeshScan() async {
if (isMeshScanning) return;

setState(() {
isMeshScanning = true;

meshStatus =
'Scanning for nearby nodes...';

meshDevices.clear();
});

try {
await _meshService.startScan(
timeout:
const Duration(seconds: 8),
);

if (!mounted) return;

// Get latest devices from MeshService
meshDevices =
List<ScanResult>.from(
_meshService.discoveredDevices,
);

setState(() {
isMeshScanning = false;

meshStatus =
meshDevices.isEmpty
? 'No nearby nodes found'
    : '${meshDevices.length} '
'nearby node(s) discovered';
});
} catch (e) {
debugPrint(
'Mesh scan error: $e',
);

if (!mounted) return;

setState(() {
isMeshScanning = false;

meshStatus =
'Bluetooth scan failed';
});
}
}

// ============================================================
// STOP MESH SCAN
// ============================================================

Future<void> stopMeshScan() async {
await _meshService.stopScan();

if (!mounted) return;

meshDevices =
List<ScanResult>.from(
_meshService.discoveredDevices,
);

setState(() {
isMeshScanning = false;

meshStatus =
'${meshDevices.length} node(s) discovered';
});
}

// ============================================================
// MESH NETWORK CARD
// ============================================================

Widget buildMeshNetworkCard() {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: AppColors.border,
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// ======================================================
// HEADER
// ======================================================

Row(
children: [
Container(
padding:
const EdgeInsets.all(10),
decoration:
BoxDecoration(
color:
AppColors.primary
    .withOpacity(0.12),
shape:
BoxShape.circle,
),
child: const Icon(
Icons.hub_rounded,
color:
AppColors.primary,
size: 26,
),
),

const SizedBox(width: 12),

const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Mesh Network',
style: TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
color: AppColors
    .textPrimary,
),
),

SizedBox(height: 3),

Text(
'Nearby BLE communication nodes',
style: TextStyle(
fontSize: 12,
color: AppColors
    .textSecondary,
),
),
],
),
),

Container(
padding:
const EdgeInsets.symmetric(
horizontal: 10,
vertical: 6,
),
decoration:
BoxDecoration(
color: isMeshScanning
? Colors.orange
    .withOpacity(0.12)
    : Colors.green
    .withOpacity(0.12),
borderRadius:
BorderRadius.circular(
20,
),
),
child: Row(
mainAxisSize:
MainAxisSize.min,
children: [
Icon(
isMeshScanning
? Icons.sync
    : Icons
    .bluetooth_connected,
size: 15,
color: isMeshScanning
? Colors.orange
    : Colors.green,
),

const SizedBox(
width: 5,
),

Text(
isMeshScanning
? 'SCANNING'
    : 'READY',
style: TextStyle(
fontSize: 10,
fontWeight:
FontWeight.bold,
color: isMeshScanning
? Colors.orange
    : Colors.green,
),
),
],
),
),
],
),

const SizedBox(height: 18),

// ======================================================
// NODE COUNT
// ======================================================

Container(
width: double.infinity,
padding:
const EdgeInsets.all(14),
decoration:
BoxDecoration(
color:
AppColors.background,
borderRadius:
BorderRadius.circular(
14,
),
),
child: Row(
children: [
const Icon(
Icons
    .devices_other_rounded,
color:
AppColors.primary,
size: 28,
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
const Text(
'Nearby Nodes',
style: TextStyle(
fontSize: 12,
color: AppColors
    .textSecondary,
),
),

const SizedBox(
height: 3,
),

Text(
'${meshDevices.length}',
style:
const TextStyle(
fontSize: 24,
fontWeight:
FontWeight.bold,
color: AppColors
    .textPrimary,
),
),
],
),
),

Expanded(
child: Text(
meshStatus,
textAlign:
TextAlign.right,
style:
const TextStyle(
fontSize: 11,
color: AppColors
    .textSecondary,
),
),
),
],
),
),

const SizedBox(height: 14),

// ======================================================
// DISCOVERED DEVICES
// ======================================================

if (meshDevices.isNotEmpty)
Column(
children:
meshDevices.take(5).map(
(result) {
final device =
result.device;

final deviceName =
device.platformName
    .isNotEmpty
? device
    .platformName
    : 'BLE Node';

return Container(
margin:
const EdgeInsets.only(
bottom: 8,
),
padding:
const EdgeInsets.all(
12,
),
decoration:
BoxDecoration(
color: AppColors
    .background,
borderRadius:
BorderRadius.circular(
12,
),
border: Border.all(
color:
AppColors.border,
),
),
child: Row(
children: [
Container(
padding:
const EdgeInsets
    .all(8),
decoration:
BoxDecoration(
color: AppColors
    .primary
    .withOpacity(
0.10,
),
shape:
BoxShape.circle,
),
child:
const Icon(
Icons.bluetooth,
color: AppColors
    .primary,
size: 20,
),
),

const SizedBox(
width: 10,
),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
deviceName,
style:
const TextStyle(
fontWeight:
FontWeight
    .bold,
color: AppColors
    .textPrimary,
),
),

const SizedBox(
height: 3,
),

Text(
device.remoteId
    .toString(),
maxLines: 1,
overflow:
TextOverflow
    .ellipsis,
style:
const TextStyle(
fontSize: 10,
color: AppColors
    .textSecondary,
),
),
],
),
),

Column(
children: [
const Icon(
Icons
    .signal_cellular_alt,
size: 18,
color:
Colors.green,
),

const SizedBox(
height: 2,
),

Text(
'${result.rssi} dBm',
style:
const TextStyle(
fontSize: 10,
fontWeight:
FontWeight
    .w600,
color: AppColors
    .textSecondary,
),
),
],
),
],
),
);
},
).toList(),
)
else
Container(
width: double.infinity,
padding:
const EdgeInsets.symmetric(
vertical: 18,
),
child: const Column(
children: [
Icon(
Icons
    .bluetooth_disabled,
size: 32,
color: AppColors
    .textSecondary,
),

SizedBox(height: 8),

Text(
'No BLE nodes discovered yet',
style: TextStyle(
color: AppColors
    .textSecondary,
fontSize: 13,
),
),
],
),
),

const SizedBox(height: 12),

// ======================================================
// SCAN BUTTON
// ======================================================

SizedBox(
width: double.infinity,
child: ElevatedButton.icon(
onPressed: isMeshScanning
? stopMeshScan
    : startMeshScan,
icon: Icon(
isMeshScanning
? Icons
    .stop_circle_outlined
    : Icons
    .bluetooth_searching,
),
label: Text(
isMeshScanning
? 'Stop Scanning'
    : 'Scan for Nearby Nodes',
),
style:
ElevatedButton.styleFrom(
backgroundColor:
AppColors.primary,
foregroundColor:
Colors.white,
padding:
const EdgeInsets
    .symmetric(
vertical: 14,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
12,
),
),
),
),
),
],
),
);
}

// ============================================================
// QUICK ACTION CARD
// ============================================================

Widget actionCard(
IconData icon,
String title,
VoidCallback onTap,
) {
return InkWell(
onTap: onTap,
borderRadius:
BorderRadius.circular(20),
child: Container(
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: AppColors.border,
),
),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
icon,
color: AppColors.primary,
size: 38,
),

const SizedBox(height: 14),

Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 8,
),
child: Text(
title,
textAlign:
TextAlign.center,
style:
const TextStyle(
color:
AppColors.textPrimary,
fontWeight:
FontWeight.w600,
fontSize: 15,
),
),
),
],
),
),
);
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(
BuildContext context,
) {
return Scaffold(
backgroundColor:
AppColors.background,

// ========================================================
// APP BAR
// ========================================================

appBar: AppBar(
backgroundColor:
AppColors.background,
elevation: 0,
automaticallyImplyLeading:
false,
title: const Text(
'ConnectSafe',
style: TextStyle(
color:
AppColors.textPrimary,
fontWeight:
FontWeight.bold,
fontSize: 24,
),
),
actions: [
IconButton(
onPressed: () {
ScaffoldMessenger.of(
context,
).showSnackBar(
const SnackBar(
content: Text(
'Notifications coming soon.',
),
),
);
},
icon: const Icon(
Icons
    .notifications_none_rounded,
color:
AppColors.textPrimary,
),
),
],
),

// ========================================================
// BODY
// ========================================================

body: SafeArea(
child: SingleChildScrollView(
padding:
const EdgeInsets.all(20),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Hello 👋',
style: TextStyle(
fontSize: 30,
fontWeight:
FontWeight.bold,
color:
AppColors.textPrimary,
),
),

const SizedBox(height: 8),

const Text(
'Stay alert. Stay protected.',
style: TextStyle(
fontSize: 16,
color:
AppColors.textSecondary,
),
),

const SizedBox(height: 20),

// ==================================================
// SOS BUTTON
// ==================================================

Center(
child: InkWell(
borderRadius:
BorderRadius.circular(
150,
),
onTap:
isSendingEmergency
? null
    : handleSOS,
child: Container(
width: 210,
height: 210,
decoration:
BoxDecoration(
color:
AppColors.sos,
shape:
BoxShape.circle,
boxShadow: [
BoxShadow(
color: AppColors
    .sos
    .withOpacity(
0.35,
),
blurRadius: 35,
spreadRadius: 10,
),
],
),
child: Center(
child:
isSendingEmergency
? const CircularProgressIndicator(
color:
Colors.white,
strokeWidth:
5,
)
    : const Text(
'SOS',
style:
TextStyle(
color:
Colors.white,
fontSize:
50,
fontWeight:
FontWeight
    .bold,
),
),
),
),
),
),

const SizedBox(height: 35),

// ==================================================
// MESH NETWORK
// ==================================================

buildMeshNetworkCard(),

const SizedBox(height: 35),

// ==================================================
// QUICK ACTIONS
// ==================================================

const Text(
'Quick Actions',
style: TextStyle(
fontSize: 24,
fontWeight:
FontWeight.bold,
color:
AppColors.textPrimary,
),
),

const SizedBox(height: 18),

GridView.count(
crossAxisCount: 2,
crossAxisSpacing: 16,
mainAxisSpacing: 16,
childAspectRatio: 1.05,
physics:
const NeverScrollableScrollPhysics(),
shrinkWrap: true,
children: [
actionCard(
Icons.people_outline,
'Emergency Contacts',
() {
Navigator.pushNamed(
context,
'/contacts',
);
},
),

actionCard(
Icons.route_outlined,
'Safe Route',
() {
Navigator.pushNamed(
context,
'/safe-route',
);
},
),

actionCard(
Icons.location_on_outlined,
'Nearby Help',
() {
Navigator.pushNamed(
context,
'/nearby-help',
);
},
),

actionCard(
Icons.smart_toy_outlined,
'AI Assistant',
() {
Navigator.pushNamed(
context,
'/ai',
);
},
),

actionCard(
Icons.history,
'History',
() {
Navigator.pushNamed(
context,
'/history',
);
},
),

actionCard(
Icons.settings_outlined,
'Settings',
() {
Navigator.pushNamed(
context,
'/settings',
);
},
),
],
),
],
),
),
),

// ========================================================
// BOTTOM NAVIGATION
// ========================================================

bottomNavigationBar:
BottomNavigationBar(
currentIndex:
selectedIndex,
type:
BottomNavigationBarType.fixed,
selectedItemColor:
AppColors.primary,
unselectedItemColor:
AppColors.secondary,
onTap: (index) {
setState(() {
selectedIndex = index;
});

switch (index) {
case 0:
break;

case 1:
Navigator.pushNamed(
context,
'/nearby-help',
);
break;

case 2:
Navigator.pushNamed(
context,
'/ai',
);
break;

case 3:
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const EmergencyMessageScreen(
emergencyType:
'GENERAL',
incidentTitle: '',
),
),
);
break;
}
},
items: const [
BottomNavigationBarItem(
icon:
Icon(Icons.home),
label: 'Home',
),

BottomNavigationBarItem(
icon: Icon(
Icons.location_on_outlined,
),
label: 'Nearby',
),

BottomNavigationBarItem(
icon: Icon(
Icons.chat_outlined,
),
label: 'AI',
),

BottomNavigationBarItem(
icon: Icon(
Icons.person_outline,
),
label: 'Profile',
),
],
),
);
}
}

