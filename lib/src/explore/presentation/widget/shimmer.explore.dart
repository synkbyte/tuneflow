part of 'shimmer.dart';

class ExploreLoadingCard extends StatefulWidget {
  const ExploreLoadingCard({super.key});

  @override
  State<ExploreLoadingCard> createState() => _ExploreLoadingCardState();
}

class _ExploreLoadingCardState extends State<ExploreLoadingCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: MyShimmer(
            child: Container(
              width: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.primary,
              ),
            ),
          ),
        ),
        const Gap(5),
        MyShimmer(
          child: Container(
            height: 8,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: context.primary,
            ),
          ),
        ),
        const Gap(5),
        MyShimmer(
          child: Container(
            height: 14,
            width: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: context.primary,
            ),
          ),
        ),
      ],
    );
  }
}
