import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  final LatLng _initialPosition =
      const LatLng(31.033549911189926, 31.35610440380582);
  LatLng? _currentPosition;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _locationPermissionGranted = true;
    } else {
      _locationPermissionGranted = false;
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_locationPermissionGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController?.animateCamera(CameraUpdate.newLatLng(_initialPosition));
  }

  Future<void> _showPharmacyDetails(
      BuildContext context,
      String name,
      String description,
      String status,
      LatLng position,
      String openTime,
      String closeTime,
      List<String> images) async {
    Position currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double distance = Geolocator.distanceBetween(currentLocation.latitude,
            currentLocation.longitude, position.latitude, position.longitude) /
        1000;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(description),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('حالة الصيدلية: '),
                  Text(status, style: const TextStyle(color: Colors.green)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('ساعات العمل: '),
                  Text('من $openTime إلى $closeTime'),
                ],
              ),
              const SizedBox(height: 8),
              Text('المسافة: ${distance.toStringAsFixed(2)} كيلومتر'),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return _buildPharmacyImage(images[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPharmacyImage(String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Image.asset(
        imagePath,
        width: 200,
        height: 100,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Marker> pharmacyMarkers = [
      Marker(
        markerId: const MarkerId('pharmacy1'),
        position: const LatLng(31.041418178050566, 31.36112030703073),
        infoWindow: const InfoWindow(title: 'صيدليه الطرشوبي'),
        onTap: () => _showPharmacyDetails(
          context,
          'صيدليه الطرشوبي',
          'نسعى لخدمة جميع عملائنا وتلبيه احتياجاتهم تحت شعار ✔️التميز هدفنا ✔️والأمانة',
          'مفتوح',
          const LatLng(31.041418178050566, 31.36112030703073),
          '12:00 صباحًا',
          '11:00 مساءً',
          [
            'assets/image/trspy1.jpg',
            'assets/image/trshpy2.jpg',
            'assets/image/trspy3.jpg'
          ],
        ),
      ),
      Marker(
        markerId: const MarkerId('pharmacy2'),
        position: const LatLng(31.035977228918487, 31.35871087469734),
        infoWindow: const InfoWindow(title: 'صيدلية العزبي'),
        onTap: () => _showPharmacyDetails(
          context,
          'صيدلية العزبي',
          'صيدليات العزبي دايما جنبك و حواليك',
          'مفتوح',
          const LatLng(31.0420, 31.3790),
          '8:00 صباحًا',
          '12:30 صباحًا',
          [
            'assets/image/azby1.jpg',
            'assets/image/azby2.jpeg',
            'assets/image/azby3.jpeg'
          ],
        ),
      ),
    ];

    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 15.0,
        ),
        markers: Set.from(pharmacyMarkers),
      ),
    );
  }
}
