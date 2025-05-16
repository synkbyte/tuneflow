import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/widget/loading.dart';
import 'package:new_tuneflow/core/common/widget/name_with_batch.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/src/other_profile/presentation/providers/other_profile_provider.dart';
import 'package:new_tuneflow/src/other_profile/presentation/screens/other_profile.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class FollowDataScreen extends StatefulWidget {
  const FollowDataScreen({super.key, this.selectedIndex = 0});
  final int selectedIndex;

  @override
  State<FollowDataScreen> createState() => _FollowDataScreenState();
}

class _FollowDataScreenState extends State<FollowDataScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OtherProfileProvider>(context);

    if (provider.followDataLoading) {
      return Scaffold(body: LoadingWidget());
    }

    if (provider.followDataError) {
      return Scaffold(
        body: Center(
          child: Text(
            provider.followDataErrorMessage,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Row(
            children: [
              const Gap(10),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.keyboard_backspace),
              ),
              Text(
                provider.followDataUser.userNameF!,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const Gap(10),
          const Divider(height: 0),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => selectedIndex = 0);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'Followers',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => selectedIndex = 1);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'Following',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: selectedIndex == 0 ? 2 : 1,
                  color:
                      selectedIndex == 0
                          ? context.primary
                          : context.onBgColor.withValues(alpha: .2),
                ),
              ),
              Expanded(
                child: Container(
                  height: selectedIndex == 1 ? 2 : 1,
                  color:
                      selectedIndex == 1
                          ? context.primary
                          : context.onBgColor.withValues(alpha: .2),
                ),
              ),
            ],
          ),
          const Gap(10),
          if (selectedIndex == 0 && provider.followers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'This user\'s followers list is empty',
                style: TextStyle(fontSize: 12),
              ),
            ),
          if (selectedIndex == 1 && provider.following.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'This user hasn’t followed anyone yet.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
              child: ListView.builder(
                itemCount:
                    selectedIndex == 0
                        ? provider.followers.length
                        : provider.following.length,
                itemBuilder: (context, index) {
                  Map data =
                      selectedIndex == 0
                          ? provider.followers[index]
                          : provider.following[index];
                  return ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: '$imageBaseUrl${data['avatar']}',
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          height: 55,
                          width: 55,
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
                          height: 55,
                          width: 55,
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
                    title: NameWithBatch(
                      name: Text(
                        data['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      batch: data,
                      size: 18,
                      topPadding: 2,
                    ),
                    subtitle: Text(
                      data['userName'],
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      provider.fetchProfile(data['id']);
                      Navigator.push(
                        context,
                        PageTransition(
                          child: const OtherProfile(),
                          type: PageTransitionType.fade,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
