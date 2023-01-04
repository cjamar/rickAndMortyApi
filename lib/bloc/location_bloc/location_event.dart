part of 'location_bloc.dart';

@immutable
abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class AddLocationList extends LocationEvent {
  final List<LocationModel> listOfLocations;
  const AddLocationList(this.listOfLocations);
}
