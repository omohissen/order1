import 'package:json_annotation/json_annotation.dart';

part 'gateway.g.dart';

@JsonSerializable()
class Gateway {
  String id;

  String? title;

  String? description;

  bool enabled;

  Gateway({
    required this.id,
    this.title,
    this.description,
    required this.enabled,
  });

  factory Gateway.fromJson(Map<String, dynamic> json) => _$GatewayFromJson(json);

  Map<String, dynamic> toJson() => _$GatewayToJson(this);
}
