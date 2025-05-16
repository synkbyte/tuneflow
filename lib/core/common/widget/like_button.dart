import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/favorite_provider.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:provider/provider.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({super.key, required this.song, this.size, this.color});
  final SongModel song;
  final double? size;
  final Color? color;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoriteProvider>(context);
    return IconButton(
      onPressed: () {
        Fluttertoast.cancel();
        if (provider.isInLikedSong(widget.song)) {
          provider.removeFavoriteSong(widget.song);
          Fluttertoast.showToast(msg: 'Removed from Favorite');
        } else {
          provider.addFavoriteSong(widget.song);
          Fluttertoast.showToast(msg: 'Added to Favorite');
        }
      },
      icon:
          provider.isInLikedSong(widget.song)
              ? Icon(
                Icons.favorite,
                size: widget.size ?? 30,
                color: context.primary,
              )
              : Icon(
                Icons.favorite_border,
                size: widget.size ?? 30,
                color: widget.color,
              ),
      color: context.scheme.onSurface,
    );
  }
}
