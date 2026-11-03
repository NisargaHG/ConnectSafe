
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/emergency_message_service.dart';

class HistoryScreen extends StatefulWidget {
const HistoryScreen({super.key});

@override
State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
List<Map<String, dynamic>> messages = [];
bool isLoading = true;
String? errorMessage;

@override
void initState() {
super.initState();
loadHistory();
}

Future<void> loadHistory() async {
setState(() {
isLoading = true;
errorMessage = null;
});

try {
final result =
await EmergencyMessageService.instance.getMessages();

if (!mounted) return;

setState(() {
messages = result
    .map((item) => Map<String, dynamic>.from(item))
    .toList();

isLoading = false;
});

debugPrint('HISTORY: $messages');
} catch (e) {
debugPrint('HISTORY LOAD FAILED: $e');

if (!mounted) return;

setState(() {
isLoading = false;
errorMessage = e.toString();
});
}
}

IconData getEmergencyIcon(String type) {
switch (type.toUpperCase()) {
case 'FIRE':
return Icons.local_fire_department_rounded;
case 'FLOOD':
return Icons.water_rounded;
case 'ACCIDENT':
return Icons.car_crash_rounded;
case 'MEDICAL':
return Icons.medical_services_rounded;
case 'EARTHQUAKE':
return Icons.public_rounded;
case 'CYCLONE':
return Icons.air_rounded;
case 'LANDSLIDE':
return Icons.terrain_rounded;
case 'PERSONAL SAFETY':
case 'PERSONAL_SAFETY':
return Icons.shield_rounded;
default:
return Icons.warning_rounded;
}
}

Color getPriorityColor(String priority) {
switch (priority.toUpperCase()) {
case 'HIGH':
return AppColors.sos;
case 'MEDIUM':
return Colors.orange;
case 'LOW':
return Colors.green;
default:
return AppColors.primary;
}
}

String formatEmergencyType(String? type) {
if (type == null || type.isEmpty) {
return 'EMERGENCY';
}

return type
    .replaceAll('_', ' ')
    .toUpperCase();
}

String formatDate(String? date) {
if (date == null || date.isEmpty) {
return 'Unknown date';
}

try {
final parsedDate = DateTime.parse(date).toLocal();

final hour = parsedDate.hour == 0
? 12
    : parsedDate.hour > 12
? parsedDate.hour - 12
    : parsedDate.hour;

final period = parsedDate.hour >= 12 ? 'PM' : 'AM';

return '${parsedDate.day.toString().padLeft(2, '0')} '
'${_monthName(parsedDate.month)} '
'${parsedDate.year}, '
'$hour:${parsedDate.minute.toString().padLeft(2, '0')} $period';
} catch (_) {
return date;
}
}

String _monthName(int month) {
const months = [
'',
'Jan',
'Feb',
'Mar',
'Apr',
'May',
'Jun',
'Jul',
'Aug',
'Sep',
'Oct',
'Nov',
'Dec',
];

return months[month];
}

String formatLocation(dynamic latitude, dynamic longitude) {
if (latitude == null || longitude == null) {
return 'Location unavailable';
}

return '${latitude.toString()}, ${longitude.toString()}';
}

void showEmergencyDetails(Map<String, dynamic> item) {
final type =
formatEmergencyType(item['emergency_type']?.toString());

final priority =
item['priority']?.toString() ?? 'MEDIUM';

final message =
item['message']?.toString() ?? 'No message';

final latitude = item['latitude'];
final longitude = item['longitude'];

final createdAt =
item['created_at']?.toString();

final contacts = item['contacts'];

showModalBottomSheet(
context: context,
backgroundColor: AppColors.background,
isScrollControlled: true,
shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(
top: Radius.circular(24),
),
),
builder: (context) {
return SafeArea(
child: Padding(
padding: const EdgeInsets.fromLTRB(
24,
20,
24,
30,
),
child: SingleChildScrollView(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Center(
child: Container(
width: 45,
height: 5,
decoration: BoxDecoration(
color: AppColors.border,
borderRadius:
BorderRadius.circular(10),
),
),
),

const SizedBox(height: 24),

const Text(
'Emergency Details',
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
color: AppColors.textPrimary,
),
),

const SizedBox(height: 24),

_detailRow(
Icons.warning_rounded,
'Type',
type,
),

_detailRow(
Icons.priority_high_rounded,
'Priority',
priority,
),

_detailRow(
Icons.location_on_rounded,
'Location',
formatLocation(
latitude,
longitude,
),
),

_detailRow(
Icons.access_time_rounded,
'Date',
formatDate(createdAt),
),

_detailRow(
Icons.message_rounded,
'Message',
message,
),

if (contacts != null)
_detailRow(
Icons.contacts_rounded,
'Contacts',
contacts.toString(),
),

const SizedBox(height: 20),

SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () {
Navigator.pop(context);
},
style: ElevatedButton.styleFrom(
backgroundColor:
AppColors.primary,
foregroundColor: Colors.white,
padding:
const EdgeInsets.symmetric(
vertical: 14,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(12),
),
),
child: const Text(
'Close',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),
),
],
),
),
),
);
},
);
}

Widget _detailRow(
IconData icon,
String label,
String value,
) {
return Padding(
padding: const EdgeInsets.only(bottom: 18),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(
icon,
color: AppColors.primary,
size: 22,
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
label,
style: const TextStyle(
fontSize: 12,
color: AppColors.textSecondary,
),
),
const SizedBox(height: 3),
Text(
value,
style: const TextStyle(
fontSize: 15,
fontWeight: FontWeight.w600,
color: AppColors.textPrimary,
),
),
],
),
),
],
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,

appBar: AppBar(
backgroundColor: AppColors.background,
elevation: 0,
centerTitle: true,
title: const Text(
'Emergency History',
style: TextStyle(
color: AppColors.textPrimary,
fontWeight: FontWeight.bold,
),
),
),

body: isLoading
? const Center(
child: CircularProgressIndicator(),
)
    : errorMessage != null
? Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
const Icon(
Icons.error_outline_rounded,
size: 50,
color: AppColors.sos,
),
const SizedBox(height: 16),
const Text(
'Failed to load history',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: AppColors.textPrimary,
),
),
const SizedBox(height: 8),
Text(
errorMessage!,
textAlign: TextAlign.center,
style: const TextStyle(
color: AppColors.textSecondary,
),
),
const SizedBox(height: 20),
ElevatedButton(
onPressed: loadHistory,
child: const Text('Retry'),
),
],
),
),
)
    : messages.isEmpty
? RefreshIndicator(
onRefresh: loadHistory,
child: ListView(
children: const [
SizedBox(height: 220),
Center(
child: Text(
'No Emergency History',
style: TextStyle(
fontSize: 18,
color:
AppColors.textSecondary,
),
),
),
],
),
)
    : RefreshIndicator(
onRefresh: loadHistory,
child: ListView.builder(
padding:
const EdgeInsets.all(20),
itemCount: messages.length,
itemBuilder:
(context, index) {
final item =
messages[index];

final type =
formatEmergencyType(
item['emergency_type']
    ?.toString(),
);

final priority =
item['priority']
    ?.toString() ??
'MEDIUM';

final message =
item['message']
    ?.toString() ??
'Emergency';

final createdAt =
item['created_at']
    ?.toString();

final latitude =
item['latitude'];

final longitude =
item['longitude'];

final priorityColor =
getPriorityColor(
priority,
);

return Card(
margin:
const EdgeInsets.only(
bottom: 16,
),
elevation: 0,
color: AppColors.surface,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
16,
),
side:
const BorderSide(
color:
AppColors.border,
),
),
child: InkWell(
borderRadius:
BorderRadius.circular(
16,
),
onTap: () =>
showEmergencyDetails(
item,
),
child: Padding(
padding:
const EdgeInsets.all(
16,
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
CircleAvatar(
radius: 25,
backgroundColor:
priorityColor
    .withOpacity(
0.12,
),
child: Icon(
getEmergencyIcon(
type,
),
color:
priorityColor,
size: 26,
),
),

const SizedBox(
width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Row(
children: [
Expanded(
child:
Text(
type,
style:
const TextStyle(
fontSize:
16,
fontWeight:
FontWeight.bold,
color:
AppColors.textPrimary,
),
),
),

Container(
padding:
const EdgeInsets
    .symmetric(
horizontal:
8,
vertical:
4,
),
decoration:
BoxDecoration(
color:
priorityColor.withOpacity(
0.12,
),
borderRadius:
BorderRadius.circular(
8,
),
),
child:
Text(
priority,
style:
TextStyle(
fontSize:
11,
fontWeight:
FontWeight.bold,
color:
priorityColor,
),
),
),
],
),

const SizedBox(
height: 8),

Text(
message,
maxLines: 2,
overflow:
TextOverflow
    .ellipsis,
style:
const TextStyle(
color:
AppColors.textSecondary,
),
),

const SizedBox(
height: 8),

Row(
children: [
const Icon(
Icons
    .location_on_outlined,
size: 15,
color:
AppColors.textSecondary,
),
const SizedBox(
width: 4),
Expanded(
child:
Text(
formatLocation(
latitude,
longitude,
),
maxLines:
1,
overflow:
TextOverflow
    .ellipsis,
style:
const TextStyle(
fontSize:
12,
color:
AppColors.textSecondary,
),
),
),
],
),

const SizedBox(
height: 4),

Row(
children: [
const Icon(
Icons
    .access_time_outlined,
size: 15,
color:
AppColors.textSecondary,
),
const SizedBox(
width: 4),
Text(
formatDate(
createdAt,
),
style:
const TextStyle(
fontSize:
12,
color:
AppColors.textSecondary,
),
),
],
),
],
),
),

const SizedBox(
width: 4),

const Icon(
Icons
    .chevron_right_rounded,
color: AppColors
    .textSecondary,
),
],
),
),
),
);
},
),
),
);
}
}

