import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/room.dart';
import '../models/row.dart' as room_row;
import '../models/seat.dart';

class ReservationPage extends StatefulWidget {
  Room room;
  int sessionId;

  ReservationPage(this.room, this.sessionId, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReservationPageState(room, sessionId);
}

class _ReservationPageState extends State<ReservationPage> {
  Room room;
  int sessionId;
  int rowIndex = 1;
  int seatIndex = 1;
  List<int> seatIndexes = [];
  bool isSuccess = false;


  var emailFieldController = TextEditingController();
  var cardNumberFieldController = TextEditingController();
  var expirationDateFieldController = TextEditingController();
  var cvvFieldController = TextEditingController();

  _ReservationPageState(this.room, this.sessionId);

  @override
  void dispose() {
    emailFieldController.dispose();
    cardNumberFieldController.dispose();
    expirationDateFieldController.dispose();
    cvvFieldController.dispose();
    super.dispose();
  }

  getSeatIndexes(int rowIndex) {
    seatIndexes.removeRange(0, seatIndexes.length);
    List<Seat> seats = room.rows.toList()[rowIndex - 1].seats;
    for (Seat temp in seats) {
      if (temp.isAvailable) {
        seatIndexes.add(temp.index);
      }
    }
    seatIndex = seatIndexes.toList()[0];
  }

  reserveSeat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';
    print(accessToken);
    int selectedId = room.rows[rowIndex - 1].seats[seatIndex - 1].id;
    List<int> selectedSeats = [];
    selectedSeats.add(selectedId);
    final response = await http.post(
      Uri.parse('https://fs-mt.qwerty123.tech/api/movies/book'),
      headers: {
        HttpHeaders.acceptLanguageHeader: 'en',
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'seats': selectedSeats,
        'sessionId': sessionId.toString(),
      }),
    );
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    if (jsonData['data'] == true) {
      await buyTickets();
    } else {
      print('Something went wrong');
    }
    print(jsonData);
  }

  buyTickets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';
    print(accessToken);
    int selectedId = room.rows[rowIndex - 1].seats[seatIndex - 1].id;
    List<int> selectedSeats = [];
    selectedSeats.add(selectedId);
    final response = await http.post(
      Uri.parse('https://fs-mt.qwerty123.tech/api/movies/buy'),
      headers: {
        HttpHeaders.acceptLanguageHeader: 'en',
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'seats': selectedSeats,
        'sessionId': sessionId.toString(),
        "email": emailFieldController.text,
        "cardNumber": cardNumberFieldController.text,
        "expirationDate": expirationDateFieldController.text,
        "cvv": cvvFieldController.text
      }),
    );
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    print(jsonData);
    if (jsonData['success'] == true) {
      isSuccess = true;
    } else {
      isSuccess = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(transform: GradientRotation(-pi / 6), colors: [
          Color(0xFF00A1AB),
          Color(0xFF20819A),
          Color(0xFF0D4F5F),
        ])),
        child: ListView(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          children: [
            Hero(
              tag: "Room ${room.name}",
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                            style: TextStyle(fontSize: 20, color: Colors.white),
                            'Row: '),
                        const SizedBox(
                          width: 5,
                        ),
                        DropdownButton<int>(
                          items: room.rows
                              .map<DropdownMenuItem<int>>((room_row.Row row) {
                            return DropdownMenuItem<int>(
                              value: row.index,
                              child: Text(
                                row.index.toString(),
                              ),
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            setState(() {
                              getSeatIndexes(value!);
                              rowIndex = value;
                            });
                          },
                          value: rowIndex,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                            style: TextStyle(fontSize: 20, color: Colors.white),
                            'Seat: '),
                        const SizedBox(
                          width: 5,
                        ),
                        DropdownButton<int>(
                          items: seatIndexes
                              .map<DropdownMenuItem<int>>((int index) {
                            return DropdownMenuItem<int>(
                              value: index,
                              child: Text(
                                index.toString(),
                              ),
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            setState(() {
                              seatIndex = value!;
                            });
                          },
                          value: seatIndex,
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.white,
                    ),
                    TextField(
                      controller: cardNumberFieldController,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12)),
                        hintStyle: TextStyle(color: Colors.white70),
                        hintText: 'Enter a card Number',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: expirationDateFieldController,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12)),
                        hintStyle: TextStyle(color: Colors.white70),
                        hintText: 'Enter an expiration date',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: cvvFieldController,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12)),
                        hintStyle: TextStyle(color: Colors.white70),
                        hintText: 'Enter a CVV',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: emailFieldController,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12)),
                        hintStyle: TextStyle(color: Colors.white70),
                        hintText: 'Enter an email',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await reserveSeat();
                          showDialog(context: context, builder: (BuildContext context) {
                            if(isSuccess) {
                              return AlertDialog(
                                title: const Text("Success"),
                                content: SizedBox(
                                  height: MediaQuery.of(context).size.height / 2,
                                  child: Column(
                                    children: [
                                      Text("Please, do a screenshot, otherwise, your ticket will be lost!"),
                                      SizedBox(height: 10,),
                                      Center(
                                        child: SizedBox(
                                          width: 200.0,
                                          height: 200.0,
                                          child: QrImage(
                                            data:  '$rowIndex $seatIndex ${room.id} ${room.name}',
                                            size: 280,
                                            embeddedImageStyle: QrEmbeddedImageStyle(
                                              size: const Size(
                                                100,
                                                100,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }else{
                              return AlertDialog(
                              title: const Text("Something went wrong!"),
                              content: Column(
                                children: const [
                                  Text(
                                      "Ticket was not bought due to some problems"),
                                ],
                              ),
                            );}
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                        child: Ink(
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    transform: GradientRotation(-pi / 6),
                                    colors: [
                                      Color(0xFF00A1AB),
                                      Color(0xFF20819A),
                                      Color(0xFF0D4F5F),
                                    ]),
                                borderRadius: BorderRadius.circular(20)),
                            child: Container(
                              height: 100,
                              alignment: Alignment.center,
                              child: const Text(
                                'Buy',
                                style: TextStyle(
                                    fontSize: 24, fontStyle: FontStyle.italic),
                              ),
                            )))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
