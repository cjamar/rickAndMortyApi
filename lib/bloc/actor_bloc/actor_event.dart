part of 'actor_bloc.dart';

@immutable
abstract class ActorEvent extends Equatable {
  const ActorEvent();

  @override
  List<Object> get props => [];
}

class AddActorsList extends ActorEvent {
  final List<CharacterModel> listOfActors;
  const AddActorsList(this.listOfActors);
}
