part of 'character_bloc.dart';

@immutable
abstract class CharacterEvent {
  const CharacterEvent();
}

class AddCharactersList extends CharacterEvent {
  final List<CharacterModel> listOfCharacters;
  const AddCharactersList(this.listOfCharacters);
}
