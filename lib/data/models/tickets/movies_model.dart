import 'package:cloud_firestore/cloud_firestore.dart';

class MovieModel {
  final String id;
  final String title;
  final String genre;
  final String rating;
  final String duration;
  final String releaseDate;
  final double imdbRating;
  final String synopsis;
  final List<String> cast;
  final String director;
  final String cinemaChain;
  final List<String> showtimes;
  final double ticketPrice;
  final String posterUrl;

  MovieModel({
    required this.id,
    required this.title,
    required this.genre,
    required this.rating,
    required this.duration,
    required this.releaseDate,
    required this.imdbRating,
    required this.synopsis,
    required this.cast,
    required this.director,
    required this.cinemaChain,
    required this.showtimes,
    required this.ticketPrice,
    this.posterUrl = '',
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'genre': genre,
      'rating': rating,
      'duration': duration,
      'releaseDate': releaseDate,
      'imdbRating': imdbRating,
      'synopsis': synopsis,
      'cast': cast,
      'director': director,
      'cinemaChain': cinemaChain,
      'showtimes': showtimes,
      'ticketPrice': ticketPrice,
      'posterUrl': posterUrl,
    };
  }

  factory MovieModel.fromMap(Map<String, dynamic> map) {
    return MovieModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      genre: map['genre'] ?? '',
      rating: map['rating'] ?? '',
      duration: map['duration'] ?? '',
      releaseDate: map['releaseDate'] ?? '',
      imdbRating: (map['imdbRating'] ?? 0.0).toDouble(),
      synopsis: map['synopsis'] ?? '',
      cast: List<String>.from(map['cast'] ?? <dynamic>[]),
      director: map['director'] ?? '',
      cinemaChain: map['cinemaChain'] ?? '',
      showtimes: List<String>.from(map['showtimes'] ?? <dynamic>[]),
      ticketPrice: (map['ticketPrice'] ?? 0.0).toDouble(),
      posterUrl: map['posterUrl'] ?? '',
    );
  }
}

// Updated MovieBookingModel with tax-related fields
class MovieBookingModel {
  final String id;
  final String movieId;
  final String movieTitle;
  final String cinemaChain;
  final String customerName;
  final String email;
  final String phone;
  final DateTime showDate;
  final String showtime;
  final int numberOfTickets;
  final String seatType;
  final double totalAmount;
  final double baseTicketPrice;
  final double seatUpgradeAmount;
  final double taxAmount;
  final String paymentStatus;
  final DateTime bookingDate;

  MovieBookingModel({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.cinemaChain,
    required this.customerName,
    required this.email,
    required this.phone,
    required this.showDate,
    required this.showtime,
    required this.numberOfTickets,
    required this.seatType,
    required this.totalAmount,
    required this.baseTicketPrice,
    required this.seatUpgradeAmount,
    required this.taxAmount,
    required this.paymentStatus,
    required this.bookingDate,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'cinemaChain': cinemaChain,
      'customerName': customerName,
      'email': email,
      'phone': phone,
      'showDate': Timestamp.fromDate(showDate),
      'showtime': showtime,
      'numberOfTickets': numberOfTickets,
      'seatType': seatType,
      'totalAmount': totalAmount,
      'baseTicketPrice': baseTicketPrice,
      'seatUpgradeAmount': seatUpgradeAmount,
      'taxAmount': taxAmount,
      'paymentStatus': paymentStatus,
      'bookingDate': Timestamp.fromDate(bookingDate),
    };
  }

  factory MovieBookingModel.fromMap(Map<String, dynamic> map) {
    return MovieBookingModel(
      id: map['id'] ?? '',
      movieId: map['movieId'] ?? '',
      movieTitle: map['movieTitle'] ?? '',
      cinemaChain: map['cinemaChain'] ?? '',
      customerName: map['customerName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      showDate: (map['showDate'] as Timestamp).toDate(),
      showtime: map['showtime'] ?? '',
      numberOfTickets: map['numberOfTickets'] ?? 1,
      seatType: map['seatType'] ?? 'Regular',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      baseTicketPrice: (map['baseTicketPrice'] ?? 0.0).toDouble(),
      seatUpgradeAmount: (map['seatUpgradeAmount'] ?? 0.0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0.0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? 'pending',
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
    );
  }
}

// US Cinema Chains & Current Movies Data
List<MovieModel> usMovieServices = <MovieModel>[
  // AMC Theatres - Current Blockbusters
  MovieModel(
    id: 'amc_001',
    title: 'Spider-Man: Across the Spider-Verse',
    genre: 'Animation, Action, Adventure',
    rating: 'PG',
    duration: '2h 20m',
    releaseDate: 'June 2, 2023',
    imdbRating: 8.7,
    synopsis: 'Miles Morales catapults across the Multiverse, where he encounters a team of Spider-People charged with protecting its very existence.',
    cast: <String>['Shameik Moore', 'Hailee Steinfeld', 'Brian Tyree Henry', 'Luna Lauren Velez'],
    director: 'Joaquim Dos Santos',
    cinemaChain: 'AMC Theatres',
    showtimes: <String>['10:00 AM', '1:30 PM', '4:45 PM', '7:15 PM', '10:30 PM'],
    ticketPrice: 14.99,
    posterUrl: '',
  ),

  MovieModel(
    id: 'amc_002',
    title: 'Guardians of the Galaxy Vol. 3',
    genre: 'Action, Adventure, Comedy',
    rating: 'PG-13',
    duration: '2h 30m',
    releaseDate: 'May 5, 2023',
    imdbRating: 8.0,
    synopsis: 'Still reeling from the loss of Gamora, Peter Quill rallies his team to defend the universe and protect one of their own.',
    cast: <String>['Chris Pratt', 'Zoe Saldana', 'Dave Bautista', 'Karen Gillan'],
    director: 'James Gunn',
    cinemaChain: 'AMC Theatres',
    showtimes: <String>['11:00 AM', '2:30 PM', '6:00 PM', '9:30 PM'],
    ticketPrice: 15.99,
    posterUrl: '',
  ),

  // Regal Cinemas
  MovieModel(
    id: 'regal_001',
    title: 'Fast X',
    genre: 'Action, Crime, Thriller',
    rating: 'PG-13',
    duration: '2h 21m',
    releaseDate: 'May 19, 2023',
    imdbRating: 5.8,
    synopsis: 'Dom Toretto and his family are targeted by the vengeful son of drug kingpin Hernan Reyes.',
    cast: <String>['Vin Diesel', 'Michelle Rodriguez', 'Tyrese Gibson', 'Ludacris'],
    director: 'Louis Leterrier',
    cinemaChain: 'Regal Cinemas',
    showtimes: <String>['12:00 PM', '3:20 PM', '6:40 PM', '10:00 PM'],
    ticketPrice: 13.75,
    posterUrl: '',
  ),

  MovieModel(
    id: 'regal_002',
    title: 'The Little Mermaid',
    genre: 'Adventure, Family, Fantasy',
    rating: 'PG',
    duration: '2h 15m',
    releaseDate: 'May 26, 2023',
    imdbRating: 7.2,
    synopsis: 'A young mermaid makes a deal with a sea witch to trade her beautiful voice for human legs.',
    cast: <String>['Halle Bailey', 'Jonah Hauer-King', 'Melissa McCarthy', 'Javier Bardem'],
    director: 'Rob Marshall',
    cinemaChain: 'Regal Cinemas',
    showtimes: <String>['10:30 AM', '1:45 PM', '5:00 PM', '8:15 PM'],
    ticketPrice: 12.99,
    posterUrl: '',
  ),

  // Cinemark Theatres
  MovieModel(
    id: 'cinemark_001',
    title: 'John Wick: Chapter 4',
    genre: 'Action, Crime, Thriller',
    rating: 'R',
    duration: '2h 49m',
    releaseDate: 'March 24, 2023',
    imdbRating: 7.7,
    synopsis: 'John Wick uncovers a path to defeating The High Table. But before he can earn his freedom, he must face off against a new enemy.',
    cast: <String>['Keanu Reeves', 'Laurence Fishburne', 'George Georgiou', 'Lance Reddick'],
    director: 'Chad Stahelski',
    cinemaChain: 'Cinemark Theatres',
    showtimes: <String>['11:30 AM', '3:00 PM', '6:30 PM', '10:00 PM'],
    ticketPrice: 13.50,
    posterUrl: '',
  ),

  MovieModel(
    id: 'cinemark_002',
    title: 'Scream VI',
    genre: 'Horror, Mystery, Thriller',
    rating: 'R',
    duration: '2h 3m',
    releaseDate: 'March 10, 2023',
    imdbRating: 6.5,
    synopsis: 'The survivors of the Ghostface killings leave Woodsboro behind and start a fresh chapter in New York City.',
    cast: <String>['Melissa Barrera', 'Jenna Ortega', 'Jasmin Savoy Brown', 'Mason Gooding'],
    director: 'Matt Bettinelli-Olpin',
    cinemaChain: 'Cinemark Theatres',
    showtimes: <String>['2:00 PM', '5:30 PM', '8:45 PM', '11:15 PM'],
    ticketPrice: 12.75,
    posterUrl: '',
  ),

  // Marcus Theatres
  MovieModel(
    id: 'marcus_001',
    title: 'Transformers: Rise of the Beasts',
    genre: 'Action, Adventure, Sci-Fi',
    rating: 'PG-13',
    duration: '2h 7m',
    releaseDate: 'June 9, 2023',
    imdbRating: 6.0,
    synopsis: 'During the 1990s, a new faction of Transformers - the Maximals - join the Autobots as allies in the battle for Earth.',
    cast: <String>['Anthony Ramos', 'Dominique Fishback', 'Luna Lauren Velez', 'Dean Scott Vazquez'],
    director: 'Steven Caple Jr.',
    cinemaChain: 'Marcus Theatres',
    showtimes: <String>['12:30 PM', '4:00 PM', '7:30 PM', '10:45 PM'],
    ticketPrice: 11.99,
    posterUrl: '',
  ),

  // Showcase Cinemas
  MovieModel(
    id: 'showcase_001',
    title: 'Indiana Jones and the Dial of Destiny',
    genre: 'Action, Adventure',
    rating: 'PG-13',
    duration: '2h 34m',
    releaseDate: 'June 30, 2023',
    imdbRating: 6.7,
    synopsis: 'Archaeologist Indiana Jones races against time to retrieve a legendary artifact that can change the course of history.',
    cast: <String>['Harrison Ford', 'Phoebe Waller-Bridge', 'Antonio Banderas', 'Karen Allen'],
    director: 'James Mangold',
    cinemaChain: 'Showcase Cinemas',
    showtimes: <String>['1:00 PM', '4:30 PM', '8:00 PM'],
    ticketPrice: 14.25,
    posterUrl: '',
  ),

  // Harkins Theatres
  MovieModel(
    id: 'harkins_001',
    title: 'Oppenheimer',
    genre: 'Biography, Drama, History',
    rating: 'R',
    duration: '3h 0m',
    releaseDate: 'July 21, 2023',
    imdbRating: 8.4,
    synopsis: 'The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb.',
    cast: <String>['Cillian Murphy', 'Emily Blunt', 'Matt Damon', 'Robert Downey Jr.'],
    director: 'Christopher Nolan',
    cinemaChain: 'Harkins Theatres',
    showtimes: <String>['11:00 AM', '3:15 PM', '7:30 PM'],
    ticketPrice: 16.50,
    posterUrl: '',
  ),

  MovieModel(
    id: 'harkins_002',
    title: 'Barbie',
    genre: 'Adventure, Comedy, Fantasy',
    rating: 'PG-13',
    duration: '1h 54m',
    releaseDate: 'July 21, 2023',
    imdbRating: 7.0,
    synopsis: 'Barbie and Ken are having the time of their lives in the colorful and seemingly perfect world of Barbie Land.',
    cast: <String>['Margot Robbie', 'Ryan Gosling', 'Issa Rae', 'Kate McKinnon'],
    director: 'Greta Gerwig',
    cinemaChain: 'Harkins Theatres',
    showtimes: <String>['10:15 AM', '1:00 PM', '3:45 PM', '6:30 PM', '9:15 PM'],
    ticketPrice: 13.99,
    posterUrl: '',
  ),

  // Landmark Theatres
  MovieModel(
    id: 'landmark_001',
    title: 'Mission: Impossible – Dead Reckoning Part One',
    genre: 'Action, Adventure, Thriller',
    rating: 'PG-13',
    duration: '2h 43m',
    releaseDate: 'July 12, 2023',
    imdbRating: 7.7,
    synopsis: 'Ethan Hunt and his IMF team must track down a terrifying new weapon that threatens all of humanity.',
    cast: <String>['Tom Cruise', 'Hayley Atwell', 'Ving Rhames', 'Simon Pegg'],
    director: 'Christopher McQuarrie',
    cinemaChain: 'Landmark Theatres',
    showtimes: <String>['12:45 PM', '4:15 PM', '7:45 PM'],
    ticketPrice: 15.75,
    posterUrl: '',
  ),

  // Alamo Drafthouse Cinema
  MovieModel(
    id: 'alamo_001',
    title: 'Sound of Freedom',
    genre: 'Action, Biography, Crime',
    rating: 'PG-13',
    duration: '2h 11m',
    releaseDate: 'July 4, 2023',
    imdbRating: 7.7,
    synopsis: 'The incredible true story of a former government agent turned vigilante who embarks on a dangerous mission to rescue children from human traffickers.',
    cast: <String>['Jim Caviezel', 'Mira Sorvino', 'Bill Camp', 'Kurt Fuller'],
    director: 'Alejandro Monteverde',
    cinemaChain: 'Alamo Drafthouse Cinema',
    showtimes: <String>['2:30 PM', '6:00 PM', '9:30 PM'],
    ticketPrice: 12.00,
    posterUrl: '',
  ),

  // Bow Tie Cinemas
  MovieModel(
    id: 'bowtie_001',
    title: 'Elemental',
    genre: 'Animation, Adventure, Comedy',
    rating: 'PG',
    duration: '1h 41m',
    releaseDate: 'June 16, 2023',
    imdbRating: 7.0,
    synopsis: 'In a city where fire, water, land, and air residents live together, a fiery young woman and a go-with-the-flow guy discover something elemental.',
    cast: <String>['Leah Lewis', 'Mamoudou Athie', 'Ronnie Del Carmen', 'Shila Ommi'],
    director: 'Peter Sohn',
    cinemaChain: 'Bow Tie Cinemas',
    showtimes: <String>['11:15 AM', '2:00 PM', '4:45 PM', '7:30 PM'],
    ticketPrice: 11.50,
    posterUrl: '',
  ),

  // Studio Movie Grill
  MovieModel(
    id: 'smg_001',
    title: 'The Flash',
    genre: 'Action, Adventure, Fantasy',
    rating: 'PG-13',
    duration: '2h 24m',
    releaseDate: 'June 16, 2023',
    imdbRating: 6.9,
    synopsis: 'Barry Allen uses his super speed to change the past, but his attempt to save his family creates a world without superheroes.',
    cast: <String>['Ezra Miller', 'Michael Keaton', 'Sasha Calle', 'Michael Shannon'],
    director: 'Andy Muschietti',
    cinemaChain: 'Studio Movie Grill',
    showtimes: <String>['1:30 PM', '5:00 PM', '8:30 PM'],
    ticketPrice: 13.25,
    posterUrl: '',
  ),

  // iPic Theaters
  MovieModel(
    id: 'ipic_001',
    title: 'No Hard Feelings',
    genre: 'Comedy, Romance',
    rating: 'R',
    duration: '1h 43m',
    releaseDate: 'June 23, 2023',
    imdbRating: 6.4,
    synopsis: 'On the brink of losing her childhood home, a desperate woman agrees to date a shy 19-year-old.',
    cast: <String>['Jennifer Lawrence', 'Andrew Barth Feldman', 'Laura Benanti', 'Natalie Morales'],
    director: 'Gene Stupnitsky',
    cinemaChain: 'iPic Theaters',
    showtimes: <String>['3:00 PM', '6:15 PM', '9:00 PM'],
    ticketPrice: 18.99,
    posterUrl: '',
  ),

  // Classic Horror and Independent Films
  MovieModel(
    id: 'independent_001',
    title: 'Talk to Me',
    genre: 'Horror, Thriller',
    rating: 'R',
    duration: '1h 35m',
    releaseDate: 'July 28, 2023',
    imdbRating: 7.1,
    synopsis: 'When a group of friends discover how to conjure spirits using an embalmed hand, they become hooked on the new thrill.',
    cast: <String>['Sophie Wilde', 'Alexandra Jensen', 'Joe Bird', 'Otis Dhanji'],
    director: 'Danny Philippou',
    cinemaChain: 'Various Independent Theaters',
    showtimes: <String>['7:00 PM', '9:45 PM'],
    ticketPrice: 10.99,
    posterUrl: '',
  ),

  // Family-Friendly Options
  MovieModel(
    id: 'family_001',
    title: 'Ruby Gillman, Teenage Kraken',
    genre: 'Animation, Adventure, Comedy',
    rating: 'PG',
    duration: '1h 31m',
    releaseDate: 'June 30, 2023',
    imdbRating: 5.7,
    synopsis: 'A shy teenager discovers that she\'s part of a legendary royal lineage of mythical sea krakens.',
    cast: <String>['Lana Condor', 'Toni Collette', 'Annie Murphy', 'Sam Richardson'],
    director: 'Kirk DeMicco',
    cinemaChain: 'Various Family Theaters',
    showtimes: <String>['10:00 AM', '12:30 PM', '3:00 PM', '5:30 PM'],
    ticketPrice: 9.99,
    posterUrl: '',
  ),

  // IMAX and Premium Format Movies
  MovieModel(
    id: 'imax_001',
    title: 'Avatar: The Way of Water (Re-release)',
    genre: 'Action, Adventure, Drama',
    rating: 'PG-13',
    duration: '3h 12m',
    releaseDate: 'December 16, 2022',
    imdbRating: 7.6,
    synopsis: 'Jake Sully lives with his newfound family formed on the extrasolar moon Pandora.',
    cast: <String>['Sam Worthington', 'Zoe Saldana', 'Sigourney Weaver', 'Stephen Lang'],
    director: 'James Cameron',
    cinemaChain: 'IMAX Theaters',
    showtimes: <String>['11:00 AM', '3:30 PM', '8:00 PM'],
    ticketPrice: 22.99,
    posterUrl: '',
  ),
];