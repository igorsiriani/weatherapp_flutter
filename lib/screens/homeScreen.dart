
import 'dart:developer';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget{
  HomePage createState()=> HomePage();
}

class HomePage extends State<HomeScreen> {
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
          Container(
            width: 4.0,
            padding: const EdgeInsets.all(20.0),
            margin: const EdgeInsets.fromLTRB(70.0, 70.0, 70.0, 15.0),
            decoration: BoxDecoration(
              color: const Color(0xFFD0E1F0),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _cloudIcon(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 15.0, 0.0, 0.0),
                  child: _temperature(),
                ),
                _description(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 10.0),
                  child: _minMax()
                ),
              ],
            ),
          ),
          _hourlyPrediction(),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: _navigation(),
          )
        ],
      ),
    );
  }

  _cloudIcon() {
    return Image(
      image: AssetImage('assets/images/$icon.png'),
      height: 75,
    );
  }

  _temperature() {
    return Text(
      '$temp°',
      style: TextStyle(
        fontSize: 55.0,
        color: Color(0xFF343434),
      ),
      textAlign: TextAlign.center,
    );
  }

  _description() {
    return Text(
      weather,
      style: TextStyle(
        fontSize: 20.0,
        color: Color(0xFF343434),
      ),
      textAlign: TextAlign.center,
    );
  }

  _minMax() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$min°',
          style: TextStyle(
            fontSize: 30.0,
            color: Color(0xFF343434),
          ),
          textAlign: TextAlign.center,
        ),
        new Spacer(),
        Text(
          '$max°',
          style: TextStyle(
            fontSize: 30.0,
            color: Color(0xFF343434),
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  _navigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 110.0,
          height: 50.0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: const Color(0xFF5F5980), // background
              onPrimary: Colors.white, // foreground
              shape: RoundedRectangleBorder( //to set border radius to button
                borderRadius: BorderRadius.circular(30)
              ),
            ),
            onPressed: () { 
              Navigator.pushNamed(context, '/tomorrow');
            },
            child: const Text('Tomorrow'),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 110.0,
          height: 50.0,
          child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: const Color(0xFF5F5980), // background
              onPrimary: Colors.white, // foreground
              shape: RoundedRectangleBorder( //to set border radius to button
                borderRadius: BorderRadius.circular(30)
              ),
            ),
            onPressed: () { 
              Navigator.pushNamed(context, '/nextDays');
            },
            child: const Text('7 Days'),
          ),
        )
      ],
    );
  }

  _hourlyPrediction() {
    
    return Container(
      height: 175.0,
      margin: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 20.0),
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20.0),
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          return Container(
              width: 120.0,
              child: Container(
                width: 120.0,
                padding: const EdgeInsets.all(20.0),
                margin: const EdgeInsets.only(right: 10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0E1F0),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: _cardTemp(list[index])
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: _cardCloudIcon(list[index]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: _cardTime(list[index])
                    ),
                  ],
                )
              ),
            );
        // return Text(list[index]);
      }),
    );
  }

  _cardTemp(forecast) {
    String cardTemp = forecast['temp'].round().toString();
    return Text(
      '$cardTemp°',
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
      height: 35,
    );
  }

  _cardTime(forecast) {
    var cardHour = forecast['dt'];

    DateTime now = DateTime.fromMillisecondsSinceEpoch(cardHour * 1000);
    DateFormat formatter = DateFormat('HH:mm');
    String formatted = formatter.format(now);

    return  Text(
      formatted,
      style: const TextStyle(
        fontSize: 20.0,
        color: Color(0xFF343434),
      ),
      textAlign: TextAlign.center,
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
      var weatherTemp = tempList['current']['weather'][0]['description'];

      weatherTemp = weatherTemp.split(' ').map((str) => "${str[0].toUpperCase()}${str.substring(1)}").join(' ');

      var tempHourly = tempList['hourly'].where((i) => isToday(i)).toList();

      setState(() => {
        temp = tempList['current']['temp'].round().toString(),
        weather = weatherTemp,
        icon = tempList['current']['weather'][0]['icon'].substring(0, 2 ),
        min = tempList['daily'][0]['temp']['min'].round().toString(),
        max = tempList['daily'][0]['temp']['max'].round().toString(),
        list = tempHourly
      });

    }
  }
}