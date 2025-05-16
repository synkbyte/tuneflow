part of 'trending_bloc.dart';

sealed class TrendingEvent extends Equatable {
  const TrendingEvent();

  @override
  List<Object> get props => [];
}

class FetchTrending extends TrendingEvent {
  const FetchTrending();

  @override
  List<Object> get props => [];
}
