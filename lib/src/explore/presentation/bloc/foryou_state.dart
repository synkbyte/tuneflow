part of 'foryou_bloc.dart';

sealed class ForyouState extends Equatable {
  final List<ForYouEntity>? forYouItems;
  final String? error;
  const ForyouState({this.forYouItems, this.error});

  @override
  List<Object?> get props => [forYouItems, error];
}

final class ForyouInitial extends ForyouState {}

final class ForyouFetched extends ForyouState {
  const ForyouFetched(List<ForYouEntity> forYouItems)
      : super(forYouItems: forYouItems);

  @override
  List<Object?> get props => [forYouItems];
}
