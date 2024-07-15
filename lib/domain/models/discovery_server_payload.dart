class DiscoveryServerPayloadModel {
  String ipAddress;
  int port;

  DiscoveryServerPayloadModel.fromJson(Map<String, dynamic> json)
      : ipAddress = json['ip_address'],
        port = int.parse(json['port']);
}
