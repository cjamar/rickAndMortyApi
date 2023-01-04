import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rickandmorty/models/character_model.dart';
part 'character_event.dart';
part 'character_state.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  CharacterBloc() : super(const CharacterLoadingState()) {
    on<AddCharactersList>(_addCharacterListToBloc);
  }

  FutureOr<void> _addCharacterListToBloc(AddCharactersList event, Emitter<CharacterState> emit) {
    if (state.props.toString() != event.listOfCharacters.toString()) {
      if (kDebugMode) print('CharacterState ---> CharacterList changed, refreshing list...');
      emit(const CharacterLoadingState());
      emit(CharacterSuccessfulState(event.listOfCharacters));
    } else {
      if (kDebugMode) print('CharacterState ---> Same CharacterList, doesnt need to refresh');
    }
  }
}
