
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';

class SafeRouteScreen extends StatefulWidget {
const SafeRouteScreen({super.key});

@override
State<SafeRouteScreen> createState() => _SafeRouteScreenState();
}

class _SafeRouteScreenState extends State<SafeRouteScreen> {
final TextEditingController destinationController =
TextEditingController();

final MapController mapController = MapController();

LatLng? currentLocation;
LatLng? destinationLocation;

List<LatLng> routePoints = [];

double? distanceKm;
double? durationMinutes;

bool isLoading = false;

@override
void dispose() {
destinationController.dispose();
super.dispose();
}

// =========================
// FIND SAFEST ROUTE
// =========================

Future<void> findRoute() async {
FocusScope.of(context).unfocus();

final address = destinationController.text.trim();

if (address.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("Please enter a destination."),
),
);
return;
}

setState(() {
isLoading = true;
routePoints = [];
distanceKm = null;
durationMinutes = null;
});

try {
// =========================
// GET CURRENT LOCATION
// =========================

final serviceEnabled =
await Geolocator.isLocationServiceEnabled();

if (!serviceEnabled) {
throw Exception(
'Please enable location services.',
);
}

LocationPermission permission =
await Geolocator.checkPermission();

if (permission == LocationPermission.denied) {
permission =
await Geolocator.requestPermission();
}

if (permission == LocationPermission.denied) {
throw Exception(
'Location permission denied.',
);
}

if (permission == LocationPermission.deniedForever) {
throw Exception(
'Location permission permanently denied.',
);
}

final position =
await Geolocator.getCurrentPosition(
locationSettings: const LocationSettings(
accuracy: LocationAccuracy.high,
),
);

final start = LatLng(
position.latitude,
position.longitude,
);

// =========================
// GEOCODE DESTINATION
// =========================

final locations =
await locationFromAddress(address);

if (locations.isEmpty) {
throw Exception(
'Destination not found.',
);
}

final destination = LatLng(
locations.first.latitude,
locations.first.longitude,
);

// =========================
// GET ROUTE FROM OSRM
// =========================

final route =
await getRoute(start, destination);

if (route.isEmpty) {
throw Exception(
'No route found.',
);
}

if (!mounted) return;

setState(() {
currentLocation = start;
destinationLocation = destination;
routePoints = route;
isLoading = false;
});

// Move map to route
mapController.fitCamera(
CameraFit.coordinates(
coordinates: [
start,
destination,
...route,
],
padding:
const EdgeInsets.all(50),
),
);

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Route found: '
'${distanceKm?.toStringAsFixed(1)} km',
),
backgroundColor: Colors.green,
),
);
} catch (e) {
if (!mounted) return;

setState(() {
isLoading = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Could not find route: $e',
),
backgroundColor: Colors.red,
),
);
}
}

// =========================
// OSRM ROUTING
// =========================

Future<List<LatLng>> getRoute(
LatLng start,
LatLng destination,
) async {
final url = Uri.parse(
'https://router.project-osrm.org/route/v1/driving/'
'${start.longitude},${start.latitude};'
'${destination.longitude},${destination.latitude}'
'?overview=full&geometries=geojson',
);

final response = await http.get(url);

if (response.statusCode != 200) {
throw Exception(
'Routing service unavailable.',
);
}

final data =
jsonDecode(response.body);

if (data['code'] != 'Ok') {
throw Exception(
'No route available.',
);
}

final route =
data['routes'][0];

final geometry =
route['geometry']['coordinates'];

final distance =
route['distance'] as num;

final duration =
route['duration'] as num;

final points = <LatLng>[];

for (final point in geometry) {
points.add(
LatLng(
(point[1] as num).toDouble(),
(point[0] as num).toDouble(),
),
);
}

setState(() {
distanceKm =
distance.toDouble() / 1000;

durationMinutes =
duration.toDouble() / 60;
});

return points;
}

// =========================
// MAP
// =========================

Widget buildMap() {
final initialCenter =
currentLocation ??
const LatLng(
12.9716,
77.5946,
);

return Container(
height: 350,
width: double.infinity,
decoration: BoxDecoration(
borderRadius:
BorderRadius.circular(18),
border: Border.all(
color: AppColors.border,
),
),
clipBehavior: Clip.antiAlias,
child: FlutterMap(
mapController: mapController,
options: MapOptions(
initialCenter: initialCenter,
initialZoom: 13,
),
children: [
TileLayer(
urlTemplate:
'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
userAgentPackageName:
'com.example.majorproject',
),

// ROUTE
if (routePoints.isNotEmpty)
PolylineLayer(
polylines: [
Polyline(
points: routePoints,
strokeWidth: 5,
color: AppColors.primary,
),
],
),

// MARKERS
MarkerLayer(
markers: [
if (currentLocation != null)
Marker(
point: currentLocation!,
width: 45,
height: 45,
child: const Icon(
Icons.my_location,
color: Colors.blue,
size: 35,
),
),

if (destinationLocation != null)
Marker(
point: destinationLocation!,
width: 45,
height: 45,
child: const Icon(
Icons.location_pin,
color: Colors.red,
size: 40,
),
),
],
),
],
),
);
}

// =========================
// ROUTE INFORMATION
// =========================

Widget buildRouteInfo() {
if (distanceKm == null ||
durationMinutes == null) {
return const SizedBox.shrink();
}

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
child: Padding(
padding:
const EdgeInsets.all(18),
child: Row(
children: [
Expanded(
child: Column(
children: [
const Icon(
Icons.route,
color:
AppColors.primary,
),
const SizedBox(height: 8),
const Text(
'Distance',
style: TextStyle(
fontSize: 12,
color:
AppColors.textSecondary,
),
),
const SizedBox(height: 4),
Text(
'${distanceKm!.toStringAsFixed(1)} km',
style:
const TextStyle(
fontWeight:
FontWeight.bold,
fontSize: 18,
color:
AppColors.textPrimary,
),
),
],
),
),

Container(
width: 1,
height: 55,
color: AppColors.border,
),

Expanded(
child: Column(
children: [
const Icon(
Icons.access_time,
color:
AppColors.primary,
),
const SizedBox(height: 8),
const Text(
'Estimated Time',
style: TextStyle(
fontSize: 12,
color:
AppColors.textSecondary,
),
),
const SizedBox(height: 4),
Text(
'${durationMinutes!.round()} min',
style:
const TextStyle(
fontWeight:
FontWeight.bold,
fontSize: 18,
color:
AppColors.textPrimary,
),
),
],
),
),
],
),
),
);
}

// =========================
// BUILD
// =========================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor:
AppColors.background,

appBar: AppBar(
elevation: 0,
centerTitle: true,
backgroundColor:
AppColors.background,
title: const Text(
"Safe Route",
style: TextStyle(
color:
AppColors.textPrimary,
fontWeight:
FontWeight.bold,
),
),
),

body: SingleChildScrollView(
padding:
const EdgeInsets.all(20),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
"Where are you going?",
style: TextStyle(
fontSize: 22,
fontWeight:
FontWeight.bold,
color:
AppColors.textPrimary,
),
),

const SizedBox(height: 18),

TextField(
controller:
destinationController,
textInputAction:
TextInputAction.search,
onSubmitted: (_) =>
findRoute(),
decoration:
InputDecoration(
hintText:
"Enter destination",
prefixIcon:
const Icon(
Icons.search,
),
filled: true,
fillColor:
Colors.white,
border:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
14,
),
borderSide:
const BorderSide(
color:
AppColors.border,
),
),
enabledBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
14,
),
borderSide:
const BorderSide(
color:
AppColors.border,
),
),
),
),

const SizedBox(height: 20),

buildMap(),

const SizedBox(height: 20),

buildRouteInfo(),

const SizedBox(height: 20),

Card(
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
child: const Padding(
padding:
EdgeInsets.all(18),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
"Route Safety",
style: TextStyle(
fontWeight:
FontWeight.bold,
fontSize: 18,
color:
AppColors
    .textPrimary,
),
),
SizedBox(
height: 12,
),
Row(
children: [
Icon(
Icons.shield,
color:
AppColors
    .success,
),
SizedBox(
width: 10,
),
Expanded(
child: Text(
"Safety analysis will be added using emergency and network data.",
),
),
],
),
],
),
),
),

const SizedBox(height: 25),

SizedBox(
width:
double.infinity,
height: 56,
child:
ElevatedButton.icon(
onPressed:
isLoading
? null
    : findRoute,
style:
ElevatedButton.styleFrom(
backgroundColor:
AppColors
    .primary,
foregroundColor:
Colors.white,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
14,
),
),
),
icon: isLoading
? const SizedBox(
width: 20,
height: 20,
child:
CircularProgressIndicator(
strokeWidth: 2,
color:
Colors.white,
),
)
    : const Icon(
Icons.route,
),
label: Text(
isLoading
? "Finding Route..."
    : "Find Safest Route",
style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.bold,
),
),
),
),
],
),
),
);
}
}

