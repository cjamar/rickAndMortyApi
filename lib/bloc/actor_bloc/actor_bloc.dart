import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:rickandmorty/models/character_model.dart';
part 'actor_event.dart';
part 'actor_state.dart';

class ActorBloc extends Bloc<ActorEvent, ActorState> {
  ActorBloc() : super(const ActorLoadingState()) {
    on<AddActorsList>(_addActorsListToBloc);
  }

  FutureOr<void> _addActorsListToBloc(AddActorsList event, Emitter<ActorState> emit) {
    if (state.props.toString() != event.listOfActors.toString()) {
      if (kDebugMode) print('ActorsState ---> ActorList changed, refreshing list...');
      emit(const ActorLoadingState());
      emit(ActorSuccessfulState(event.listOfActors));
    } else {
      if (kDebugMode) print('CharacterState ---> Same CharacterList, doesnt need to refresh');
    }
  }
}
