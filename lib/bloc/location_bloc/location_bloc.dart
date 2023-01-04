import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rickandmorty/models/location_model.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(const LocationLoadingState()) {
    on<AddLocationList>(_addLocationListToBloc);
  }

  FutureOr<void> _addLocationListToBloc(AddLocationList event, Emitter<LocationState> emit) {
    if (state.props.toString() != event.listOfLocations.toString()) {
      if (kDebugMode) print('LocationsState ---> LocationList changed, refreshing list...');
      emit(const LocationLoadingState());
      emit(LocationSuccessfulstate(event.listOfLocations));
    } else {
      if (kDebugMode) print('LocationState ---> Same LocationList, doesnt need to refresh');
    }
  }
}
