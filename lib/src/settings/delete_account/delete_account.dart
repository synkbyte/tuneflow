import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/src/settings/delete_account/delete_account_field.dart';
import 'package:new_tuneflow/src/settings/providers/delete_account_provider.dart';
import 'package:page_transition/page_transition.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  String value = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delete Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Gap(10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: deleteAccountReasons.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return RadioListTile(
                  contentPadding: EdgeInsets.zero,
                  value: deleteAccountReasons[index],
                  onChanged: (value) {
                    setState(() => this.value = value!);
                  },
                  groupValue: value,
                  title: Text(
                    deleteAccountReasons[index],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          value.isEmpty
              ? null
              : Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).padding.bottom + 10,
                  top: 10,
                ),
                child: PrimaryButton(
                  title: 'Continue',
                  onPressed: () {
                    context.read<DeleteAccountProvider>().setReason(value);
                    Navigator.push(
                      context,
                      PageTransition(
                        child: DeleteAccountField(),
                        type: PageTransitionType.fade,
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
