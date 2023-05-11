import 'package:flutter/material.dart';

import '../models/session.dart';
import 'film_detailed_widget.dart';

class FilmWidget extends StatelessWidget {
  FilmWidget(
      {super.key,
      required this.id,
      required this.name,
      required this.age,
      required this.trailer,
      required this.image,
      required this.smallImage,
      required this.originalName,
      required this.duration,
      required this.language,
      required this.rating,
      required this.year,
      required this.country,
      required this.genre,
      required this.plot,
      required this.starring,
      required this.director,
      required this.screenwriter,
      required this.studio,
      required this.sessions});

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is FilmWidget &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          age == other.age &&
          trailer == other.trailer &&
          image == other.image &&
          smallImage == other.smallImage &&
          originalName == other.originalName &&
          duration == other.duration &&
          language == other.language &&
          rating == other.rating &&
          year == other.year &&
          country == other.country &&
          genre == other.genre &&
          plot == other.plot &&
          starring == other.starring &&
          director == other.director &&
          screenwriter == other.screenwriter &&
          studio == other.studio;

  @override
  int get hashCode =>
      super.hashCode ^
      id.hashCode ^
      name.hashCode ^
      age.hashCode ^
      trailer.hashCode ^
      image.hashCode ^
      smallImage.hashCode ^
      originalName.hashCode ^
      duration.hashCode ^
      language.hashCode ^
      rating.hashCode ^
      year.hashCode ^
      country.hashCode ^
      genre.hashCode ^
      plot.hashCode ^
      starring.hashCode ^
      director.hashCode ^
      screenwriter.hashCode ^
      studio.hashCode;

  List<Session> getSessions(Map<int, List<Session>> sessionsByFilmId){
    List<Session> nothing = [];
    return sessionsByFilmId['id'] ?? nothing;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => FilmDetailedWidget(id, name, age, trailer, image, smallImage, originalName, duration,
                language, rating,  year, country, genre, plot, starring, director, screenwriter, studio, sessions,
                  )
          ));
        },
        child: Hero(
            tag: "film$id",
            child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(image),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                            child: Text(
                                textScaleFactor: 1,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                name)),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 5,
                        ),
                        const Icon(Icons.star_border, color: Colors.limeAccent),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                            textScaleFactor: 1,
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white),
                            rating.toString()),
                        const SizedBox(
                          width: 5,
                        ),
                        const Icon(Icons.circle_rounded,
                            size: 4, color: Colors.white),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                            child: Text(
                                textScaleFactor: 1,
                                style: const TextStyle(color: Colors.white),
                                "${duration} mins")),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                )
            )
        )
    );
  }
}
