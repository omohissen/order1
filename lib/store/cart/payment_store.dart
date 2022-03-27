import 'package:cirilla/models/cart/gateway.dart';
import 'package:cirilla/service/helpers/request_helper.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';

part 'payment_store.g.dart';

class PaymentStore = _PaymentStore with _$PaymentStore;

abstract class _PaymentStore with Store {
  final RequestHelper _requestHelper;

  // Constructor: ------------------------------------------------------------------------------------------------------
  _PaymentStore(this._requestHelper) {
    _init();
    _reaction();
  }

  Future<void> _init() async {}

  // Observable: -------------------------------------------------------------------------------------------------------
  @observable
  bool loading = false;

  @observable
  int active = 0;

  @observable
  ObservableList<Gateway> gateways = ObservableList<Gateway>.of([]);

  @computed
  String get method => gateways.isNotEmpty ? gateways[active].id : '';

  // Action: -----------------------------------------------------------------------------------------------------------
  @action
  Future<void> getGateways() async {
    try {
      loading = true;
      List<dynamic> data = await _requestHelper.gateways();
      List<Gateway> _gatewaysEnable = data.map((g) => Gateway.fromJson(g)).toList().cast<Gateway>();
      gateways = ObservableList<Gateway>.of(_gatewaysEnable.where((element) => element.enabled).toList());
      loading = false;
    } on DioError {
      loading = false;
      rethrow;
    }
  }

  @action
  void select(int index) {
    if (index > -1) {
      active = index;
    }
  }

  // disposers:---------------------------------------------------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _reaction() {
    _disposers = [];
  }

  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
