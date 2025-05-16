part of 'foryou_bloc.dart';

sealed class ForyouEvent extends Equatable {
  const ForyouEvent();

  @override
  List<Object?> get props => [];
}

class FetchForYouEvent extends ForyouEvent {
  const FetchForYouEvent();

  @override
  List<Object?> get props => [];
}
