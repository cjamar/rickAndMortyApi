part of 'character_bloc.dart';

@immutable
abstract class CharacterState extends Equatable {
  final List<CharacterModel>? listOfCharacters;

  const CharacterState({this.listOfCharacters});

  @override
  List<Object> get props => [listOfCharacters!];

  @override
  bool get stringify => true;
}

class CharacterLoadingState extends CharacterState {
 const CharacterLoadingState() : super(listOfCharacters: const []);
}

class CharacterSuccessfulState extends CharacterState {
  final List<CharacterModel> listOfCharactersState;

  const CharacterSuccessfulState(this.listOfCharactersState)
      : super(listOfCharacters: listOfCharactersState);
}
