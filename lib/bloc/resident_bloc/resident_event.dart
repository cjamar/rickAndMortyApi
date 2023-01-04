part of 'resident_bloc.dart';

@immutable
abstract class ResidentEvent extends Equatable {
  const ResidentEvent();

  @override
  List<Object> get props => [];
}

class AddResidentsList extends ResidentEvent {
  final List<CharacterModel> listOfResidents;
  const AddResidentsList(this.listOfResidents);
}
