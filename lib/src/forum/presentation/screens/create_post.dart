// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/src/forum/presentation/providers/forum_provider.dart';
import 'package:provider/provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ForumProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Create Post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
          const Gap(10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const Gap(20),
            const Text(
              'Title',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const Gap(10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextField(
                controller: title,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.onBgColor.withValues(alpha: .1),
                  border: InputBorder.none,
                ),
              ),
            ),
            const Gap(20),
            const Text(
              'Content',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const Gap(10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextField(
                controller: content,
                maxLines: 10,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.onBgColor.withValues(alpha: .1),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () async {
          FocusManager.instance.primaryFocus?.unfocus();
          if (isLoading) return;
          if (title.text.isEmpty || content.text.isEmpty) {
            errorMessage(context, 'Title and Content is required');
            return;
          }

          setState(() => isLoading = true);

          Map response = await provider.addForum(title.text, content.text);
          setState(() => isLoading = false);
          if (!response['status']) {
            errorMessage(context, response['message']);
            return;
          }
          successMessage(context, 'Posted successfully');
          provider.reset();
          Navigator.pop(context);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: .4),
            borderRadius: isLoading
                ? BorderRadius.circular(100)
                : BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? CircularProgressIndicator(color: context.onBgColor)
              : const Icon(Icons.near_me),
        ),
      ),
    );
  }
}
