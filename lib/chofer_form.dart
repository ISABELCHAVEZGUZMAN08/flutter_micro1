import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:azure_cosmosdb/azure_cosmosdb_debug.dart';


class DriverLogin extends StatefulWidget {
  const DriverLogin({Key? key}) : super(key: key);

  @override
  _DriverLoginState createState() => _DriverLoginState();
}

class _DriverLoginState extends State<DriverLogin> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<bool> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Configura la conexión a la base de datos de Cosmos DB
    final cosmosDb = AzureCosmosDB(
      'tu_endpoint',
      'tu_clave',
      'tu_nombre_base_datos',
    );

    // Busca el chofer en la base de datos por usuario y contraseña
    final query = QueryBuilder()
        .from('choferes')
        .where('usuario', '=', username)
        .andWhere('contrasena', '=', password)
        .limit(1)
        .build();

    final result = await cosmosDb.query(query);

    if (result.isSuccessful && result.documents.isNotEmpty) {
      return true; // Credenciales válidas
    } else {
      return false; // Credenciales inválidas
    }
  }

  void _handleLogin() async {
    bool isAuthenticated = await _login();

    if (isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DriverInterface(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error de inicio de sesión'),
          content: Text('Usuario o contraseña incorrectos.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de sesión del chofer'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _handleLogin,
              child: Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }


class DriverInterface extends StatefulWidget {
  const DriverInterface({Key? key}) : super(key: key);

  @override
  _DriverInterfaceState createState() => _DriverInterfaceState();
}

class _DriverInterfaceState extends State<DriverInterface> {
  LatLng _currentLocation = LatLng(0, 0);
  Marker _driverMarker = Marker(markerId: MarkerId('driver'));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chofer'),
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
              markers: {
                _driverMarker,
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _getCurrentLocation();
              },
              child: Text('Actualizar ubicación'),
            ),
          ),
          Text('Hora de salida: ${DateTime.now().toString()}'),
        ],
      ),
    );
  }
}

