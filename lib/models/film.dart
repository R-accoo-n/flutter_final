class Film {
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

  Film({
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
    required this.studio
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Film &&
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

  @override
  String toString() {
    return 'Film{id: $id, name: $name, age: $age, trailer: $trailer, image: $image, smallImage: $smallImage, originalName: $originalName, duration: $duration, language: $language, rating: $rating, year: $year, country: $country, genre: $genre, plot: $plot, starring: $starring, director: $director, screenwriter: $screenwriter, studio: $studio}';
  }
}
