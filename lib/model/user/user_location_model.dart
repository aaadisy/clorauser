class UserLocationModel {
  String? ip;
  String? network;
  String? version;
  String? city;
  String? region;
  String? regionCode;
  String? country;
  String? countryName;
  String? countryCode;
  String? countryCodeIso3;
  String? countryCapital;
  String? countryTld;
  String? continentCode;
  bool? inEu;
  String? postal;
  double? latitude;
  double? longitude;
  String? timezone;
  String? utcOffset;
  String? countryCallingCode;
  String? currency;
  String? currencyName;
  String? languages;
  String? asn;
  String? org;

  UserLocationModel(
      {this.ip,
      this.network,
      this.version,
      this.city,
      this.region,
      this.regionCode,
      this.country,
      this.countryName,
      this.countryCode,
      this.countryCodeIso3,
      this.countryCapital,
      this.countryTld,
      this.continentCode,
      this.inEu,
      this.postal,
      this.latitude,
      this.longitude,
      this.timezone,
      this.utcOffset,
      this.countryCallingCode,
      this.currency,
      this.currencyName,
      this.languages,
      this.asn,
      this.org});

  UserLocationModel.fromJson(Map<String, dynamic> json) {
    ip = json['ip'];
    network = json['network'];
    version = json['version'];
    city = json['city'];
    region = json['region'];
    regionCode = json['region_code'];
    country = json['country'];
    countryName = json['country_name'];
    countryCode = json['country_code'];
    countryCodeIso3 = json['country_code_iso3'];
    countryCapital = json['country_capital'];
    countryTld = json['country_tld'];
    continentCode = json['continent_code'];
    inEu = json['in_eu'];
    postal = json['postal'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    timezone = json['timezone'];
    utcOffset = json['utc_offset'];
    countryCallingCode = json['country_calling_code'];
    currency = json['currency'];
    currencyName = json['currency_name'];
    languages = json['languages'];
    asn = json['asn'];
    org = json['org'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ip'] = this.ip;
    data['network'] = this.network;
    data['version'] = this.version;
    data['city'] = this.city;
    data['region'] = this.region;
    data['region_code'] = this.regionCode;
    data['country'] = this.country;
    data['country_name'] = this.countryName;
    data['country_code'] = this.countryCode;
    data['country_code_iso3'] = this.countryCodeIso3;
    data['country_capital'] = this.countryCapital;
    data['country_tld'] = this.countryTld;
    data['continent_code'] = this.continentCode;
    data['in_eu'] = this.inEu;
    data['postal'] = this.postal;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['timezone'] = this.timezone;
    data['utc_offset'] = this.utcOffset;
    data['country_calling_code'] = this.countryCallingCode;
    data['currency'] = this.currency;
    data['currency_name'] = this.currencyName;
    data['languages'] = this.languages;
    data['asn'] = this.asn;
    data['org'] = this.org;
    return data;
  }
}
