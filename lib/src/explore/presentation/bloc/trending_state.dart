part of 'trending_bloc.dart';

sealed class TrendingState extends Equatable {
  final List<TrendingEntity>? trendingItems;
  final String? error;
  const TrendingState({this.trendingItems, this.error});

  @override
  List<Object?> get props => [trendingItems!, error!];
}

final class TrendingInitial extends TrendingState {}

final class TrendingFetched extends TrendingState {
  const TrendingFetched(List<TrendingEntity> trendingItems)
      : super(trendingItems: trendingItems);

  @override
  List<Object?> get props => [trendingItems ?? []];
}

final class ExploreError extends TrendingState {
  const ExploreError(String error) : super(error: error);

  @override
  List<Object?> get props => [error];
}
