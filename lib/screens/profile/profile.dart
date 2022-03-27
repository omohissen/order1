import 'package:cirilla/constants/constants.dart';
import 'package:cirilla/mixins/app_bar_mixin.dart';
import 'package:cirilla/mixins/utility_mixin.dart';
import 'package:cirilla/models/setting/setting.dart';
import 'package:cirilla/screens/profile/widgets/icon_notification.dart';
import 'package:cirilla/store/store.dart';
import 'package:cirilla/types/types.dart';
import 'package:cirilla/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import 'widgets/profile_content_login.dart';
import 'widgets/profile_content_logout.dart';
import 'widgets/profile_footer.dart';

const enableLogin = false;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with Utility, AppBarMixin {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  late AppStore _appStore;
  late SettingStore _settingStore;
  late AuthStore _authStore;
  CountryStore? _countryStore;
  AddressFieldStore? _addressFieldStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appStore = Provider.of<AppStore>(context);
    _settingStore = Provider.of<SettingStore>(context);
    _authStore = Provider.of<AuthStore>(context);

    String keyCountry = 'country_list';
    String keyAddressField = 'address_fields_${_settingStore.locale}';
    if (_appStore.getStoreByKey(keyCountry) == null) {
      CountryStore store = CountryStore(_settingStore.requestHelper, key: keyCountry)..getCountry();
      _appStore.addStore(store);
      _countryStore ??= store;
    } else {
      _countryStore = _appStore.getStoreByKey(keyCountry);
    }
    if (_appStore.getStoreByKey(keyAddressField) == null) {
      AddressFieldStore store = AddressFieldStore(_settingStore.requestHelper, key: keyAddressField)
        ..getAddressField(queryParameters: {
          'lang': _settingStore.locale,
        });
      _appStore.addStore(store);
      _addressFieldStore ??= store;
    } else {
      _addressFieldStore = _appStore.getStoreByKey(keyAddressField);
    }
  }

  void logout() async {
    bool isLogout = await _authStore.logout();
    avoidPrint(isLogout);
  }

  void showMessage({String? message}) {
    scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          color: Colors.green,
        ),
        margin: secondPaddingSmall,
        padding: secondPaddingSmall,
        height: 40,
        child: Center(child: Text(message ?? '')),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    TranslateType translate = AppLocalizations.of(context)!.translate;

    String title = enableLogin ? translate('profile_account_txt') : translate('profile_txt');
    String languageKey = _settingStore.languageKey;

    WidgetConfig widgetConfig = _settingStore.data!.screens!['profile']!.widgets!['profilePage']!;
    Map<String, dynamic>? fields = widgetConfig.fields;

    bool enableDownload = get(fields, ['enableDownload'], true);
    bool? enableHelpInfo = get(fields, ['enableHelpInfo'], true);
    bool? enablePhone = get(fields, ['enablePhone'], true);
    bool enableWallet = get(fields, ['enableWallet'], true);
    String? textCopyRight = get(fields, ['textCopyRight', languageKey], '© Cirrilla 2020');
    String? phone = get(fields, ['phone', languageKey], '0123456789');
    List? socials = get(fields, ['itemSocial'], []);

    // Padding
    Map<String, dynamic>? _padding = get(widgetConfig.styles, ['padding']);
    EdgeInsetsDirectional padding = _padding != null ? ConvertData.space(_padding, 'padding') : defaultScreenPadding;

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: baseStyleAppBar(
          context,
          title: title,
          automaticallyImplyLeading: false,
          actions: [
            IconNotification(store: _authStore),
          ],
        ),
        body: SingleChildScrollView(
          padding: padding,
          child: SizedBox(
              width: double.infinity,
              child: Observer(
                builder: (_) => _authStore.isLogin
                    ? ProfileContentLogin(
                        logout: logout,
                        user: _authStore.user,
                        enablePhone: enablePhone,
                        phone: phone,
                        enableWallet: enableWallet,
                        enableHelpInfo: enableHelpInfo,
                        enableDownload: enableDownload,
                        footer: ProfileFooter(
                          copyright: textCopyRight,
                          socials: socials,
                        ),
                      )
                    : ProfileContentLogout(
                        showMessage: showMessage,
                        enablePhone: enablePhone,
                        phone: phone,
                        enableHelpInfo: enableHelpInfo,
                        footer: ProfileFooter(
                          copyright: textCopyRight,
                          socials: socials,
                        ),
                      ),
              )),
        ),
      ),
    );
  }
}
