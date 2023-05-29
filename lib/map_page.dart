import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_micro1/location_service.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapPage extends StatefulWidget {
  const MapPage({Key? key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  // ignore: unused_field

 Completer<GoogleMapController> _controller = Completer();
  TextEditingController _originController =TextEditingController();
  TextEditingController _destinationController =TextEditingController();
  Set<Marker> _markers= Set<Marker>();
  Set<Polyline> _polylines= Set<Polyline>();
  Set<Polygon> _polygons= Set<Polygon>();
  List <LatLng> polygonLatLngs =<LatLng>[];

int _polygonIdCounter =1;
int _polylineIdCounter =1;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  @override
  
  void initState() {
    super.initState();
     _setMarker(LatLng(37.42796133580664, -122.085749655962));
    
  }
   void _setMarker(LatLng point)
  {
     setState(()
     {
      _markers.add(
        Marker(markerId: MarkerId('marker'),
        position: point,
      ),);
     });
  }
  void _setPolygon()
  {
    final String polygonIdVal= 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;
    _polygons.add(Polygon(polygonId:PolygonId
    (
      polygonIdVal

    ),
    points:polygonLatLngs,
    strokeWidth: 2,
    fillColor: Colors.transparent,
    ),);
  }
  void _setPolyline(List<PointLatLng> points)
  {
     final String polylineIdVal= 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;
    _polylines.add(
      Polyline(
      polylineId: PolylineId(polylineIdVal),
      width: 2,
      color: Colors.blue,
      points: points.map(
        (point)=> LatLng(point.latitude,point.longitude),
      )
      .toList(),
    ),
    
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: 
      Text('Google Maps' ),
      ),
      body: Column(
      children:[
      Row(
        children:[
      Expanded(
      child:Column(
        children:[
        TextFormField(
        controller: _originController,
            decoration: InputDecoration(hintText: 'Origin'),
            onChanged: (value)
            {
               print(value);
            },
          ),
          TextFormField(
            controller: _destinationController,
            decoration: InputDecoration(hintText:'Destination'),
            onChanged: (value){
              print(value);
            },
          )
        ]
      )
    ),
        
          IconButton
          (onPressed: () async {
           var directions= await LocationService().getDirections(_originController.text,_destinationController.text);
          
          _goToPlace(directions['start_location']['lat'], directions['start_location']['lng']);
          _setPolyline(directions['polyline_decoded']);
          }, 
          icon: Icon(Icons.search),
         ),
   ]),
  Expanded(
  child: GoogleMap(
    mapType: MapType.normal,
    markers: _markers,
    polygons: _polygons,
    polylines: _polylines,
    initialCameraPosition: _kGooglePlex,
    onMapCreated: (GoogleMapController controller) {
      _controller.complete(controller);
    },
    onTap: (point)
    {
      setState((){
        polygonLatLngs.add(point);
        _setPolygon();
      });
    }
  ),
),
    
      ],
      ),
      
    );
    
  }
  Future<void> _goToPlace(
    //Map<String, dynamic>place,
    double lat,
    double lng,
  )async {
   // final double lat = place['geometry']['Location']['lat'];
   // final double lng = place['geometry']['Location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat, lng), zoom: 12))
      );
   _setMarker(LatLng(lat, lng));
  }
 
}
