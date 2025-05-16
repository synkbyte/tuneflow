part of 'discover_bloc.dart';

sealed class DiscoverState extends Equatable {
  const DiscoverState({this.discoverItems, this.error});
  final List<DiscoverEntiry>? discoverItems;
  final String? error;

  @override
  List<Object?> get props => [discoverItems, error];
}

final class DiscoverInitial extends DiscoverState {}

final class DiscoverFetched extends DiscoverState {
  const DiscoverFetched(List<DiscoverEntiry> discoverItems)
      : super(discoverItems: discoverItems);

  @override
  List<Object?> get props => [discoverItems];
}

final class DiscoverError extends DiscoverState {
  const DiscoverError(String error) : super(error: error);

  @override
  List<Object?> get props => [error];
}
