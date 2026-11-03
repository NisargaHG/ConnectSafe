
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';

class NearbyHelpScreen extends StatefulWidget {
const NearbyHelpScreen({super.key});

@override
State<NearbyHelpScreen> createState() => _NearbyHelpScreenState();
}

class _NearbyHelpScreenState extends State<NearbyHelpScreen> {
Position? currentPosition;
bool isLoading = false;

Future<bool> _checkLocationPermission() async {
final serviceEnabled =
await Geolocator.isLocationServiceEnabled();

if (!serviceEnabled) {
if (!mounted) return false;

await showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text('Location Required'),
content: const Text(
'Please enable location services to find nearby help.',
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('OK'),
),
],
),
);

return false;
}

LocationPermission permission =
await Geolocator.checkPermission();

if (permission == LocationPermission.denied) {
permission = await Geolocator.requestPermission();
}

if (permission == LocationPermission.denied ||
permission == LocationPermission.deniedForever) {
if (!mounted) return false;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Location permission is required to find nearby help.',
),
),
);

return false;
}

return true;
}

Future<void> _findLocation() async {
setState(() {
isLoading = true;
});

try {
final hasPermission =
await _checkLocationPermission();

if (!hasPermission) {
if (mounted) {
setState(() {
isLoading = false;
});
}
return;
}

final position =
await Geolocator.getCurrentPosition(
locationSettings: const LocationSettings(
accuracy: LocationAccuracy.high,
),
);

if (!mounted) return;

setState(() {
currentPosition = position;
isLoading = false;
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Your location has been found.'),
),
);
} catch (e) {
debugPrint(
'NEARBY HELP LOCATION ERROR: $e',
);

if (!mounted) return;

setState(() {
isLoading = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Unable to get your location: $e',
),
),
);
}
}

Future<void> _openNearbySearch(
String searchTerm,
) async {
// Get location if we don't already have it.
if (currentPosition == null) {
await _findLocation();

if (currentPosition == null) {
return;
}
}

final latitude = currentPosition!.latitude;
final longitude = currentPosition!.longitude;

final encodedQuery =
Uri.encodeComponent(searchTerm);

// Google Maps web search.
final mapsUrl = Uri.parse(
'https://www.google.com/maps/search/'
'?api=1'
'&query=$encodedQuery'
'&center=$latitude,$longitude',
);

try {
final launched = await launchUrl(
mapsUrl,
mode: LaunchMode.externalApplication,
);

if (!launched) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Could not open Maps or browser.',
),
),
);
}
} catch (e) {
debugPrint('MAP OPEN ERROR: $e');

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Unable to open Maps.',
),
),
);
}
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
'Nearby Help',
style: TextStyle(
color: AppColors.textPrimary,
fontWeight: FontWeight.bold,
),
),
),

body: SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
children: [
// LOCATION
Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius:
BorderRadius.circular(18),
border: Border.all(
color: AppColors.border,
),
),
child: Row(
children: [
CircleAvatar(
backgroundColor:
AppColors.primary
    .withOpacity(0.12),
child: const Icon(
Icons.my_location,
color: AppColors.primary,
),
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Your Location',
style: TextStyle(
fontWeight: FontWeight.bold,
color:
AppColors.textPrimary,
),
),
const SizedBox(height: 5),
Text(
currentPosition == null
? 'Location not detected'
    : '${currentPosition!.latitude.toStringAsFixed(5)}, '
'${currentPosition!.longitude.toStringAsFixed(5)}',
style: const TextStyle(
fontSize: 12,
color:
AppColors.textSecondary,
),
),
],
),
),

if (currentPosition != null)
const Icon(
Icons.check_circle,
color: AppColors.success,
),
],
),
),

const SizedBox(height: 20),

// MAP STATUS
Container(
height: 180,
width: double.infinity,
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius:
BorderRadius.circular(18),
border: Border.all(
color: AppColors.border,
),
),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
currentPosition == null
? Icons.location_searching
    : Icons.map_rounded,
size: 55,
color: AppColors.primary,
),

const SizedBox(height: 12),

Text(
currentPosition == null
? 'Find your location'
    : 'Nearby help is ready',
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color:
AppColors.textPrimary,
),
),

const SizedBox(height: 6),

Text(
currentPosition == null
? 'Tap the button below to locate you'
    : 'Select a category to find nearby services',
textAlign: TextAlign.center,
style: const TextStyle(
color:
AppColors.textSecondary,
),
),
],
),
),

const SizedBox(height: 25),

// HOSPITALS
_helpCard(
icon: Icons.local_hospital_rounded,
title: 'Hospitals',
subtitle:
'Find nearby hospitals and emergency care',
color: AppColors.success,
onTap: () {
_openNearbySearch(
'hospitals near me',
);
},
),

const SizedBox(height: 14),

// POLICE
_helpCard(
icon: Icons.local_police_rounded,
title: 'Police Stations',
subtitle:
'Locate the nearest police stations',
color: AppColors.accent,
onTap: () {
_openNearbySearch(
'police stations near me',
);
},
),

const SizedBox(height: 14),

// FIRE
_helpCard(
icon:
Icons.local_fire_department_rounded,
title: 'Fire & Rescue',
subtitle:
'Find nearby fire and rescue services',
color: AppColors.sos,
onTap: () {
_openNearbySearch(
'fire stations near me',
);
},
),

const SizedBox(height: 14),

// SAFE PLACES
_helpCard(
icon: Icons.security_rounded,
title: 'Safe Places',
subtitle:
'Find nearby safe public places',
color: AppColors.warning,
onTap: () {
_openNearbySearch(
'safe places near me',
);
},
),

const SizedBox(height: 30),

// FIND LOCATION BUTTON
SizedBox(
width: double.infinity,
height: 56,
child: ElevatedButton.icon(
onPressed:
isLoading ? null : _findLocation,
style: ElevatedButton.styleFrom(
backgroundColor:
AppColors.primary,
foregroundColor: Colors.white,
disabledBackgroundColor:
AppColors.primary
    .withOpacity(0.5),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(14),
),
),
icon: isLoading
? const SizedBox(
width: 20,
height: 20,
child:
CircularProgressIndicator(
strokeWidth: 2,
color: Colors.white,
),
)
    : const Icon(
Icons.my_location,
),
label: Text(
isLoading
? 'Finding Location...'
    : 'Find Nearby Help',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
),
),

const SizedBox(height: 15),

const Text(
'Nearby locations will open in your Maps or browser application.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 12,
color:
AppColors.textSecondary,
),
),
],
),
),
);
}

Widget _helpCard({
required IconData icon,
required String title,
required String subtitle,
required Color color,
required VoidCallback onTap,
}) {
return Card(
elevation: 0,
color: AppColors.surface,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(16),
side: const BorderSide(
color: AppColors.border,
),
),
child: InkWell(
borderRadius:
BorderRadius.circular(16),
onTap: onTap,
child: ListTile(
contentPadding:
const EdgeInsets.symmetric(
horizontal: 16,
vertical: 5,
),

leading: CircleAvatar(
backgroundColor:
color.withOpacity(0.15),
child: Icon(
icon,
color: color,
),
),

title: Text(
title,
style: const TextStyle(
fontWeight: FontWeight.bold,
color:
AppColors.textPrimary,
),
),

subtitle: Text(subtitle),

trailing: const Icon(
Icons.chevron_right_rounded,
),
),
),
);
}
}

