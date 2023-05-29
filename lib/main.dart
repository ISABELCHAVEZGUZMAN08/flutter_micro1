
import 'package:flutter/material.dart';
import 'package:flutter_micro1/chofer_form.dart';
import 'package:flutter_micro1/login_cliente.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      routes: {
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}
class MicrobusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar el camino
    Paint pathPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    Path path = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width, size.height * 0.7);

    canvas.drawPath(path, pathPaint);

    // Dibujar el microbús
    Paint busPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    double busSize = 40.0;
    double busX = size.width * 0.1; // Posición inicial del microbús
    double busY = size.height * 0.68;

    canvas.drawRect(Rect.fromLTWH(busX, busY, busSize, busSize), busPaint);

    // Dibujar el GPS
    Paint gpsPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    double gpsSize = 12.0;
    double gpsX = busX + busSize / 2 - gpsSize / 2;
    double gpsY = busY - gpsSize * 1.5;

    canvas.drawCircle(Offset(gpsX, gpsY), gpsSize, gpsPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bustracer'),
      ),
      body: Container(
        color: Colors.white, // Cambia el color de fondo a blanco
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Bienvenido a Bustracer',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Column(
              children: [
                Image.asset('assets/images/robot.gif'), // Ruta del primer GIF local en el proyecto
                 SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: CustomPaint(
                  painter: MicrobusPainter(),
                  ))
              ],
            ),
            const SizedBox(height: 20), // Espacio después del segundo GIF
            ElevatedButton(
              child: const Text('Ingresar'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Registrarse como:'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            child: const Text('Pasajero'),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/register',
                                  arguments: 'pasajero');
                              Navigator.push(
                               context,
                                MaterialPageRoute(builder: (context) => const ClientInterface()),
                              );
                            },
                          ),
                          
                           ElevatedButton(
                            child: const Text('Chofer'),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/register',
                                  arguments: 'chofer');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const DriverLogin()),
                              );
                            }
                           ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String userType =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Registrarse como $userType',
              style: const TextStyle(fontSize: 20.0),
            ),
            // Aquí puedes agregar los campos de registro específicos para pasajeros y conductores
          ],
        ),
      ),
    );
  }
}

