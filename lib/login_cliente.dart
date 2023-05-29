import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClientInterface extends StatefulWidget {
  const ClientInterface({Key? key}) : super(key: key);

  @override
  _ClientInterfaceState createState() => _ClientInterfaceState();
}

class _ClientInterfaceState extends State<ClientInterface> {
  TextEditingController _destinationController = TextEditingController();
  LatLng _currentLocation = LatLng(0, 0);
  List<LatLng> _microLocations = [
    LatLng(37.12345, -122.54321), // Ejemplo de ubicación de micros
    LatLng(37.56789, -122.98765),
    LatLng(37.24680, -122.13579),
  ];
  Set<Marker> _markers = {};
  LatLng _destinationLocation = LatLng(0, 0);
  Marker _destinationMarker = Marker(markerId: MarkerId('destination'));
  double _distanceToDestination = 0.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<LatLng> geocodeAddress(String address) async {
    final apiKey = 'AIzaSyDCDQOp7_Fov2CQ2y1CcBCke83XXsX6YHY'; // Reemplaza con tu clave de API de Geocodificación
    final encodedAddress = Uri.encodeQueryComponent(address);
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final location = result['results'][0]['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        return LatLng(lat, lng);
      }
    }

    return LatLng(0, 0); // Devuelve una ubicación vacía si la solicitud falla o no se encuentra la dirección
  }

  void _showMicrosOnMap() {
    setState(() {
      _markers.clear();

      // Agrega los marcadores de los micros que van hacia el destino
      for (int i = 0; i < _microLocations.length; i++) {
        LatLng microLocation = _microLocations[i];
        double distance = Geolocator.distanceBetween(
          microLocation.latitude,
          microLocation.longitude,
          _destinationLocation.latitude,
          _destinationLocation.longitude,
        );

        // Umbral de distancia para mostrar los micros que van hacia el destino
        double distanceThreshold = 500.0; // Puedes ajustar este valor según tus necesidades

        if (distance < distanceThreshold) {
          _markers.add(
            Marker(
              markerId: MarkerId('micro_$i'),
              position: microLocation,
              infoWindow: InfoWindow(
                title: 'Micro $i',
                snippet: 'Ubicación del micro',
              ),
            ),
          );
        }
      }

      // Agrega el marcador del destino si se ha proporcionado una ubicación válida
      if (_destinationLocation.latitude != 0 && _destinationLocation.longitude != 0) {
        _markers.add(
          Marker(
            markerId: _destinationMarker.markerId,
            position: _destinationLocation,
            infoWindow: InfoWindow(
              title: 'Destino',
              snippet: 'Ubicación de destino',
            ),
          ),
        );
      }

      // Calcula la distancia entre la ubicación actual y el destino
      _distanceToDestination = Geolocator.distanceBetween(
        _currentLocation.latitude,
        _currentLocation.longitude,
        _destinationLocation.latitude,
        _destinationLocation.longitude,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cliente'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              onMapCreated: (controller) {},
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 14.0,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    labelText: 'Destino',
                    hintText: 'Ingrese su destino',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () async {
                        String destinationText = _destinationController.text;
                        LatLng destinationLocation = await geocodeAddress(destinationText);
                        setState(() {
                          _destinationLocation = destinationLocation;
                        });
                        _showMicrosOnMap();
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String destinationText = _destinationController.text;
                    LatLng destinationLocation = await geocodeAddress(destinationText);
                    setState(() {
                      _destinationLocation = destinationLocation;
                    });
                    _showMicrosOnMap();
                  },
                  child: Text('Mostrar micros'),
                ),
                Text('Distancia al destino: $_distanceToDestination metros'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
