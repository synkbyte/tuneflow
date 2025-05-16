part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  final SearchEntity? results;
  final String? error;
  const SearchState({this.results, this.error});

  @override
  List<Object?> get props => [results, error];
}

final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {}

final class SearchResults extends SearchState {
  const SearchResults(SearchEntity results) : super(results: results);

  @override
  List<Object?> get props => [results];
}

final class SearchError extends SearchState {
  const SearchError(String error) : super(error: error);

  @override
  List<Object?> get props => [error];
}
