import 'package:device_power/device_info.dart';
import 'package:device_power/my_gallery.dart';
import 'package:device_power/my_location.dart';
import 'package:flutter/material.dart';
import 'package:device_power/widgets/my_app_bar.dart';
import 'package:device_power/widgets/my_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, "Device Power"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Discover The App Features",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue),
          ),
          const SizedBox(height: 20),
          myButton("Show Device Info", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const DeviceInfo()));
          }),
          myButton("My Gallery", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MyGallery()));
          }),
          myButton("Get Your Location To Cairo", () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyLocation(
                        locationName: "Cairo",
                        latitude: 30.0444,
                        longitude: 31.2357)));
          }),
          myButton("Your Voice Matters (in-complete)", () {
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => const UsersFirebase()));
          }),
        ],
      ),
    );
  }
}
