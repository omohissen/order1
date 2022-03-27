import 'package:cirilla/constants/styles.dart';
import 'package:cirilla/mixins/loading_mixin.dart';
import 'package:cirilla/screens/profile/widgets/address_field_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:cirilla/store/store.dart';

class CheckoutViewShippingAddress extends StatefulWidget {
  final CartStore cartStore;
  final AddressFieldStore addressFieldStore;
  final CountryStore countryStore;

  const CheckoutViewShippingAddress({
    Key? key,
    required this.cartStore,
    required this.addressFieldStore,
    required this.countryStore,
  }) : super(key: key);

  @override
  State<CheckoutViewShippingAddress> createState() => _CheckoutViewShippingAddressState();
}

class _CheckoutViewShippingAddressState extends State<CheckoutViewShippingAddress> with LoadingMixin {
  final _formShippingKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => widget.cartStore.checkoutStore.shipToDifferentAddress
          ? Padding(
              padding: paddingVerticalMedium,
              child: widget.addressFieldStore.loading
                  ? entryLoading(context)
                  : AddressFieldForm(
                      formKey: _formShippingKey,
                      data: widget.cartStore.cartData?.shippingAddress,
                      addressFields: widget.addressFieldStore.addressFields,
                      countries: widget.countryStore.country,
                      changeValue: (String key, String value) {},
                    ),
            )
          : Container(),
    );
  }
}
