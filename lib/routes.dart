import 'package:flutter/material.dart';

import 'package:cirilla/store/store.dart';
import 'package:cirilla/screens/screens.dart';

///
/// Define route
class Routes {
  Routes._();

  static routes(SettingStore store) => <String, WidgetBuilder>{
        HomeScreen.routeName: (context) => HomeScreen(store: store),

        // Auth
        LoginScreen.routeName: (context) => LoginScreen(store: store),
        RegisterScreen.routeName: (context) => RegisterScreen(store: store),
        ForgotScreen.routeName: (context) => const ForgotScreen(),
        LoginMobileScreen.routeName: (context) => LoginMobileScreen(),

        // On Boarding
        OnBoardingScreen.routeName: (context) => OnBoardingScreen(store: store),

        // Ask permission
        AllowLocationScreen.routeName: (context) => AllowLocationScreen(store: store),

        Checkout.routeName: (context) => const Checkout(),
        CheckoutWebView.routeName: (context) => const CheckoutWebView(),

        AccountScreen.routeName: (context) => const AccountScreen(),
        EditAccountScreen.routeName: (context) => const EditAccountScreen(),
        ChangePasswordScreen.routeName: (context) => const ChangePasswordScreen(),
        AddressBookScreen.routeName: (context) => const AddressBookScreen(),
        AddressShippingScreen.routeName: (context) => const AddressShippingScreen(),
        HelpInfoScreen.routeName: (context) => HelpInfoScreen(store: store),
        SettingScreen.routeName: (context) => const SettingScreen(),
        OrderListScreen.routeName: (context) => const OrderListScreen(),
        ContactScreen.routeName: (context) => ContactScreen(store: store),
        DownloadScreen.routeName: (context) => const DownloadScreen(),
        WalletScreen.routeName: (context) => const WalletScreen(),

        BrandListScreen.routeName: (context) => BrandListScreen(store: store),
        LocationScreen.routeName: (context) => LocationScreen(store: store),
        FormAddressScreen.routeName: (context) => FormAddressScreen(store: store),
        SelectLocationScreen.routeName: (context) => SelectLocationScreen(store: store),

        ChatListScreen.routeName: (context) => ChatListScreen(store: store),
        ChatDetailScreen.routeName: (context) => ChatDetailScreen(store: store),
      };

  static onGenerateRoute(dynamic settings, SettingStore store) {
    Uri uri = Uri.parse(settings.name);

    // Temporary fix for callback verify login OTP and Facebook
    if (uri.hasQuery && uri.queryParameters['deep_link_id'] != null) {
      return null;
    }

    String? name = uri.pathSegments.length > 1 ? "/${uri.pathSegments[0]}" : settings.name;
    dynamic args = uri.pathSegments.length > 1 ? {'id': uri.pathSegments[1]} : settings.arguments;

    return MaterialPageRoute(
      builder: (context) {
        switch (name) {
          case PostScreen.routeName:
            return PostScreen(store: store, args: args);
          case PostListScreen.routeName:
            return PostListScreen(store: store, args: args);
          case PostAuthorScreen.routeName:
            return PostAuthorScreen(args: args);
          case ProductListScreen.routeName:
            return ProductListScreen(store: store, args: args);
          case ProductScreen.routeName:
            return ProductScreen(store: store, args: args);
          case WebViewScreen.routeName:
            return WebViewScreen(args: args);
          case PageScreen.routeName:
            return PageScreen(args: args);
          case CustomScreen.routeName:
            return CustomScreen(screenKey: args['key']);
          case NotificationList.routeName:
            return const NotificationList();
          case NotificationDetail.routeName:
            return NotificationDetail(args: args);
          case VendorScreen.routeName:
            return VendorScreen(store: store, args: args);
          case OrderDetailScreen.routeName:
            return OrderDetailScreen(args: args);
          default:
            return const NotFound();
        }
      },
    );
  }
}
