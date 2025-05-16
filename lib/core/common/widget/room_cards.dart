import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/bloc/state_bloc.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';

class RoomCardsMini extends StatelessWidget {
  const RoomCardsMini({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<StateBloc>().add(const StateChangeIndex(2));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        elevation: 4,
        child: Container(
          height: 100,
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.scheme.primaryContainer,
                context.scheme.secondaryContainer.withValues(alpha: .1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.group,
                color: context.scheme.onPrimaryContainer,
                size: 32,
              ),
              Gap(20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Join or Create Room",
                      style: TextStyle(
                        color: context.scheme.onPrimaryContainer,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Host public or private rooms easily!",
                      style: TextStyle(
                        fontSize: 9,
                        color: context.scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Listen & Chat with Friends in Real-Time.",
                      style: TextStyle(
                        fontSize: 9,
                        color: context.scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
