import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wather_app_batch05/models/current_response_model.dart';
import 'package:wather_app_batch05/models/forecast_response_model.dart';
import 'package:wather_app_batch05/utils/constant.dart';
import 'package:geocoding/geocoding.dart' as Geo;

class WeatherProvider extends ChangeNotifier {
  CurrentResponseModel? currentResponseModel;
  ForecastResponseModel? forecastResponseModel;
  double latitude = 0.0, longitude = 0.0;
  String unit = 'metric';
  String unitSymbol = celsius;

  bool get hasDataLoaded => currentResponseModel != null && forecastResponseModel != null;
  bool get isFahenheit => unit == imperial;

  void setNewLocation(double lat, double long) {
    latitude = lat;
    longitude = long;
  }

  void setTempUnit(bool tag) {
    unit = tag ? imperial : metric;
    unitSymbol = tag ? fahrenheit : celsius;
    notifyListeners();
  }

  Future<bool> setPreferenceTempUnitValue(bool tag) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setBool('unit', tag);
  }

  Future<bool> getPreferenceTempUnitValue() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool('unit') ?? false;
  }

  getWeatherData() {
    _getCurrentData();
    _getForecastData();
  }


  void convertAddresstoLatLong(String result) async {
    try {
      final locationList = await Geo.locationFromAddress(result);
      if(locationList.isNotEmpty) {
        final location = locationList.first;
        setNewLocation(location.latitude, location.longitude);
        getWeatherData();
      }
      else {
        print('City not found');
      }

    }catch(error){
      print(error.toString());
      //easy loading
    }
  }

  void _getCurrentData() async {
    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$unit&appid=$weatherApiKey');
    try {
      final response = await get(uri);
      final map = jsonDecode(response.body);
      if(response.statusCode == 200){
        currentResponseModel = CurrentResponseModel.fromJson(map);
        print(currentResponseModel!.main!.temp!.round());
        notifyListeners();
      }
      else {
        print(map['message']);
      }
    }catch(error) {
      rethrow;
    }
  }

  void _getForecastData() async {
    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=$unit&appid=$weatherApiKey');
    try {
      final response = await get(uri);
      final map = jsonDecode(response.body);
      if(response.statusCode == 200){
        forecastResponseModel = ForecastResponseModel.fromJson(map);
        print(forecastResponseModel!.list!.length);
        notifyListeners();
      }
      else {
        print(map['message']);
      }
    }catch(error) {
      rethrow;
    }
  }

  void _getForecastDataToday() async {
    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=$unit&appid=$weatherApiKey');
    try {
      final response = await get(uri);
      final map = jsonDecode(response.body);
      if(response.statusCode == 200){
        forecastResponseModel = ForecastResponseModel.fromJson(map);
        print(forecastResponseModel!.list!.length);
        notifyListeners();
      }
      else {
        print(map['message']);
      }
    }catch(error) {
      rethrow;
    }
  }


}
















