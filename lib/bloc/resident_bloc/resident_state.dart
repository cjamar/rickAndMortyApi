// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'resident_bloc.dart';

abstract class ResidentState extends Equatable {
  final List<CharacterModel>? listOfResidents;
  const ResidentState({this.listOfResidents});

  @override
  List<Object> get props => [listOfResidents!];

  @override
  bool get stringify => true;
}

class ResidentLoadingState extends ResidentState {
  const ResidentLoadingState() : super(listOfResidents: const []);
}

class ResidentSuccessfulState extends ResidentState {
  final List<CharacterModel> listOfResidentsState;

  const ResidentSuccessfulState(this.listOfResidentsState) : super(listOfResidents: listOfResidentsState);
}
