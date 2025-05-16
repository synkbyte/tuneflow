import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_tuneflow/core/common/providers/state_provider.dart';
import 'package:new_tuneflow/core/common/singletones/user.dart';
import 'package:new_tuneflow/core/common/widget/name_with_batch.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/src/chat/presentation/providers/chat_provider.dart';
import 'package:new_tuneflow/src/other_profile/presentation/providers/other_profile_provider.dart';
import 'package:new_tuneflow/src/other_profile/presentation/screens/other_profile.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class WelcomeAppBar extends StatelessWidget {
  const WelcomeAppBar({
    super.key,
    this.title,
    this.showBatch = false,
    this.surfix,
  });
  final String? title;
  final bool showBatch;
  final Widget? surfix;

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  context.read<OtherProfileProvider>().fetchProfile(
                    User.instance.user!.id,
                  );
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: OtherProfile(),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: User.instance.user!.avatar!,
                  placeholder:
                      (context, url) => Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(Media.logo),
                          ),
                        ),
                      ),
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: imageProvider,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NameWithBatch(
                    name: Text(
                      'Hey ${getFirstName(User.instance.user!.name)}',
                      style: GoogleFonts.dekko(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    batch: User.instance.user!.getBatch(),
                    size: 10,
                    topPadding: 0,
                  ),
                  Text(
                    title ?? '',
                    style: GoogleFonts.dekko(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Spacer(),
              surfix ??
                  IconButton(
                    onPressed: () {
                      context.read<StateProvider>().toggleDrawer();
                    },
                    icon: Badge.count(
                      count: chatProvider.unreadCount,
                      isLabelVisible: chatProvider.unreadCount != 0,
                      child: Image.asset(
                        Media.menu,
                        height: 35,
                        width: 35,
                        color: context.onBgColor,
                      ),
                    ),
                  ),
            ],
          ),
        ),
        const Gap(10),
        Divider(height: 0),
      ],
    );
  }
}
