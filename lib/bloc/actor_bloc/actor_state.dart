part of 'actor_bloc.dart';

@immutable
abstract class ActorState extends Equatable {
  final List<CharacterModel>? listOfActors;
  const ActorState({this.listOfActors});

  @override
  List<Object> get props => [listOfActors!];

  @override
  bool get stringify => true;
}

class ActorLoadingState extends ActorState {
  const ActorLoadingState() : super(listOfActors: const []);
}

class ActorSuccessfulState extends ActorState {
  final List<CharacterModel> listOfActorsState;
  const ActorSuccessfulState(this.listOfActorsState) : super(listOfActors: listOfActorsState);
}
