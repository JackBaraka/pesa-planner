import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class KenyanPhoneField extends StatelessWidget {
  final TextEditingController controller;

  const KenyanPhoneField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InternationalPhoneNumberInput(
      onInputChanged: (PhoneNumber number) {},
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.DROPDOWN,
      ),
      initialValue: PhoneNumber(isoCode: 'KE'),
      textFieldController: controller,
      formatInput: false,
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      inputDecoration: const InputDecoration(
        labelText: 'Phone Number',
        border: OutlineInputBorder(),
      ),
    );
  }
}
