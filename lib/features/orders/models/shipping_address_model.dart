class ShippingAddressModel {
  final String fullName;
  final String phone;
  final String street;
  final String? apartment;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;

  ShippingAddressModel({
    required this.fullName,
    required this.phone,
    required this.street,
    this.apartment,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'Egypt',
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'street': street,
      'apartment': apartment,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      street: json['street'] as String? ?? '',
      apartment: json['apartment'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      country: json['country'] as String? ?? 'Egypt',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  String get fullAddress {
    final parts = [
      street,
      if (apartment != null && apartment!.isNotEmpty) apartment,
      city,
      state,
      postalCode,
      country,
    ];
    return parts.join(', ');
  }

  bool get isValid {
    return fullName.isNotEmpty &&
        phone.isNotEmpty &&
        street.isNotEmpty &&
        city.isNotEmpty &&
        state.isNotEmpty &&
        postalCode.isNotEmpty;
  }
}
