import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/widget/name_with_batch.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/src/explore/presentation/widget/shimmer.dart';
import 'package:new_tuneflow/src/other_profile/presentation/providers/other_profile_provider.dart';
import 'package:new_tuneflow/src/other_profile/presentation/screens/other_profile.dart';
import 'package:new_tuneflow/src/social/presentation/providers/social_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SearchPeople extends StatefulWidget {
  const SearchPeople({super.key});

  @override
  State<SearchPeople> createState() => _SearchPeopleState();
}

class _SearchPeopleState extends State<SearchPeople> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final otherProvider = Provider.of<OtherProfileProvider>(context);
    final provider = Provider.of<SocialProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: controller,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  provider.onSearchTextChanged(value);
                }
                setState(() {});
              },
              decoration: InputDecoration(
                filled: true,
                hintText: 'Search...',
                prefixIcon: BackButton(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    width: 1,
                    color: context.scheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    width: 2,
                    color: context.scheme.primary,
                  ),
                ),
                suffixIcon:
                    controller.text.isNotEmpty
                        ? IconButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            controller.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        )
                        : null,
              ),
            ),
          ),
          Gap(5),
          const Divider(),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: Expanded(
              child: ListView(
                children: [
                  if (controller.text.isNotEmpty)
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Results for "${controller.text}"',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        if (provider.isSearching)
                          _buildSearchSongShimmer()
                        else if (provider.searchedUsers.isNotEmpty)
                          ListView.separated(
                            itemCount: provider.searchedUsers.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              Map model = provider.searchedUsers[index];
                              return GestureDetector(
                                onTap: () {
                                  otherProvider.fetchProfile(model['id']);
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      child: const OtherProfile(),
                                      type: PageTransitionType.fade,
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: context.scheme.secondaryContainer,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl:
                                            '$imageBaseUrl${model['avatar']}',
                                        imageBuilder: (context, imageProvider) {
                                          return Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: imageProvider,
                                              ),
                                            ),
                                          );
                                        },
                                        placeholder: (context, url) {
                                          return Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: AssetImage(Media.logo),
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            NameWithBatch(
                                              name: Text(
                                                model['name'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              batch: model,
                                              size: 16,
                                              topPadding: 0,
                                            ),
                                            Text(
                                              model['userName'],
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Gap(10);
                            },
                          )
                        else
                          Text(
                            'No Results Found with ${controller.text}',
                            style: TextStyle(fontSize: 10),
                          ),
                        Gap(10),
                      ],
                    ),
                  if (provider.batchedUsers.isNotEmpty)
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Pro Members',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 70,
                          child: ListView.separated(
                            itemCount: provider.batchedUsers.length,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemBuilder: (context, index) {
                              Map model = provider.batchedUsers[index];
                              return GestureDetector(
                                onTap: () {
                                  otherProvider.fetchProfile(model['id']);
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      child: const OtherProfile(),
                                      type: PageTransitionType.fade,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: context.scheme.primary.withValues(
                                      alpha: .2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl:
                                            '$imageBaseUrl${model['avatar']}',
                                        imageBuilder: (context, imageProvider) {
                                          return Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: imageProvider,
                                              ),
                                            ),
                                          );
                                        },
                                        placeholder: (context, url) {
                                          return Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: AssetImage(Media.logo),
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      Gap(10),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          NameWithBatch(
                                            name: Text(
                                              model['name'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            batch: model,
                                            size: 15,
                                            topPadding: 1,
                                          ),
                                          Text(
                                            model['userName'],
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const Gap(10);
                            },
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  if (provider.leaderboards.isNotEmpty)
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Vibe Masters',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          itemCount: provider.leaderboards.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            Map data = provider.leaderboards[index];
                            return InkWell(
                              onTap: () {
                                otherProvider.fetchProfile(data['id']);
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: const OtherProfile(),
                                    type: PageTransitionType.fade,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl:
                                          '$imageBaseUrl${data['avatar']}',
                                      imageBuilder: (context, imageProvider) {
                                        return Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: context.primary,
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: imageProvider,
                                            ),
                                          ),
                                        );
                                      },
                                      placeholder: (context, url) {
                                        return Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: context.primary,
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: AssetImage(Media.logo),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Gap(10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          NameWithBatch(
                                            name: Text(
                                              data['name'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            batch: data,
                                          ),
                                          Text(
                                            '${data['songCount']} Tunes Enjoyed',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 12),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  Gap(MediaQuery.of(context).padding.bottom + 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSongShimmer() {
    return ListView.separated(
      itemCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return MyShimmer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: context.scheme.secondaryContainer,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                _buildShimmerContainer(40, 40, 10),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildShimmerContainer(170, 14, 10),
                      const SizedBox(height: 5),
                      _buildShimmerContainer(100, 10, 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const Gap(10),
    );
  }

  Widget _buildShimmerContainer(double width, double height, double radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: context.primary,
      ),
    );
  }
}
