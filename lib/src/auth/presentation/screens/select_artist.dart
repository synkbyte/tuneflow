import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/artist_provider.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/auth/domain/entites/artist_entity.dart';
import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';
import 'package:new_tuneflow/src/auth/domain/usecase/artist_usecase.dart';
import 'package:new_tuneflow/src/auth/presentation/bloc/artist_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/widget/shimmer.dart';
import 'package:new_tuneflow/src/home/presentation/screens/home.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SelectArtistScreen extends StatefulWidget {
  const SelectArtistScreen({super.key, this.isNewUser = true});
  final bool isNewUser;

  @override
  State<SelectArtistScreen> createState() => _SelectArtistScreenState();
}

class _SelectArtistScreenState extends State<SelectArtistScreen> {
  TextEditingController controller = TextEditingController();
  List<ArtistEntity> selectedArtists = [];
  bool isLoading = false;
  bool isInit = false;

  updateSelectedArtists(List<ArtistModel> savedArtists) {
    selectedArtists = savedArtists.map((e) => e.toEntity()).toList();
    isInit = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArtistProvider>(context);

    if (!widget.isNewUser && !isInit) {
      updateSelectedArtists(provider.savedArtists);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 40),
            const Text(
              'Personalize Your Collection',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Text(
              'Discover new music and tailor your experience with your favorite artists.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: controller,
              onChanged: (value) {
                if (value.isNotEmpty && value.trim().isNotEmpty) {
                  BlocProvider.of<ArtistBloc>(
                    context,
                  ).add(ArtistSearch(value.trim()));
                } else {
                  BlocProvider.of<ArtistBloc>(context).add(ArtistGetTop());
                }
              },
              decoration: InputDecoration(
                hintText: 'Search Artists',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: BlocBuilder<ArtistBloc, ArtistState>(
                  builder: (context, state) {
                    if (state is ArtistLoading) {
                      return _buildArtistLoading();
                    }

                    if (state is ArtistError) {
                      return Column(
                        children: [
                          Text(
                            state.error!,
                            style: TextStyle(color: context.scheme.error),
                          ),
                          const Row(),
                        ],
                      );
                    }

                    if (state is ArtistLoaded) {
                      return _buildArtistCard(state.artists!);
                    }

                    return _buildArtistLoading();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          widget.isNewUser
              ? selectedArtists.isEmpty
                  ? null
                  : Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: MediaQuery.of(context).padding.bottom + 10,
                      left: 20,
                      right: 20,
                    ),
                    child: PrimaryButton(
                      title: 'Continue',
                      isLoading: isLoading,
                      onPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (isLoading) return;
                        setState(() => isLoading = true);
                        List userSelectedArtists =
                            selectedArtists.map((e) => e.toMap()).toList();
                        ArtistUseCase useCase = sl();
                        DataState state = await useCase.updateSelectedArtists(
                          Cache.instance.userId,
                          userSelectedArtists,
                        );

                        bool hasAnyError = hasAnyErrors(state);
                        if (hasAnyError) {
                          return;
                        }

                        SignupEntity entity = state.data;
                        await CacheHelper().saveSelectedUserArtists(
                          userSelectedArtists,
                        );
                        if (!widget.isNewUser) {
                          await userProvider.initializeUser();
                        }
                        navigateUser(entity);
                      },
                    ),
                  )
              : Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: MediaQuery.of(context).padding.bottom + 10,
                  left: 20,
                  right: 20,
                ),
                child: PrimaryButton(
                  title: 'Done',
                  isLoading: isLoading,
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (isLoading) return;
                    setState(() => isLoading = true);
                    List userSelectedArtists =
                        selectedArtists.map((e) => e.toMap()).toList();
                    ArtistUseCase useCase = sl();
                    DataState state = await useCase.updateSelectedArtists(
                      Cache.instance.userId,
                      userSelectedArtists,
                    );

                    bool hasAnyError = hasAnyErrors(state);
                    if (hasAnyError) {
                      return;
                    }

                    SignupEntity entity = state.data;
                    await CacheHelper().saveSelectedUserArtists(
                      userSelectedArtists,
                    );

                    await provider.intializeArtist();
                    if (!widget.isNewUser) await userProvider.initializeUser();

                    navigateUser(entity);
                  },
                ),
              ),
    );
  }

  _buildArtistLoading() {
    return GridView.builder(
      itemCount: 30,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        mainAxisExtent: 150,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return MyShimmer(
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Container(
                height: 12,
                width: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildArtistCard(List<ArtistEntity> artists) {
    return GridView.builder(
      itemCount: artists.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        mainAxisExtent: 150,
      ),
      itemBuilder: (context, index) {
        ArtistEntity model = artists[index];
        return GestureDetector(
          onTap: () {
            if (isArtistSelected(selectedArtists, model)) {
              selectedArtists.removeWhere((element) => element.id == model.id);
            } else {
              selectedArtists.insert(0, model);
            }
            setState(() {});
          },
          child: Column(
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: model.image.good,
                    imageBuilder: (context, imageProvider) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundImage: imageProvider,
                      );
                    },
                    placeholder: (context, url) {
                      return const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/logo.png'),
                      );
                    },
                  ),
                  if (isArtistSelected(selectedArtists, model))
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: .8),
                      child: const Icon(Ionicons.checkmark_circle),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                model.name,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  bool isArtistSelected(
    List<ArtistEntity> selectedArtists,
    ArtistEntity artist,
  ) {
    for (int i = 0; i < selectedArtists.length; i++) {
      if (selectedArtists[i].id == artist.id) {
        return true;
      }
    }
    return false;
  }

  bool hasAnyErrors(DataState state) {
    if (state is DataError) {
      errorMessage(context, state.error!);
      setState(() => isLoading = false);
      return true;
    }

    SignupEntity entity = state.data;
    if (!entity.status) {
      errorMessage(context, entity.message);
      setState(() => isLoading = false);
      return true;
    }

    return false;
  }

  navigateUser(SignupEntity entity) {
    setState(() => isLoading = false);

    if (!widget.isNewUser) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      PageTransition(child: const HomeScreen(), type: PageTransitionType.fade),
      (route) => false,
    );
  }
}
