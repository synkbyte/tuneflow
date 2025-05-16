import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/utils/function.dart';

class NameWithBatch extends StatelessWidget {
  const NameWithBatch({
    super.key,
    required this.name,
    this.size = 17,
    required this.batch,
    this.topPadding = 4,
  });
  final Widget name;
  final double size;
  final Map batch;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            name,
            if (batch['hasBatch']) const Gap(5),
            if (batch['hasBatch'] && batch['batchName'] == 'verified')
              Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: Icon(
                  Icons.verified,
                  size: size,
                  color: getBatchColor(batch['batchColor']),
                ),
              ),

            if (batch['hasBatch'] &&
                batch['batchName'] == 'premium' &&
                batch['batchColor'] == '1w')
              Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: SvgPicture.asset(
                  'assets/icons/1-week.svg',
                  height: size,
                ),
              ),
            if (batch['hasBatch'] &&
                batch['batchName'] == 'premium' &&
                batch['batchColor'] == '1m')
              Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: SvgPicture.asset(
                  'assets/icons/1-month.svg',
                  height: size + 3,
                ),
              ),
            if (batch['hasBatch'] &&
                batch['batchName'] == 'premium' &&
                batch['batchColor'] == '3m')
              Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: SvgPicture.asset(
                  'assets/icons/3-months.svg',
                  height: size,
                ),
              ),
            if (batch['hasBatch'] &&
                batch['batchName'] == 'premium' &&
                batch['batchColor'] == '6m')
              Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: Image.asset('assets/icons/crown.gif', height: size + 3),
              ),
            if (batch['hasBatch'] &&
                batch['batchName'] == 'premium' &&
                batch['batchColor'] == '1y')
              Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: Image.asset(Media.premiumBatch, height: size + 3),
              ),
          ],
        ),
      ],
    );
  }
}

class GetBatchWidget extends StatelessWidget {
  const GetBatchWidget({
    super.key,
    required this.batch,
    this.size = 17,
    this.topPadding = 0,
  });
  final Map batch;
  final double size;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    if (batch['hasBatch'] && batch['batchName'] == 'verified') {
      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Icon(
          Icons.verified,
          size: size,
          color: getBatchColor(batch['batchColor']),
        ),
      );
    }

    if (batch['hasBatch'] &&
        batch['batchName'] == 'premium' &&
        batch['batchColor'] == '1w') {
      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: SvgPicture.asset('assets/icons/1-week.svg', height: size),
      );
    }
    if (batch['hasBatch'] &&
        batch['batchName'] == 'premium' &&
        batch['batchColor'] == '1m') {
      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: SvgPicture.asset('assets/icons/1-month.svg', height: size + 3),
      );
    }
    if (batch['hasBatch'] &&
        batch['batchName'] == 'premium' &&
        batch['batchColor'] == '3m') {
      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: SvgPicture.asset('assets/icons/3-months.svg', height: size),
      );
    }
    if (batch['hasBatch'] &&
        batch['batchName'] == 'premium' &&
        batch['batchColor'] == '6m') {
      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Image.asset('assets/icons/crown.gif', height: size + 3),
      );
    }
    if (batch['hasBatch'] &&
        batch['batchName'] == 'premium' &&
        batch['batchColor'] == '1y') {
      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Image.asset(Media.premiumBatch, height: size + 3),
      );
    }

    // if (batch['hasBatch'] && batch['batchName'] == 'verified') {
    //   return Icon(
    //     Icons.verified,
    //     size: size,
    //     color: getBatchColor(batch['batchColor']),
    //   );
    // }
    // if (batch['hasBatch'] && batch['batchName'] == 'premium') {
    //   return Image.asset(Media.premiumBatch, height: 24);
    // }
    return const SizedBox();
  }
}
