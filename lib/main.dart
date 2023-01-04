import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rickandmorty/bloc/actor_bloc/actor_bloc.dart';
import 'package:rickandmorty/bloc/character_bloc/character_bloc.dart';
import 'package:rickandmorty/bloc/episode_bloc/episode_bloc.dart';
import 'package:rickandmorty/bloc/location_bloc/location_bloc.dart';
import 'package:rickandmorty/bloc/resident_bloc/resident_bloc.dart';
import 'package:rickandmorty/constants/app_routes_constants.dart';
import 'package:rickandmorty/models/character_model.dart';
import 'package:rickandmorty/models/location_model.dart';
import 'package:rickandmorty/models/origin_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await _registerAdapters();
  runApp(const MyApp());
}

_registerAdapters() async {
  Hive
    ..registerAdapter(CharacterModelAdapter())
    ..registerAdapter(LocationModelAdapter())
    ..registerAdapter(OriginModelAdapter());

  await Hive.openBox<CharacterModel>('characters');
  await Hive.openBox<LocationModel>('locations');
  await Hive.openBox<OriginModel>('origins');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CharacterBloc()),
        BlocProvider(create: (_) => LocationBloc()),
        BlocProvider(create: (_) => ResidentBloc()),
        BlocProvider(create: (_) => EpisodeBloc()),
        BlocProvider(create: (_) => ActorBloc())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: AppRoutes.initialRoute,
        routes: AppRoutes.getAppRoutes(),
      ),
    );
  }
}
