import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/src/player/presentation/widget/more_action_sheet.dart';

class MoreVertSong extends StatelessWidget {
  const MoreVertSong({super.key, required this.model});
  final SongModel model;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return ShowMoreVert(model: model);
          },
        );
      },
      icon: const Icon(
        Icons.more_vert,
        size: 25,
      ),
    );
  }
}
