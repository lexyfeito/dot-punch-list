import '../model.interface.dart';

class SettingsModel extends Model {
  bool disclaimerClosed;

  SettingsModel(Id, {this.disclaimerClosed}): super(Id);

  factory SettingsModel.fromJson(Map<String, dynamic> map) => new SettingsModel(
      map["id"],
      disclaimerClosed: map["disclaimerClosed"] == 1
  );

  @override
  Map<String, dynamic> toJson() => {
    "id": Id,
    "disclaimerClosed": disclaimerClosed
  };
}