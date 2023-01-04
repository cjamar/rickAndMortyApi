// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'location_bloc.dart';

abstract class LocationState extends Equatable {
  final List<LocationModel>? listOfLocations;
  const LocationState({this.listOfLocations});

  @override
  List<Object> get props => [listOfLocations!];

  @override
  bool get stringify => true;
}

class LocationLoadingState extends LocationState {
  const LocationLoadingState() : super(listOfLocations: const []);
}

class LocationSuccessfulstate extends LocationState {
  final List<LocationModel> listOfLocationsState;

  const LocationSuccessfulstate(this.listOfLocationsState) : super(listOfLocations: listOfLocationsState);
}
