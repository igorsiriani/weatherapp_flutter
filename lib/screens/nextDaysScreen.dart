import 'package:flutter/material.dart';

import 'dart:ui';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

import 'package:http/http.dart' as http;

class NextDaysScreen extends StatefulWidget{
  NextDaysPage createState()=> NextDaysPage();
}

class NextDaysPage extends State<NextDaysScreen> {
  bool started = false;
  String lat = '';
  String long = '';
  String temp = '--';
  String weather = ' ';
  String icon = '01';
  String min = '--';
  String max = '--';

  List list = [];

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    if (!started) {
      started = true;
      getLocation();
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 50.0, 0.0, 0.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  }, 
                  icon: const Icon(Icons.arrow_back, size: 40,)
                )
              ]
            )
          ),
          _daylyPrediction(),
        ],
      ),
    );
  }

  _daylyPrediction() {
    
    return Container(
      height: MediaQuery.of(context).size.height - 148,
      margin: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return Container(
              width: MediaQuery.of(context).size.height,
              child: Container(
                width: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(20.0),
                margin: const EdgeInsets.only(bottom: 10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0E1F0),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: _cardDay(list[index])
                    ),
                    new Spacer(),
                    _cardCloudIcon(list[index]),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: _cardMinMax(list[index])
                    ),
                  ],
                )
              ),
            );
        // return Text(list[index]);
      }),
    );
  }

  _cardDay(forecast) {
    var cardHour = forecast['dt'];
    String formatted = '';

    if (!isToday(forecast)) {
      DateTime testing = DateTime.fromMillisecondsSinceEpoch(cardHour * 1000);
      DateFormat formatter = DateFormat('EEEE');
      formatted = formatter.format(testing);
    } else {
      formatted = 'Today';
    }
    
    return Text(
      formatted,
      style: const TextStyle(
        fontSize: 25.0,
        color: Color(0xFF343434),
      ),
      textAlign: TextAlign.center,
    );
  }

  _cardCloudIcon(forecast) {
    String cardIcon = forecast['weather'][0]['icon'].substring(0, 2);
    return Image(
      image: AssetImage('assets/images/$cardIcon.png'),
      height: 45,
    );
  }

  _cardMinMax(forecast) {
    String min = forecast['temp']['min'].round().toString();
    String max = forecast['temp']['max'].round().toString();

    return Column(
      children: [
        Text(
          '$min°',
          style: const TextStyle(
            fontSize: 20.0,
            color: Color(0xFF343434),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '$max°',
          style: const TextStyle(
            fontSize: 20.0,
            color: Color(0xFF343434),
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    lat = _locationData.latitude.toString();
    long = _locationData.longitude.toString();

    getWeather();
  }

  bool isToday(time) {
    var cardHour = time['dt'];
    DateTime testing = DateTime.fromMillisecondsSinceEpoch(cardHour * 1000);

    DateTime now = DateTime.now();
    var res = DateTime(testing.year, testing.month, testing.day).difference(DateTime(now.year, now.month, now.day)).inDays;

    if (res == 0) {
      return true;
    } else {
      return false;
    }
  }

  getWeather() async {
    final response = await http.get(Uri.parse('http://api.openweathermap.org/data/2.5/onecall?units=metric&lat=$lat&lon=$long&APPID=e0d0ed6241a6e7bd2380a3cc396c6707'));

    if (response.statusCode == 200) {
      var tempList = jsonDecode(response.body);

      setState(() => {
        list = tempList['daily']
      });

    }
  }
}