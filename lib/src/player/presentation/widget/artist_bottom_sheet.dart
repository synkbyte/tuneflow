import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/src/artist_details/presentation/bloc/artist_details_bloc.dart';
import 'package:new_tuneflow/src/artist_details/presentation/screens/artist_details.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ArtistBottomSheet extends StatelessWidget {
  const ArtistBottomSheet({super.key, required this.artists});
  final List<SongArtingModel> artists;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 100,
        maxHeight: 700,
        minWidth: MediaQuery.of(context).size.width,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            ' Artists',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: artists.length,
              itemBuilder: (context, index) {
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<ArtistDetailsBloc>().add(
                          ArtistDetailsFetch(id: artists[index].id),
                        );
                    Navigator.push(
                      context,
                      PageTransition(
                        child: const ArtistDetailsScreen(),
                        type: PageTransitionType.fade,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 5,
                    ),
                    child: Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: artists[index].imagesUrl.good,
                          imageBuilder: (context, imageProvider) {
                            return CircleAvatar(
                              radius: 25,
                              backgroundImage: imageProvider,
                            );
                          },
                          placeholder: (context, url) {
                            return const CircleAvatar(
                              radius: 25,
                              backgroundImage: AssetImage(Media.logo),
                            );
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                artists[index].name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text(
                                'Artist',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
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
                return const SizedBox(
                  height: 10,
                );
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
