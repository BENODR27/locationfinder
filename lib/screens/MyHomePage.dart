import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  Position? _currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;
  String currentAddress = "";
  Future<Position> getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if(!servicePermission){
      print("denied");
    }
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }
  getAddressFromCoordinates() async{
    try{
      List<Placemark> placemarks = await placemarkFromCoordinates(_currentLocation!.latitude, _currentLocation!.longitude);
      Placemark place = placemarks[0];
      setState(() {
        currentAddress = "${place.locality},${place.country}";
      });
    }catch(e){
      if (kDebugMode) {
        print(e);
      }
    }

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.search))
        ],
      ),
      drawer: const Drawer(),
      body: _currentLocation!=null ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Latitude:${_currentLocation?.latitude}"),

            Text("Longitude:${_currentLocation?.longitude}"),
            Text(
              "Your Current Address $currentAddress",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ): Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() async{
            _currentLocation = await getCurrentLocation();
            await getAddressFromCoordinates();
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.location_on_rounded),
      ),
    );
  }
}
