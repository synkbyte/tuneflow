import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:new_tuneflow/core/common/bloc/state_bloc.dart';
import 'package:new_tuneflow/core/common/providers/artist_provider.dart';
import 'package:new_tuneflow/core/common/providers/banner_provider.dart';
import 'package:new_tuneflow/core/common/providers/dash_provider.dart';
import 'package:new_tuneflow/core/common/providers/deffer_link_provider.dart';
import 'package:new_tuneflow/core/common/providers/downloads_provider.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/providers/favorite_provider.dart';
import 'package:new_tuneflow/core/common/providers/playlist_provider.dart';
import 'package:new_tuneflow/core/common/providers/profile_provider.dart';
import 'package:new_tuneflow/core/common/providers/room_provider.dart';
import 'package:new_tuneflow/core/common/providers/search_suggestions_provider.dart';
import 'package:new_tuneflow/core/common/providers/state_provider.dart';
import 'package:new_tuneflow/core/common/providers/user_provider.dart';
import 'package:new_tuneflow/core/services/api_service/app/search_suggestion_api_service.dart';
import 'package:new_tuneflow/core/services/api_service/app/support_api_service.dart';
import 'package:new_tuneflow/core/services/api_service/app/upload_api_service.dart';
import 'package:new_tuneflow/core/services/api_service/deep_link/deep_link_api_service.dart';
import 'package:new_tuneflow/core/services/api_service/like/like_api_service.dart';
import 'package:new_tuneflow/core/services/api_service/otp/otp_api_service.dart';
import 'package:new_tuneflow/core/services/api_service/playlist/playlist_api_service.dart';
import 'package:new_tuneflow/core/services/api_service/purchase/purchase_api_service.dart';
import 'package:new_tuneflow/core/services/api_service/recent/recent_api_service.dart';
import 'package:new_tuneflow/core/services/api_service/reset_password/reset_password_api_service.dart';
import 'package:new_tuneflow/core/services/api_service/room/room_api_service.dart';
import 'package:new_tuneflow/core/services/api_service/user/user_api_service.dart';
import 'package:new_tuneflow/core/services/audio_service.dart';
import 'package:new_tuneflow/src/album/data/data_source/album_data_source.dart';
import 'package:new_tuneflow/src/album/data/repository/album_repository_imp.dart';
import 'package:new_tuneflow/src/album/domain/repository/album_repository.dart';
import 'package:new_tuneflow/src/album/domain/usecase/album_usecase.dart';
import 'package:new_tuneflow/src/album/presentation/provider/album_provider.dart';
import 'package:new_tuneflow/src/artist_details/data/data_source/artist_details_data_source.dart';
import 'package:new_tuneflow/src/artist_details/data/repository/artist_details_repository_imp.dart';
import 'package:new_tuneflow/src/artist_details/domain/repository/artist_details_repository.dart';
import 'package:new_tuneflow/src/artist_details/domain/usecase/artist_details_usecase.dart';
import 'package:new_tuneflow/src/artist_details/presentation/bloc/artist_details_bloc.dart';
import 'package:new_tuneflow/src/artist_details/presentation/providers/artist_provider.dart';
import 'package:new_tuneflow/src/auth/data/data_source/artist_data_source.dart';
import 'package:new_tuneflow/src/auth/data/data_source/language_data_source.dart';
import 'package:new_tuneflow/src/auth/data/data_source/login_data_source.dart';
import 'package:new_tuneflow/src/auth/data/data_source/signup_data_source.dart';
import 'package:new_tuneflow/src/auth/data/repository/artist_repository_imp.dart';
import 'package:new_tuneflow/src/auth/data/repository/language_repository_imp.dart';
import 'package:new_tuneflow/src/auth/data/repository/login_repository_imp.dart';
import 'package:new_tuneflow/src/auth/data/repository/signup_repository_imp.dart';
import 'package:new_tuneflow/src/auth/domain/repository/artist_repository.dart';
import 'package:new_tuneflow/src/auth/domain/repository/language_repository.dart';
import 'package:new_tuneflow/src/auth/domain/repository/login_repository.dart';
import 'package:new_tuneflow/src/auth/domain/repository/signup_repository.dart';
import 'package:new_tuneflow/src/auth/domain/usecase/artist_usecase.dart';
import 'package:new_tuneflow/src/auth/domain/usecase/language_usecase.dart';
import 'package:new_tuneflow/src/auth/domain/usecase/login_usecase.dart';
import 'package:new_tuneflow/src/auth/domain/usecase/signup_usecase.dart';
import 'package:new_tuneflow/src/auth/presentation/bloc/artist_bloc.dart';
import 'package:new_tuneflow/src/chat/presentation/providers/chat_provider.dart';
import 'package:new_tuneflow/src/equalizer/presentation/providers/equalizer_provider.dart';
import 'package:new_tuneflow/src/explore/data/data_source/explore_remote_data_source.dart';
import 'package:new_tuneflow/src/explore/data/data_source/search_api_service.dart';
import 'package:new_tuneflow/src/explore/data/repository/explore_repo_imp.dart';
import 'package:new_tuneflow/src/explore/data/repository/search_repo_imp.dart';
import 'package:new_tuneflow/src/explore/domain/repository/explore_repo.dart';
import 'package:new_tuneflow/src/explore/domain/repository/search_repo.dart';
import 'package:new_tuneflow/src/explore/domain/usecase/explore_usecase.dart';
import 'package:new_tuneflow/src/explore/domain/usecase/search_usecase.dart';
import 'package:new_tuneflow/src/explore/presentation/bloc/discover_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/bloc/explore_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/bloc/foryou_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/bloc/search_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/bloc/trending_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/providers/explore_provider.dart';
import 'package:new_tuneflow/src/forum/presentation/providers/forum_provider.dart';
import 'package:new_tuneflow/src/other_profile/presentation/providers/other_profile_provider.dart';
import 'package:new_tuneflow/src/player/data/data_source/lyrics_data_source.dart';
import 'package:new_tuneflow/src/player/data/data_source/player_data_source.dart';
import 'package:new_tuneflow/src/player/data/repository/lyrics_repository_imp.dart';
import 'package:new_tuneflow/src/player/data/repository/player_repository_imp.dart';
import 'package:new_tuneflow/src/player/domain/repository/lyrics_repository.dart';
import 'package:new_tuneflow/src/player/domain/repository/player_repository.dart';
import 'package:new_tuneflow/src/player/domain/usecase/lyrics_usecase.dart';
import 'package:new_tuneflow/src/player/domain/usecase/player_usecase.dart';
import 'package:new_tuneflow/src/player/presentation/bloc/lyrics_bloc.dart';
import 'package:new_tuneflow/src/playlist/data/data_source/playlist_data_source.dart';
import 'package:new_tuneflow/src/playlist/data/repository/playlist_repository_imp.dart';
import 'package:new_tuneflow/src/playlist/domain/repository/playlist_repository.dart';
import 'package:new_tuneflow/src/playlist/domain/usecase/playlist_usecase.dart';
import 'package:new_tuneflow/src/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:new_tuneflow/src/settings/providers/delete_account_provider.dart';
import 'package:new_tuneflow/src/social/presentation/providers/social_provider.dart';
import 'package:new_tuneflow/src/song/data/data_source/song_details_api_service.dart';
import 'package:new_tuneflow/src/song/data/repository/song_details_repository_imp.dart';
import 'package:new_tuneflow/src/song/domain/repository/song_repository.dart';
import 'package:new_tuneflow/src/song/domain/usecase/song_usecase.dart';
import 'package:new_tuneflow/src/song/presentation/bloc/song_details_bloc.dart';

final sl = GetIt.instance;

MyAudioHandler audioHandler = MyAudioHandler();
late RoomProvider roomProvider;
late PlayerProvider playerProvider;
late StateBloc stateBloc;
late DefferLinkProvider defferLinkProvider;
late UserProvider userProvider;
late OtherProfileProvider otherProfileProvider;
late ChatProvider chatProvider;
late StateProvider stateProvider;

Future<void> initializeDependencies() async {
  audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'tuneflow.playback',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationIcon: 'drawable/media_noti',
      androidStopForegroundOnPause: false,
    ),
  );

  sl.registerSingleton<ExploreAPIService>(ExploreAPIServiceImp());
  sl.registerSingleton<ExploreRepository>(ExploreRepositoryImpl(sl()));
  sl.registerSingleton<ExploreUseCase>(ExploreUseCase(sl()));

  sl.registerSingleton<PlaylistApiService>(PlaylistApiServiceImp());
  sl.registerSingleton<PlaylistRepository>(PlaylistRepositoryImpl(sl()));
  sl.registerSingleton<PlaylistUseCase>(PlaylistUseCase(sl()));

  sl.registerSingleton<AlbumApiService>(AlbumApiServiceImp());
  sl.registerSingleton<AlbumRepository>(AlbumRepositoryImp(sl()));
  sl.registerSingleton<AlbumUseCase>(AlbumUseCase(sl()));

  sl.registerSingleton<SongDetailsApiService>(SongDetailsApiServiceImp());
  sl.registerSingleton<SongDetailsRepository>(SongDetailsRepositoryImp(sl()));
  sl.registerSingleton<SongDetailsUseCase>(SongDetailsUseCase(sl()));

  sl.registerSingleton<SearchApiService>(SearchApiServiceImp());
  sl.registerSingleton<SearchRepository>(SearchRepositoryImp(sl()));
  sl.registerSingleton<SearchUseCase>(SearchUseCase(sl()));

  sl.registerSingleton<ArtistDetailsApiService>(ArtistDetailsApiServiceImp());
  sl.registerSingleton<ArtistDetailsRepository>(
    ArtistDetailsRepositoryImp(sl()),
  );
  sl.registerSingleton<ArtistDetailsUseCase>(ArtistDetailsUseCase(sl()));

  sl.registerSingleton<PlayerApiService>(PlayerApiServiceImp());
  sl.registerSingleton<PlayerRepository>(PlayerRepositoryImp(sl()));
  sl.registerSingleton<PlayerUseCase>(PlayerUseCase(sl()));

  sl.registerSingleton<LyricsApiService>(LyricsApiServiceImp());
  sl.registerSingleton<LyricsRepository>(LyricsRepositoryImp(sl()));
  sl.registerSingleton<LyricsUseCase>(LyricsUseCase(sl()));

  sl.registerSingleton<ArtistApiService>(ArtistApiServiceImp());
  sl.registerSingleton<ArtistRepository>(ArtistRepositoryImp(sl()));
  sl.registerSingleton<ArtistUseCase>(ArtistUseCase(sl()));

  sl.registerSingleton<LoginApiService>(LoginApiServiceImp());
  sl.registerSingleton<LoginRepository>(LoginRepositoryImp(sl()));
  sl.registerSingleton<LoginUseCase>(LoginUseCase(sl()));

  sl.registerSingleton<SignupApiService>(SignupApiServiceImp());
  sl.registerSingleton<SignupRepository>(SignupRepositoryImp(sl()));
  sl.registerSingleton<SignupUseCase>(SignupUseCase(sl()));

  sl.registerSingleton<LanguageApiService>(LanguageApiServiceImp());
  sl.registerSingleton<LanguageRepository>(LanguageRepositoryImp(sl()));
  sl.registerSingleton<LanguageUseCase>(LanguageUseCase(sl()));

  sl.registerSingleton<LikeApiService>(LikeApiServiceImp());
  sl.registerSingleton<UserApiService>(UserApiServiceImp());
  sl.registerSingleton<PlaylistApiServiceGloble>(PlaylistApiServiceGlobleImp());
  sl.registerSingleton<UploadApiService>(UploadApiServiceImp());
  sl.registerSingleton<RecentApiService>(RecentApiServiceImp());
  sl.registerSingleton<SupportApiService>(SupportApiServiceImp());
  sl.registerSingleton<SearchSuggestionApiService>(
    SearchSuggestionApiServiceImp(),
  );
  sl.registerSingleton<DeepLinkApiService>(DeepLinkApiServiceImp());
  sl.registerSingleton<ResetPasswordApiService>(ResetPasswordApiServiceImp());
  sl.registerSingleton<PurchaseApiService>(PurchaseApiServiceImp());
  sl.registerSingleton<RoomAPIService>(RoomApiServiceImp());
  sl.registerSingleton<OtpApiService>(OtpApiServiceImp());

  sl.registerFactory<StateBloc>(() => StateBloc());
  sl.registerFactory<ExploreBloc>(() => ExploreBloc(sl()));
  sl.registerFactory<TrendingBloc>(() => TrendingBloc(sl()));
  sl.registerFactory<ForyouBloc>(() => ForyouBloc(sl()));
  sl.registerFactory<PlaylistBloc>(() => PlaylistBloc(sl()));
  sl.registerFactory<SongDetailsBloc>(() => SongDetailsBloc(sl()));
  sl.registerFactory<SearchBloc>(() => SearchBloc(sl()));
  sl.registerFactory<ArtistDetailsBloc>(() => ArtistDetailsBloc(sl()));
  sl.registerFactory<LyricsBloc>(() => LyricsBloc(sl()));
  sl.registerFactory<ArtistBloc>(() => ArtistBloc(sl()));
  sl.registerFactory<DiscoverBloc>(() => DiscoverBloc(sl()));

  sl.registerFactory<PlayerProvider>(() => PlayerProvider());
  sl.registerFactory<FavoriteProvider>(() => FavoriteProvider());
  sl.registerFactory<ArtistProvider>(() => ArtistProvider());
  sl.registerFactory<UserProvider>(() => UserProvider());
  sl.registerFactory<PlaylistProvider>(() => PlaylistProvider());
  sl.registerFactory<DownloadsProvider>(() => DownloadsProvider());
  sl.registerFactory<RoomProvider>(() => RoomProvider());
  sl.registerFactory<SearchSuggestionsProvider>(
    () => SearchSuggestionsProvider(),
  );
  sl.registerFactory<ProfileProvider>(() => ProfileProvider());
  sl.registerFactory<DefferLinkProvider>(() => DefferLinkProvider());
  sl.registerFactory<DashProvider>(() => DashProvider());
  sl.registerFactory<ExploreProvider>(() => ExploreProvider());
  sl.registerFactory<OtherProfileProvider>(() => OtherProfileProvider());
  sl.registerFactory<ForumProvider>(() => ForumProvider());
  sl.registerFactory<SocialProvider>(() => SocialProvider());
  sl.registerFactory<ChatProvider>(() => ChatProvider());
  sl.registerFactory<EqualizerProvider>(() => EqualizerProvider());
  sl.registerFactory<BannerProvider>(() => BannerProvider());
  sl.registerFactory<ArtistSongsProvider>(() => ArtistSongsProvider());
  sl.registerFactory<AlbumProvider>(() => AlbumProvider());
  sl.registerFactory<StateProvider>(() => StateProvider());
  sl.registerFactory<DeleteAccountProvider>(() => DeleteAccountProvider());
}
