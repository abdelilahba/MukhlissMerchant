import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/features/offers/presentation/managers/offer_manager.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

class OfferForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;
  final OfferManager manager;

  const OfferForm({
    required this.formKey,
    required this.onSubmit,
    required this.manager,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: manager.amountController,
            decoration:  InputDecoration(labelText:l10n.mantant),
            validator: (value) => value?.isEmpty ?? true ? l10n.requis : null,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: manager.pointsController,
            decoration:  InputDecoration(labelText:l10n.point ),
            validator: (value) => value?.isEmpty ?? true ?l10n.requis  : null,
            keyboardType: TextInputType.number,
          ),
         
        ],
      ),
    );
  }
}