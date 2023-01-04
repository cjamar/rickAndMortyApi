import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:rickandmorty/models/episode_model.dart';
part 'episode_event.dart';
part 'episode_state.dart';

class EpisodeBloc extends Bloc<EpisodeEvent, EpisodeState> {
  EpisodeBloc() : super(const EpisodeLoadingState()) {
    on<AddEpisodeList>(_addEpisodeListToBloc);
  }

  FutureOr<void> _addEpisodeListToBloc(AddEpisodeList event, Emitter<EpisodeState> emit) {
    if (state.props.toString() != event.listOfEpisodes.toString()) {
      if (kDebugMode) print('EpisodesState ---> EpisodeList changed, refreshing list...');
      emit(const EpisodeLoadingState());
      emit(EpisodeSuccessfulState(event.listOfEpisodes));
    } else {
      if (kDebugMode) print('EpisodeState ---> Same EpisodeList, doesnt need to refresh');
    }
  }
}
