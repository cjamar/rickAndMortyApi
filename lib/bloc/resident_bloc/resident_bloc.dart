import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:rickandmorty/models/character_model.dart';

part 'resident_event.dart';
part 'resident_state.dart';

class ResidentBloc extends Bloc<ResidentEvent, ResidentState> {
  ResidentBloc() : super(const ResidentLoadingState()) {
    on<AddResidentsList>(_addResidentListToBloc);
  }

  FutureOr<void> _addResidentListToBloc(AddResidentsList event, Emitter<ResidentState> emit) {
    if (state.props.toString() != event.listOfResidents.toString()) {
      if (kDebugMode) print('ResidentsState ---> ResidentsList changed, refreshing list...');
      emit(const ResidentLoadingState());
      emit(ResidentSuccessfulState(event.listOfResidents));
    } else {
      if (kDebugMode) print('ResidentsState ---> Same ResidentsList, doesnt need to refresh');
    }
  }
}
