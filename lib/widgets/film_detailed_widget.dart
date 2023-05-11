import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_final/widgets/reservation_page.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/row.dart' as room_row;
import '../models/room.dart';
import '../models/seat.dart';
import '../models/session.dart';

class FilmDetailedWidget extends StatefulWidget {
  final int id;
  final String name;
  final int age;
  final String trailer;
  final String image;
  final String smallImage;
  final String originalName;
  final int duration;
  final String language;
  final String rating;
  final int year;
  final String country;
  final String genre;
  final String plot;
  final String starring;
  final String director;
  final String screenwriter;
  final String studio;
  final List<Session> sessions;

  const FilmDetailedWidget(
      this.id,
      this.name,
      this.age,
      this.trailer,
      this.image,
      this.smallImage,
      this.originalName,
      this.duration,
      this.language,
      this.rating,
      this.year,
      this.country,
      this.genre,
      this.plot,
      this.starring,
      this.director,
      this.screenwriter,
      this.studio,
      this.sessions,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FilmDetailedWidgetState(
      id,
      name,
      age,
      trailer,
      image,
      smallImage,
      originalName,
      duration,
      language,
      rating,
      year,
      country,
      genre,
      plot,
      starring,
      director,
      screenwriter,
      studio,
      sessions);
}

class _FilmDetailedWidgetState extends State<FilmDetailedWidget> {
  int id;
  String name;
  int age;
  String trailer;
  String image;
  String smallImage;
  String originalName;
  int duration;
  String language;
  String rating;
  int year;
  String country;
  String genre;
  String plot;
  String starring;
  String director;
  String screenwriter;
  String studio;
  List<Session> sessions;
  List<String> sessionTimes = [];
  String sessionDate = '';
  List<Widget> hoursWidgets = [];

  _FilmDetailedWidgetState(
      this.id,
      this.name,
      this.age,
      this.trailer,
      this.image,
      this.smallImage,
      this.originalName,
      this.duration,
      this.language,
      this.rating,
      this.year,
      this.country,
      this.genre,
      this.plot,
      this.starring,
      this.director,
      this.screenwriter,
      this.studio,
      this.sessions);


  @override
  void dispose() {
    super.dispose();
    hoursWidgets.removeRange(0, hoursWidgets.length);
  }

  @override
  void initState(){
    super.initState();
    hoursWidgets.removeRange(0, hoursWidgets.length);
  }

  getSessionsById(int id) async {
    sessionTimes.removeRange(0, sessionTimes.length);
    hoursWidgets.removeRange(0, hoursWidgets.length);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken')!;
    final response = await http.get(
      Uri.parse(
          'https://fs-mt.qwerty123.tech/api/movies/sessions?movieId=$id&date=2023-05-02'),
      headers: {
        HttpHeaders.acceptLanguageHeader: 'en',
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
      },
    );
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    List<dynamic> dataSession = jsonData['data'] ?? [];
    for (int i = 0; i < dataSession.length; i++) {
      Map<String, dynamic> dataRooms = dataSession[i]['room'];
      List<dynamic> rowsData = dataRooms['rows'];
      List<room_row.Row> rows = [];
      for (int j = 0; j < rowsData.length; j++) {
        List<dynamic> dataSeats = rowsData[j]['seats'];
        List<Seat> seats = [];
        for (int k = 0; k < dataSeats.length; k++) {
          seats.add(Seat(
              id: dataSeats[k]['id'],
              index: dataSeats[k]['index'],
              type: dataSeats[k]['type'],
              price: dataSeats[k]['price'],
              isAvailable: dataSeats[k]['isAvailable']));
        }
        rows.add(room_row.Row(
            id: rowsData[j]['id'], index: rowsData[j]['index'], seats: seats));
      }
      Room room =
          Room(id: dataRooms['id'], name: dataRooms['name'], rows: rows);
      Session session = Session(
          id: dataSession[i]['id'],
          date: dataSession[i]['date'],
          type: dataSession[i]['type'],
          minPrice: dataSession[i]['minPrice'],
          room: room);
      sessions.add(session);
      sessionTimes.add(DateFormat('HH:MM')
          .format(DateTime.fromMillisecondsSinceEpoch(session.date * 1000)));
      sessionDate = (DateFormat('d LLL')
          .format(DateTime.fromMillisecondsSinceEpoch(session.date * 1000)));

      hoursWidgets.add(InkWell(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ReservationPage(room, session.id)));
        },
        child: Hero(
            tag: "Room ${room.name}",
            child: Material(
                type: MaterialType.transparency,
                child: Row(children: [
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 5, vertical: 20),
                      decoration: BoxDecoration(
                          border: Border.all(
                        color: Colors.white,
                      )),
                      child: Text(
                          textScaleFactor: 1,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          DateFormat('HH:MM').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  session.date * 1000)))),
                  const SizedBox(
                    width: 5,
                  ),
                ])

            )
        ),
      ));
    }
    return sessions;
  }

  Future<List<Session>> loadData() async {
    sessions.removeRange(0, sessions.length);
    await getSessionsById(id);
    return sessions;
  }

  getHours() {
    List<Widget> widgets = [];
    for (String temp in sessionTimes) {
      print(temp);
      widgets.add(Container(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 5, vertical: 20),
          decoration: BoxDecoration(
              border: Border.all(
            color: Colors.white,
          )),
          child: Text(
              textScaleFactor: 1,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              temp)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadData(),
        builder: (BuildContext ctx, AsyncSnapshot<List<Session>> snapshot) =>
            snapshot.hasData
                ? Scaffold(
                    body: Container(
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              transform: GradientRotation(-pi / 6),
                              colors: [
                            Color(0xFF00A1AB),
                            Color(0xFF20819A),
                            Color(0xFF0D4F5F),
                          ])),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        children: [
                          Hero(
                            tag: "film$id",
                            child: Material(
                              type: MaterialType.transparency,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 60,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 40,
                                        ),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.network(image),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                    horizontal: 30, vertical: 20),
                                child: Text(
                                    textScaleFactor: 1,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    plot),
                              )),
                            ],
                          ),
                          const Divider(
                            color: Colors.white,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                  this.sessionDate),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 60,
                            height: MediaQuery.of(context).size.height / 10,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: hoursWidgets,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : snapshot.hasError
                    ? Center(
                        child: Text(snapshot.stackTrace.toString()),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                transform: GradientRotation(-pi / 6),
                                colors: [
                              Color(0xFF00A1AB),
                              Color(0xFF20819A),
                              Color(0xFF0D4F5F),
                            ])),
                        child: const Center(
                          // render the loading indicator
                          child: CircularProgressIndicator(),
                        )));
  }
}
