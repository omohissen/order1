import 'package:cirilla/constants/constants.dart';
import 'package:cirilla/mixins/app_bar_mixin.dart';
import 'package:cirilla/mixins/loading_mixin.dart';
import 'package:cirilla/mixins/snack_mixin.dart';
import 'package:cirilla/mixins/transition_mixin.dart';
import 'package:cirilla/screens/checkout/gateway/gateway.dart';
import 'package:cirilla/screens/checkout/view/checkout_view_shipping_methods.dart';
import 'package:cirilla/store/store.dart';
import 'package:cirilla/themes/default/checkout/payment_method.dart';
import 'package:cirilla/themes/default/default.dart';
import 'package:cirilla/types/types.dart';
import 'package:cirilla/utils/utils.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import 'view/checkout_view_cart_totals.dart';
import 'view/checkout_view_shipping_methods.dart';
import 'view/checkout_view_billing_address.dart';
import 'view/checkout_view_shipping_address.dart';
import 'view/checkout_view_ship_to_different_address.dart';

List<IconData> _tabIcons = [FeatherIcons.mapPin, FeatherIcons.pocket, FeatherIcons.check];

class Checkout extends StatefulWidget {
  static const routeName = '/checkout';

  const Checkout({Key? key}) : super(key: key);

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> with TickerProviderStateMixin, TransitionMixin, SnackMixin, LoadingMixin {
  late TabController _tabController;
  int visit = 0;
  int? success;

  late AppStore _appStore;
  late SettingStore _settingStore;
  late CartStore _cartStore;
  late CountryStore _countryStore;
  late AddressFieldStore _addressFieldStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appStore = Provider.of<AppStore>(context);
    _settingStore = Provider.of<SettingStore>(context);
    _cartStore = Provider.of<CartStore>(context)..paymentStore.getGateways();

    String keyCountry = 'country_list';
    String keyAddressField = 'address_fields_${_settingStore.locale}';
    if (_appStore.getStoreByKey(keyCountry) == null) {
      CountryStore store = CountryStore(_settingStore.requestHelper, key: keyCountry)..getCountry();
      _appStore.addStore(store);
      _countryStore = store;
    } else {
      _countryStore = _appStore.getStoreByKey(keyCountry);
    }
    if (_appStore.getStoreByKey(keyAddressField) == null) {
      AddressFieldStore store = AddressFieldStore(_settingStore.requestHelper, key: keyAddressField)
        ..getAddressField(queryParameters: {
          'lang': _settingStore.locale,
        });
      _appStore.addStore(store);
      _addressFieldStore = store;
    } else {
      _addressFieldStore = _appStore.getStoreByKey(keyAddressField);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabIcons.length, vsync: this);
    _tabController.addListener(() {
      if (visit != _tabController.index) {
        setState(() {
          visit = _tabController.index;
        });
      }
    });
  }

  void onGoPage(int visit, [int? visitSuccess]) {
    if (visit == 2) {
      _cartStore.getCart();
    }
    _tabController.animateTo(visit);
    setState(() {
      success = visitSuccess;
    });
  }

  void handlePayment(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: borderRadiusBottomSheet,
      ),
      builder: (context) {
        MediaQueryData mediaQuery = MediaQuery.of(context);
        return SizedBox(
          height: mediaQuery.size.height - 100,
          child: ModalPaymentCheckout(
            onConfirm: () {
              Navigator.pop(context);
              setState(() {
                success = 1;
              });
            },
          ),
        );
      },
    );
  }

  void _preCheckoutProgress(BuildContext context) async {
    try {
      if (_cartStore.paymentStore.method == "stripe") {
        String source = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, _a1, _a2) => const StripeGateway(),
            transitionsBuilder: slideTransition,
          ),
        );
        Map<String, dynamic> billing = {
          ...?_cartStore.cartData?.billingAddress,
          ..._cartStore.checkoutStore.billingAddress,
        };
        List<dynamic> paymentData = [
          {"key": "stripe_source", "value": source},
          {"key": "billing_email", "value": billing['email']},
          {"key": "billing_first_name", "value": billing['first_name']},
          {"key": "billing_last_name", "value": billing['last_name']},
          {"key": "paymentMethod", "value": "stripe"},
          {"key": "paymentRequestType", "value": "cc"},
          {"key": "wc-stripe-new-payment-method", "value": true}
        ];
        await _cartStore.checkoutStore.checkout(paymentData);
        onGoPage(2, 2);
      } else {
        dynamic data = await _cartStore.checkoutStore.checkout([]);
        if (['bacs', 'cod', 'cheque'].contains(data['payment_method'])) {
          onGoPage(2, 2);
        } else {
          String result = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, _a1, _a2) => PaymentProgress(data: data),
              transitionsBuilder: slideTransition,
            ),
          );
          if (result == 'done') {
            onGoPage(2, 2);
          }
        }
      }
    } catch (e) {
      showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TranslateType translate = AppLocalizations.of(context)!.translate;
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double padTop = mediaQuery.padding.top > 0 ? mediaQuery.padding.top : 30;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              TabbarView(
                icons: _tabIcons,
                visit: visit,
                isVisitSuccess: success == visit,
                padding: paddingHorizontal.add(EdgeInsets.only(top: padTop)),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    StepAddress(
                      totals: CheckoutViewCartTotals(cartStore: _cartStore),
                      shippingMethods: CheckoutViewShippingMethods(cartStore: _cartStore),
                      address: Column(
                        children: [
                          CheckoutViewBillingAddress(
                            cartStore: _cartStore,
                            countryStore: _countryStore,
                            addressFieldStore: _addressFieldStore,
                          ),
                          CheckoutViewShipToDifferentAddress(
                            checkoutStore: _cartStore.checkoutStore,
                          ),
                          CheckoutViewShippingAddress(
                            cartStore: _cartStore,
                            countryStore: _countryStore,
                            addressFieldStore: _addressFieldStore,
                          )
                        ],
                      ),
                      padding: paddingVerticalLarge,
                      bottomWidget: buildBottom(
                        start: buildButton(
                          title: translate('checkout_back'),
                          secondary: true,
                          theme: theme,
                          onPressed: () => Navigator.pop(context),
                        ),
                        end: buildButton(
                          title: translate('checkout_payment'),
                          theme: theme,
                          onPressed: () => onGoPage(1, 0),
                        ),
                        theme: theme,
                      ),
                    ),
                    success == 1
                        ? StepFormPayment(onPayment: () => onGoPage(2, 2))
                        : StepPayment(
                            paymentMethod: Observer(
                              builder: (_) => PaymentMethod(
                                padHorizontal: layoutPadding,
                                gateways: _cartStore.paymentStore.gateways,
                                active: _cartStore.paymentStore.active,
                                select: _cartStore.paymentStore.select,
                              ),
                            ),
                            padding: paddingVerticalLarge,
                            bottomWidget: buildBottom(
                              start: buildButton(
                                title: translate('checkout_back'),
                                secondary: true,
                                theme: theme,
                                onPressed: () => onGoPage(0, null),
                              ),
                              end: buildButton(
                                title: translate('checkout_payment'),
                                theme: theme,
                                onPressed: () => _preCheckoutProgress(context),
                              ),
                              theme: theme,
                            ),
                          ),
                    const StepSuccess(),
                  ],
                ),
              ),
            ],
          ),
          Observer(
            builder: (_) => _cartStore.checkoutStore.loading
                ? Align(
                    child: buildLoadingOverlay(context),
                    alignment: FractionalOffset.center,
                  )
                : const SizedBox(),
          )
        ],
      ),
    );
  }

  Widget buildBottom({
    required Widget start,
    required Widget end,
    required ThemeData theme,
  }) {
    return Container(
      padding: paddingVerticalMedium.add(paddingHorizontal),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: initBoxShadow,
      ),
      child: Row(
        children: [
          Expanded(child: start),
          const SizedBox(width: itemPaddingMedium),
          Expanded(child: end),
        ],
      ),
    );
  }

  Widget buildButton({
    required String title,
    bool secondary = false,
    VoidCallback? onPressed,
    required ThemeData theme,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        child: isLoading ? entryLoading(context, color: Theme.of(context).colorScheme.onPrimary) : Text(title),
        onPressed: isLoading ? () => {} : onPressed,
        style: secondary
            ? ElevatedButton.styleFrom(
                primary: theme.colorScheme.surface,
                onPrimary: theme.textTheme.subtitle1?.color,
              )
            : null,
      ),
    );
  }
}

class PaymentProgress extends StatelessWidget with AppBarMixin {
  final dynamic data;

  const PaymentProgress({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget method = Text('${data['payment_method']} not improvement on mobile app.');

    if ('paypal' == data['payment_method']) {
      method = PaypalGateway(data: data);
    } else if ('razorpay' == data['payment_method']) {
      method = RazorpayGateway(data: data);
    }
    return Scaffold(
      appBar: baseStyleAppBar(context, title: 'Payment'),
      body: SafeArea(
        child: method,
      ),
    );
  }
}
