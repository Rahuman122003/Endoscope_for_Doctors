// lib/models/user_profile.dart

class UserProfile {
  String uhid;
  String drFullname;
  String email;
  String hospitalname;
  String hospitalAddress;
  String contactNumber;
  String logoUrl;
  String signatureImage;

  UserProfile({
    required this.uhid,
    required this.drFullname,
    required this.email,
    required this.hospitalname,
    required this.hospitalAddress,
    required this.contactNumber,
    required this.logoUrl,
    required this.signatureImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'uhid': uhid,
      'drFullname': drFullname,
      'email': email,
      'hospitalname':hospitalname,
      'hospitalAddress': hospitalAddress,
      'contactNumber': contactNumber,
      'logoUrl': logoUrl,
      'signatureImage': signatureImage,
    };
  }

  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uhid: json['uhid'],
      drFullname: json['drFullname'],
      email: json['email'],
      hospitalname: json['hospitalname'],
      hospitalAddress: json['hospitalAddress'],
      contactNumber: json['contactNumber'],
      logoUrl: json['logoUrl'],
      signatureImage: json['signatureImage'],
    );
  }
}
