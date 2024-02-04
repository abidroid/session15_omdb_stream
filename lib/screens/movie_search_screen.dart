import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:session15_omdb_stream/models/movie.dart';
import 'package:session15_omdb_stream/utitlity/constants.dart';
import 'package:http/http.dart' as http;


class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  late TextEditingController movieNameController;
  late StreamController streamController;
  late Stream stream;
  Movie? movie;

  getMovieDetails({required String movieName}) async {

    streamController.add(Constants.Loading);

    String url = 'https://www.omdbapi.com/?t=$movieName&plot=full&apikey=94e188aa';
    // call api

    http.Response response = await http.get(Uri.parse(url));

    if( response.statusCode == 200 ){

      var jsonResponse = jsonDecode(response.body);

      if( jsonResponse['Response'] == 'True'){

        movie = Movie.fromJson(jsonResponse);

        streamController.add(Constants.Found);

      }else{
        streamController.add(Constants.NotFound);
      }


    }else{
      streamController.add(Constants.Error);
    }


  }

  @override
  void initState() {
    movieNameController = TextEditingController();

    streamController = StreamController();
    stream = streamController.stream;

    streamController.add(Constants.Initial);

    super.initState();
  }

  @override
  void dispose() {
    movieNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: movieNameController,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(onPressed: () {
          
                    movieNameController.clear();
                    streamController.add(Constants.Initial);
          
                  }, child: const Text('Clear')),
                  ElevatedButton(
                      onPressed: () {
                        String movieName = movieNameController.text.trim();
          
                        if (movieName.isEmpty) {
                          SnackBar snackBar = const SnackBar(
                              content: Text(
                            'Please provide movie name',
                            style: TextStyle(fontSize: 40),
                          ));
          
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          
                          return;
                        }
          
                        getMovieDetails(movieName: movieName);
                      },
                      child: const Text('Search')),
                ],
              ),
          
              StreamBuilder(stream: stream, builder: (context, snapshot){
          
                if( snapshot.data == Constants.Loading){
                  return const SpinKitDancingSquare(color: Colors.blue, size: 100,);
                }
          
                if( snapshot.data == Constants.Error){
                  return const Icon(Icons.error, size: 100,);
                }
          
                if( snapshot.data == Constants.NotFound){
                  return const Text('Not Found');
                }
          
                if( snapshot.data == Constants.Initial){
                  return const Text('Write a Movie Name');
          
                }
          
                if( snapshot.data == Constants.Found){
                  return Card(
                    child: Column(
                      children: [
                        
                        SizedBox(width: 200, height: 400, child: Image.network(movie!.poster!),),
                        const Divider(),
                        Text(movie!.title!, style: const TextStyle(fontSize: 30),),
                        const Divider(),

                        Text(movie!.actors!),
                      ],
                    ),
                  );
          
                }
          
          
          
          
                return const SizedBox.shrink();
              })
            ],
          ),
        ),
      ),
    );
  }
}
