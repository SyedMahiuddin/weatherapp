import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:wather_app_batch05/models/forecast_response_model.dart';
import 'package:wather_app_batch05/pages/settings_page.dart';
import 'package:wather_app_batch05/utils/helper_function.dart';
import 'package:wather_app_batch05/providers/weather_provider.dart';
import 'package:wather_app_batch05/utils/constant.dart';
import 'package:wather_app_batch05/utils/location_utils.dart';
import 'package:wather_app_batch05/utils/txt_style.dart';

class WeatherPage extends StatefulWidget {
  static const String routeName = '/';

  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late WeatherProvider weatherProvider;
  bool isFirst = true;

  @override
  void didChangeDependencies() {
    if (isFirst) {
      weatherProvider = Provider.of<WeatherProvider>(context);
      _getData();
      isFirst = false;
    }
    super.didChangeDependencies();
  }

  _getData() async {
    try {
      final position = await determinePosition();
      weatherProvider.setNewLocation(position.latitude, position.longitude);
      weatherProvider
          .setTempUnit(await weatherProvider.getPreferenceTempUnitValue());
      weatherProvider.getWeatherData();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Weather'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                _getData();
              },
              icon: Icon(Icons.my_location, color: Colors.white,)),
          IconButton(
              onPressed: () async {
                final result = await showSearch(
                  context: context,
                  delegate: _CitySearchDelegate(),
                );
                if (result != null && result.isNotEmpty) {
                  weatherProvider.convertAddresstoLatLong(result);
                }
              },
              icon: Icon(Icons.search, color: Colors.white,)),
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, SettingsPage.routeName);
              },
              icon: Icon(Icons.settings, color: Colors.white,)),
        ],
      ),
      body: Center(
        child: weatherProvider.hasDataLoaded
            ? ListView(
              padding: EdgeInsets.all(8.0),
              children: [
                // _currentWeatherSection(),
                _currentWeatherSection2(),
                SizedBox(
                  height: 20,
                ),
                // _forecastWeatherSection(),
              ],
            )
            : Container(
          height: 70,
          width: 70,
          child: LoadingIndicator(
              indicatorType: Indicator.lineScalePulseOut, /// Required, The loading type of the widget
              colors: const [Colors.deepOrange, Colors.blue, Colors.amber, Colors.cyanAccent],       /// Optional, The color collections
              strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
              backgroundColor: Colors.black,      /// Optional, Background of the widget
              pathBackgroundColor: Colors.blue   /// Optional, the stroke backgroundColor
          ),
        )
      ),
    );
  }

  Widget _forecastWeatherSection() {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Text(
          'Weather Forecast',
          style: TextStyle(fontSize: 24, color: Colors.deepOrangeAccent),
        ),
        Container(
          height: 400,
          width: double.infinity,
          child: ListView.builder(
            itemCount: weatherProvider.forecastResponseModel!.list!.length,
            itemBuilder: (context, index) {
              final forecastData = weatherProvider.forecastResponseModel;
              return InkWell(
                child: Card(
                    elevation: 10,
                    color: Colors.blueGrey,
                    child: InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: size.width / 3,
                              child: Text(
                                getFormattedDateTime(
                                    forecastData!.list![index].dt!,
                                    'E, MMM dd'),
                                style: txtNormal16,
                              ),
                            ),
                            SizedBox(
                              width: (size.width / 5) * 2,
                              child: Row(
                                children: [
                                  Image.network(
                                    '$iconPrefix${forecastData.list![index].weather![0].icon}$iconSuffix',
                                    height: 50,
                                    width: 50,
                                  ),
                                  Text(
                                    '${forecastData.list![index].main!.humidity}/${forecastData.list![index].main!.temp!.round()}$degree',
                                    style: txtNormal16,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                  width: (size.width / 5 * 2),
                                  child: Text(
                                    '${forecastData.list![index].weather![0].description}',
                                    style: txtNormal16,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    )),
              );
            },
          ),
        ),
      ],
    );
  }



  Widget _currentWeatherSection2() {
    final response = weatherProvider.currentResponseModel;
    return Column(
      children: [
        Container(
          height: 400,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [
              Center(
                child: Positioned(
                  child: Container(
                    height: 300,
                    width: 350,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white12),
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: response!.main!.temp!.round()<10?Image.asset('images/snow.gif',height: 300,width: 350,fit: BoxFit.cover,):
                            Image.asset('images/fog.gif',height: 300,width: 350,fit: BoxFit.cover,)
                        ),
                        Center(
                            child: Column(
                              children: [
                                Image.network(
                                  '$iconPrefix${response!.weather![0].icon}$iconSuffix',
                                  color: Colors.white54,
                                  height: 100,
                                  width: 100,
                                ),
                                Text(
                                  '${response.name}, ${response.sys!.country}',
                                  style: txtNormal16,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${response.main!.temp!.round()}$degree${weatherProvider.unitSymbol}',
                                        style: TextStyle(
                                            fontSize: 40, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 35,
                left: 80,
                child: Container(
                    height: 35,
                    width: 250,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    child: Center(
                      child: Text(
                        '${getFormattedDateTime(response.dt!, 'EEEE M MMM yyyy')}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )),
              ),
              Positioned(
                top: 240,
                left: 154,
                child: Row(
                  children: [
                    Text(
                      ' Feels Like: ${response.main!.feelsLike!.round()}$degree',
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
              Positioned(
                top: 290,
                left: 50,
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Container(
                    height: 100,
                    width: 300,
                    child: Center(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('images/humidity.png', color: Colors.deepOrange,),
                                SizedBox(height: 10,),
                                Text(
                                  '${response.main!.humidity}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('images/visibility.png', color: Colors.deepOrange,),
                                SizedBox(height: 10,),
                                Text(
                                  '${response.visibility}km',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('images/storm.png', color: Colors.deepOrange,),
                                SizedBox(height: 10,),
                                Text(
                                  '${response.wind!.speed}kph',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('images/barometer.png', color: Colors.deepOrange,),
                                SizedBox(height: 10,),
                                Text(
                                  '${response.main!.pressure}hpa',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Today',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              label: Text(
                'Next 7 days',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(Icons.chevron_right),
            )
          ],
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 211,
            width: double.infinity,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weatherProvider.forecastResponseModel!.list!.length,
              itemBuilder: (context, index) {
                final forecastData = weatherProvider.forecastResponseModel;
                return InkWell(
                  child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                      elevation: 10,
                      color: Colors.white12,
                      child: InkWell(
                        onTap: () {

                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text('${getFormattedDateTime(weatherProvider.forecastResponseModel!.list![index].dt!, 'd MMM yyyy')}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                              SizedBox(height: 5,),
                              Text('${getFormattedDateTime(weatherProvider.forecastResponseModel!.list![index].dt!, 'hh : mm a')}', style: TextStyle(color: Colors.white, fontSize: 16),),

                              Image.network(
                                '$iconPrefix${weatherProvider.forecastResponseModel!.list![index].weather![0].icon}$iconSuffix',
                                height: 80,
                                width: 80,
                              ),

                              Text('${weatherProvider.forecastResponseModel!.list![index].main!.temp!.round()}$degree${weatherProvider.unitSymbol}', style: TextStyle(color: Colors.white, fontSize: 30),),
                            ],
                          ),
                        ),
                      )),
                );
              },
            ),
          ),
        )




      ],
    );
  }
}

class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(
        onPressed: () {
          close(context, '');
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      title: Text(query),
      onTap: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty
        ? cities
        : cities
            .where((city) => city.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(filteredList[index]),
        onTap: () {
          query = filteredList[index];
          close(context, query);
        },
      ),
    );
  }
}
