import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/src/explore/presentation/widget/shimmer.dart';

class TrendingShimmer extends StatelessWidget {
  const TrendingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return MyShimmer(
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: context.primary,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class TrendingShimmerView extends StatefulWidget {
  const TrendingShimmerView({super.key});

  @override
  State<TrendingShimmerView> createState() => _TrendingShimmerViewState();
}

class _TrendingShimmerViewState extends State<TrendingShimmerView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: SizedBox(
        height: 150,
        child: ListView.separated(
          itemCount: 10,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return const TrendingShimmer();
          },
          separatorBuilder: (context, index) {
            return const SizedBox(width: 15);
          },
        ),
      ),
    );
  }
}
