part of 'episode_bloc.dart';

@immutable
abstract class EpisodeEvent extends Equatable {
  const EpisodeEvent();

  @override
  List<Object> get props => [];
}

class AddEpisodeList extends EpisodeEvent {
  final List<EpisodeModel> listOfEpisodes;
  const AddEpisodeList(this.listOfEpisodes);
}
