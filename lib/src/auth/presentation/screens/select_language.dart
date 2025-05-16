import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/user_provider.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';
import 'package:new_tuneflow/src/auth/domain/usecase/language_usecase.dart';
import 'package:new_tuneflow/src/auth/presentation/bloc/artist_bloc.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/select_artist.dart';
import 'package:new_tuneflow/src/support/presentation/screens/support.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({
    super.key,
    this.isNewUser = true,
    this.languageList,
  });
  final bool isNewUser;
  final List<LanguageModel>? languageList;

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  TextEditingController controller = TextEditingController();
  List<LanguageModel> selectedLanguage = [];
  bool isFiltered = false;
  bool isLoading = false;
  List<LanguageModel> filteredLanguage = [];

  filterLanguage(String value) {
    if (value.isEmpty) {
      setState(() {
        isFiltered = false;
        filteredLanguage = [];
      });
      return;
    }
    filteredLanguage =
        languageList
            .where((language) => language.name.toLowerCase().contains(value))
            .toList();
    setState(() => isFiltered = true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateInitUser();
    });
  }

  updateInitUser() {
    if (!widget.isNewUser) {
      selectedLanguage = widget.languageList ?? [];
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            if (Platform.isAndroid) const SizedBox(height: 20),
            const Text(
              'Your Music, Your Language',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Text(
              'Discover a Multilingual Melody: Set and Enjoy Your Preferred Languages.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: controller,
              onChanged: (value) {
                filterLanguage(value.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Search your language',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isFiltered && filteredLanguage.isEmpty)
              Center(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 15),
                    children: [
                      const TextSpan(
                        text:
                            'Oops! 😔 The language you\'re looking for isn\'t available in $appName at the moment. ',
                      ),
                      TextSpan(
                        text: 'Click here',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: const SupportScreen(),
                                    type: PageTransitionType.fade,
                                  ),
                                );
                              },
                      ),
                      const TextSpan(
                        text:
                            ' to request your preferred language, and we\'ll do our best to add it soon!',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.separated(
                  itemCount:
                      isFiltered
                          ? filteredLanguage.length
                          : languageList.length,
                  itemBuilder: (context, index) {
                    LanguageModel item =
                        isFiltered
                            ? filteredLanguage[index]
                            : languageList[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        if (isThisLang(item)) {
                          selectedLanguage.removeWhere(
                            (element) => element.id == item.id,
                          );
                        } else {
                          selectedLanguage.add(item);
                        }
                        setState(() {});
                      },
                      child: Container(
                        height: 55,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:
                              isThisLang(item)
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Colors.transparent,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isThisLang(item)
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                              ),
                            ),
                            const Spacer(),
                            if (isThisLang(item))
                              Icon(
                                Ionicons.checkmark_circle,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          selectedLanguage.isEmpty
              ? null
              : Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: MediaQuery.of(context).padding.bottom + 10,
                  left: 20,
                  right: 20,
                ),
                child: PrimaryButton(
                  title: 'Continue',
                  isLoading: isLoading,
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (isLoading) return;

                    setState(() => isLoading = true);
                    List userSelectedLanguages =
                        selectedLanguage.map((e) => e.toMap()).toList();
                    LanguageUseCase useCase = sl();
                    DataState state = await useCase.call(
                      id: Cache.instance.userId,
                      languages: userSelectedLanguages,
                    );

                    bool hasAnyError = hasAnyErrors(state);
                    if (hasAnyError) {
                      return;
                    }

                    SignupEntity entity = state.data;
                    await CacheHelper().saveSelectedUserLanguages(
                      userSelectedLanguages,
                    );
                    navigateUser(entity);
                  },
                ),
              ),
    );
  }

  bool hasAnyErrors(DataState state) {
    if (state is DataError) {
      errorMessage(context, state.error!);
      setState(() => isLoading = false);
      return true;
    }

    SignupEntity entity = state.data;
    if (!entity.status) {
      errorMessage(context, entity.message);
      setState(() => isLoading = false);
      return true;
    }

    return false;
  }

  navigateUser(SignupEntity entity) {
    Provider.of<UserProvider>(context, listen: false).initializeUser();
    setState(() => isLoading = false);
    context.read<ArtistBloc>().add(ArtistGetTop());
    if (widget.isNewUser) {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          child: const SelectArtistScreen(),
          type: PageTransitionType.fade,
        ),
        (route) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  bool isThisLang(LanguageModel model) {
    LanguageModel? has = selectedLanguage.firstWhereOrNull(
      (e) => e.id == model.id,
    );
    return has != null;
  }
}
