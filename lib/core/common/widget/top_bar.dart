   // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Row(
        //               children: [
        //                 Container(
        //                   height: 45,
        //                   width: 45,
        //                   decoration: BoxDecoration(
        //                     border: Border.all(
        //                       width: 1.5,
        //                       color: context.scheme.primary,
        //                     ),
        //                     shape: BoxShape.circle,
        //                     image: DecorationImage(
        //                       fit: BoxFit.cover,
        //                       image: CachedNetworkImageProvider(
        //                         User.instance.user!.avatar!,
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //                 const Gap(10),
        //                 Expanded(
        //                   child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       NameWithBatch(
        //                         name: Text(
        //                           'Hello ${getFirstName(User.instance.user!.name)}',
        //                           style: GoogleFonts.gamjaFlower(
        //                             fontWeight: FontWeight.bold,
        //                             fontSize: 12,
        //                             color: context.onBgColor.withValues(
        //                               alpha: .7,
        //                             ),
        //                           ),
        //                         ),
        //                         batch: User.instance.user!.getBatch(),
        //                         size: 13,
        //                         topPadding: 0,
        //                       ),
        //                       Text(
        //                         getGreeting(),
        //                         style: GoogleFonts.playpenSans(
        //                           fontWeight: FontWeight.bold,
        //                           fontSize: 12,
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ],
        //         ),
        //       ),
        //       Container(
        //         decoration: BoxDecoration(
        //           shape: BoxShape.circle,
        //           color: context.primary.withValues(alpha: .2),
        //         ),
        //         child: InkWell(
        //           onTap: () {
        //             Navigator.push(
        //               context,
        //               PageTransition(
        //                 child: const NotificationScreen(),
        //                 type: PageTransitionType.fade,
        //               ),
        //             );
        //           },
        //           borderRadius: BorderRadius.circular(100),
        //           child: const SizedBox(
        //             height: 45,
        //             width: 45,
        //             child: Icon(Icons.notifications_outlined),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      