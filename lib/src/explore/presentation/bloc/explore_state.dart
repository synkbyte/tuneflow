part of 'explore_bloc.dart';

sealed class ExploreState extends Equatable {
  final List<ExploreEntiry>? exploreItems;
  final String? error;

  const ExploreState({this.exploreItems, this.error});

  @override
  List<Object?> get props => [exploreItems!, error!];
}

final class ExploreInitial extends ExploreState {}

final class ExploreFetched extends ExploreState {
  const ExploreFetched(List<ExploreEntiry> exploreItems)
      : super(exploreItems: exploreItems);

  @override
  List<Object?> get props => [exploreItems ?? []];
}

final class ExploreError extends ExploreState {
  const ExploreError(String error) : super(error: error);
  @override
  List<Object?> get props => [error];
}
