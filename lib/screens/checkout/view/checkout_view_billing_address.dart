import 'package:cirilla/constants/styles.dart';
import 'package:cirilla/mixins/loading_mixin.dart';
import 'package:cirilla/screens/profile/widgets/address_field_form2.dart';
import 'package:cirilla/types/types.dart';
import 'package:cirilla/utils/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:cirilla/store/store.dart';

class CheckoutViewBillingAddress extends StatefulWidget {
  final CartStore cartStore;
  final AddressFieldStore addressFieldStore;
  final CountryStore countryStore;

  const CheckoutViewBillingAddress({
    Key? key,
    required this.cartStore,
    required this.addressFieldStore,
    required this.countryStore,
  }) : super(key: key);

  @override
  State<CheckoutViewBillingAddress> createState() => _CheckoutViewBillingAddressState();
}

class _CheckoutViewBillingAddressState extends State<CheckoutViewBillingAddress> with LoadingMixin {
  final _formBillingKey = GlobalKey<FormState>();

  Map<String, dynamic> convertFields(Map<String, dynamic> data, TranslateType translate) {
    Map<String, dynamic> result = {...data};
    dynamic defaultValue = result['default'];
    dynamic dataDefault = defaultValue is Map<String, dynamic> ? {...defaultValue} : {};
    if (dataDefault is Map) {
      Map<String, dynamic> valueAdd = {
        'email': <String, dynamic>{
          "type": "email",
          "label": translate('address_email'),
          "required": true,
          "class": ["form-row-wide", "address-field"],
          "validate": ["email"],
          "autocomplete": "email",
          "priority": 999,
        },
        'phone': {
          "type": "phone",
          "label": translate('address_phone'),
          "required": true,
          "class": ["form-row-wide", "address-field"],
          "validate": ["phone"],
          "autocomplete": "phone",
          "priority": 1000,
        },
      };
      dataDefault.addAll(valueAdd);
      result.addAll({
        'default': <String, dynamic>{
          ...dataDefault as Map<String, dynamic>,
        }
      });
    }
    return result;
  }

  void onChanged(Map<String, dynamic> value) {
    widget.cartStore.checkoutStore.changeAddress(
      billing: value,
      shipping: widget.cartStore.checkoutStore.shipToDifferentAddress ? null : value,
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TranslateType translate = AppLocalizations.of(context)!.translate;
    return Observer(
      builder: (_) {
        Map<String, dynamic> billing = {
          ...?widget.cartStore.cartData?.billingAddress,
          ...widget.cartStore.checkoutStore.billingAddress,
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(translate('checkout_billing_detail'), style: theme.textTheme.headline6),
            Padding(
              padding: paddingVerticalMedium,
              child: widget.addressFieldStore.loading
                  ? entryLoading(context)
                  : AddressFieldForm2(
                      formKey: _formBillingKey,
                      data: billing,
                      addressFields: convertFields(widget.addressFieldStore.addressFields, translate),
                      countries: widget.countryStore.country,
                      onChanged: onChanged,
                    ),
            )
          ],
        );
      },
    );
  }
}
