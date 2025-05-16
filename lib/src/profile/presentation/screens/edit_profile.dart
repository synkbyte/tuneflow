// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/models/user_model.dart';
import 'package:new_tuneflow/core/common/providers/user_provider.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/services/api_service/app/upload_api_service.dart';
import 'package:new_tuneflow/core/services/api_service/user/user_api_service.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  File? pickedImage;
  final key = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController emailAddress = TextEditingController();
  TextEditingController bio = TextEditingController();

  UserApiService userApiService = sl();
  UploadApiService uploadApiService = sl();

  bool isLoading = false;
  bool isInit = true;
  setUpInitialDetails(UserModel userDetails) {
    name.text = userDetails.name;
    userName.text = (userDetails.userName ?? '').replaceAll('@', '');
    phoneNumber.text = userDetails.phone ?? '';
    emailAddress.text = userDetails.email ?? '';
    bio.text = userDetails.bio;
    isInit = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme scheme = Theme.of(context).colorScheme;
    final userProvider = Provider.of<UserProvider>(context);
    if (isInit) {
      setUpInitialDetails(userProvider.userModel!);
    }

    return Scaffold(
      backgroundColor: scheme.surface.withValues(alpha: 0.5),
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 5),
        decoration: BoxDecoration(
          color: scheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 40,
              color: scheme.primary,
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView(
            children: [
              Form(
                key: key,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (userProvider.userModel!.avatar == null ||
                        pickedImage != null)
                      GestureDetector(
                        onTap: () async {
                          pickedImage = await pickImage();
                          setState(() {});
                        },
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: pickedImage == null
                              ? null
                              : FileImage(File(pickedImage!.path)),
                          child: pickedImage == null
                              ? const Text(
                                  'Select Image',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : null,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () async {
                          pickedImage = await pickImage();
                          setState(() {});
                        },
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: CachedNetworkImageProvider(
                            userProvider.userModel!.avatar!,
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor:
                                context.primary.withValues(alpha: .5),
                            child: const CircleAvatar(
                              radius: 15,
                              child: Icon(
                                Icons.edit,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter full name';
                          } else if (value.length < 3) {
                            return 'Enter valid name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          labelText: 'Full name',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: userName,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username cannot be empty';
                          } else if (value.length < 4) {
                            return 'Username must be at least 4 characters long';
                          } else if (!RegExp(r'^[a-zA-Z0-9_.-]+(?<![.-])$')
                              .hasMatch(value)) {
                            return 'Username can only contain letters, numbers, underscores, periods, and hyphens. It cannot start or end with a period or hyphen.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          labelText: 'Username',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: phoneNumber,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number cannot be empty';
                          } else {
                            RegExp phoneRegex = RegExp(r'^[0-9]+$');
                            if (!phoneRegex.hasMatch(value)) {
                              return 'Enter a valid phone number';
                            }
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          labelText: 'Phone number',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email address cannot be empty';
                          } else {
                            RegExp emailRegex =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          labelText: 'Email address',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: bio,
                        maxLines: 5,
                        minLines: 1,
                        validator: (value) {
                          if (value == null || value.length < 10) {
                            return 'Bio must be at least 10 characters long';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          labelText: 'Bio',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: PrimaryButton(
                        title: 'Update Profile',
                        isLoading: isLoading,
                        onPressed: () async {
                          if (key.currentState!.validate()) {
                            setState(() => isLoading = true);

                            String? imageUrl;
                            if (pickedImage != null) {
                              DefaultResponse res =
                                  await uploadApiService.uploadFile(
                                pickedImage!.path,
                              );
                              if (res.status) {
                                imageUrl = res.value;
                              }
                            }

                            DefaultResponse response =
                                await userApiService.updateProfile(
                              id: userProvider.userModel!.id,
                              name: name.text,
                              phone: phoneNumber.text,
                              email: emailAddress.text,
                              userName: userName.text,
                              bio: bio.text,
                              avatar: imageUrl,
                            );

                            setState(() => isLoading = false);

                            if (!response.status) {
                              errorMessage(context, response.message);
                              return;
                            }

                            userProvider.initializeUser();

                            successMessage(context, response.message);
                            Navigator.pop(context);
                          }
                        },
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
