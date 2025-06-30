import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/features/offers/presentation/managers/offer_manager.dart';

class OfferForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;
  final OfferManager manager;

  const OfferForm({
    required this.formKey,
    required this.onSubmit,
    required this.manager,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: manager.amountController,
            decoration: const InputDecoration(labelText: 'Montant (DH)'),
            validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: manager.pointsController,
            decoration: const InputDecoration(labelText: 'Points'),
            validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
            keyboardType: TextInputType.number,
          ),
         
        ],
      ),
    );
  }
}