import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_final/models/room.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

import 'models/film.dart';
import 'models/row.dart' as room_row;
import 'models/seat.dart';
import 'models/session.dart';
import 'widgets/film_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CinemaApp());
}

class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Final',
        home: CinemaHomePage());
  }
}

class CinemaHomePage extends StatefulWidget {
  const CinemaHomePage({super.key});

  @override
  State<CinemaHomePage> createState() => _CinemaHomePageState();
}

class _CinemaHomePageState extends State<CinemaHomePage> {
  bool isLogined = false;
  String accessToken = '';
  String sessionToken = '';
  List<Film> films = [];
  Map<int, List<Session>> sessionsByFilmId = <int, List<Session>>{};
  List<FilmWidget> filmWidgets = [];
  List<FilmWidget> leftFilmWidgets = [];
  List<FilmWidget> rightFilmWidgets = [];

  Future<bool> getIsLogined() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool boolValue = prefs.getBool('wasEverLogined') ?? false;
    isLogined = boolValue;
    print(isLogined);
    return isLogined;
  }

  startLogin() async {
    final response = await http.post(
        Uri.parse('https://fs-mt.qwerty123.tech/api/auth/session'),
        headers: {HttpHeaders.acceptLanguageHeader: 'en'});
    print(jsonDecode(response.body));
    sessionToken = ((jsonDecode(response.body)['data'])['sessionToken']);
    await getAccessTocken();
  }

  Future<void> getAccessTocken() async {
    var signature =
        sha256.convert(utf8.encode('${sessionToken}2jukqvNnhunHWMBRRVcZ9ZQ9'));
    final response = await http.post(
      Uri.parse('https://fs-mt.qwerty123.tech/api/auth/token'),
      headers: {
        HttpHeaders.acceptLanguageHeader: 'en',
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode(<String, String>{
        'sessionToken': sessionToken,
        'signature': signature.toString(),
      }),
    );
    print(jsonDecode(response.body));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await getAccessTokenVariable();
    accessToken = ((jsonDecode(response.body)['data'])['sessionToken']);
    if (accessToken.isEmpty) {
      prefs.setBool('wasEverLogined', true);
      prefs.setString('accessToken', accessToken);
    } else {
      accessToken = prefs.getString('accessToken')!;
    }
    print(prefs.getString('accessToken'));
    print(accessToken);
    await getFilms();
  }

  Future<String> getAccessTokenVariable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken') ?? '';
    return accessToken;
  }

  //For testing purposes only
  setWasEverLoginFalse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('wasEverLogined', false);
    prefs.setString('accessToken', '');
  }

  getFilms() async {
    final response = await http.get(
      Uri.parse(
          'https://fs-mt.qwerty123.tech/api/movies?date=2023-05-02&query='),
      headers: {
        HttpHeaders.acceptLanguageHeader: 'en',
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
      },
    );
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    if (jsonData['success'] != null) {
      List<dynamic> data = jsonData['data'];
      for (int i = 0; i < data.length; i++) {
        Film tempFilm = Film(
          id: data[i]["id"] as int,
          name: data[i]["name"] as String,
          age: data[i]["age"] as int,
          trailer: data[i]['trailer'] as String,
          image: data[i]['image'] as String,
          smallImage: data[i]['smallImage'] as String,
          originalName: data[i]['originalName'] as String,
          duration: data[i]['duration'] as int,
          language: data[i]['language'] as String,
          rating: data[i]['rating'] as String,
          year: data[i]['year'] as int,
          country: data[i]['country'] as String,
          genre: data[i]['genre'] as String,
          plot: data[i]['plot'] as String,
          starring: data[i]['starring'] as String,
          director: data[i]['director'] as String,
          screenwriter: data[i]['screenwriter'] as String,
          studio: data[i]['studio'] as String,
        );
        if (!films.contains(tempFilm)) {
          films.add(tempFilm);
        }
      }
    }
    buildFilmWidgets();
  }

  getSessionsById(int id) async {
    List<Session> filmSessions = [];
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
      filmSessions.add(session);
    }
    return filmSessions;
  }

  getSessions() async {
    for (Film temp in films) {
      List<Session> filmSessions = [];
      int filmId = temp.id;
      sessionsByFilmId.putIfAbsent(filmId, () => []);
      final response = await http.get(
        Uri.parse(
            'https://fs-mt.qwerty123.tech/api/movies/sessions?movieId=$filmId&date=2023-05-02'),
        headers: {
          HttpHeaders.acceptLanguageHeader: 'en',
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $accessToken',
        },
      );
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      if (jsonData['success'] != null) {
        List<dynamic> dataSession = jsonData['data'];
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
                id: rowsData[j]['id'],
                index: rowsData[j]['index'],
                seats: seats));
          }
          Room room =
              Room(id: dataRooms['id'], name: dataRooms['name'], rows: rows);
          Session session = Session(
              id: dataSession[i]['id'],
              date: dataSession[i]['date'],
              type: dataSession[i]['type'],
              minPrice: dataSession[i]['minPrice'],
              room: room);
          filmSessions.add(session);
        }
        sessionsByFilmId.update(filmId, (value) => filmSessions);
      } else {
        break;
      }
    }
  }

  Future<void> buildFilmWidgets() async {
    filmWidgets.removeRange(0, filmWidgets.length);
    leftFilmWidgets.removeRange(0, leftFilmWidgets.length);
    rightFilmWidgets.removeRange(0, rightFilmWidgets.length);
    int index = 0;
    films = films.toSet().toList();
    for (Film temp in films) {
      FilmWidget filmWidgetTemp = FilmWidget(
        id: temp.id,
        name: temp.name,
        age: temp.age,
        trailer: temp.trailer,
        image: temp.image,
        smallImage: temp.smallImage,
        originalName: temp.originalName,
        duration: temp.duration,
        language: temp.language,
        rating: temp.rating,
        year: temp.year,
        country: temp.country,
        genre: temp.genre,
        plot: temp.plot,
        starring: temp.starring,
        director: temp.director,
        screenwriter: temp.screenwriter,
        studio: temp.studio,
        sessions: sessionsByFilmId[temp.id.toString()] ?? [],
      );
      if (!filmWidgets.contains(filmWidgetTemp)) {
        filmWidgets.add(filmWidgetTemp);
        if (index % 2 == 0) {
          leftFilmWidgets.add(filmWidgetTemp);
        } else {
          rightFilmWidgets.add(filmWidgetTemp);
        }
        index++;
      }
    }
  }

  Future<List<FilmWidget>> loadData() async {
    filmWidgets.removeRange(0, filmWidgets.length);
    leftFilmWidgets.removeRange(0, leftFilmWidgets.length);
    rightFilmWidgets.removeRange(0, rightFilmWidgets.length);
    if (!isLogined) {
      await startLogin();
    } else {
      await getFilms();
    }
    return filmWidgets;
  }

  // @override
  // initState() {
  //   super.initState();
  //   getIsLogined();
  //   if (!isLogined) {
  //     startLogin();
  //   } else {
  //     getFilms();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    //setWasEverLoginFalse();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            transform: GradientRotation(-pi / 6),
            colors: [
              Color(0xFF00A1AB),
              Color(0xFF20819A),
              Color(0xFF0D4F5F),
            ],
          ),
        ),
        child: FutureBuilder(
          future: loadData(),
          builder:
              (BuildContext ctx, AsyncSnapshot<List<FilmWidget>> snapshot) =>
                  snapshot.hasData
                      ? ListView(
                          //padding: EdgeInsets.zero,
                          scrollDirection: Axis.vertical,
                          children: [
                            Row(
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: Set.of(leftFilmWidgets).toList(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: Set.of(rightFilmWidgets).toList(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                              ],
                            )
                          ],
                        )
                      : snapshot.hasError
                          ? Center(
                              child: Text(snapshot.stackTrace.toString()),
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
        ),
      ),
    );
  }
}
