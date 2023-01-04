// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'episode_bloc.dart';

abstract class EpisodeState extends Equatable {
  final List<EpisodeModel>? listOfEpisodes;
  const EpisodeState({this.listOfEpisodes});

  @override
  List<Object> get props => [listOfEpisodes!];

  @override
  bool get stringify => true;
}

class EpisodeLoadingState extends EpisodeState {
  const EpisodeLoadingState() : super(listOfEpisodes: const []);
}

class EpisodeSuccessfulState extends EpisodeState {
  final List<EpisodeModel> listOfEpisodesState;
  const EpisodeSuccessfulState(this.listOfEpisodesState) : super(listOfEpisodes: listOfEpisodesState);
}
