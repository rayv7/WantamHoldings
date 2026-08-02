import '../models/customer.dart';

class UserStore {
  static String name = '';
  static String email = '';
  static String phone = '';
  static String branch = '';

  static String get firstName => name.split(' ').first;

  static CustomerModel toCustomer() => CustomerModel(
        name: name,
        email: email,
        phone: phone,
        branch: branch,
      );

  static void clear() {
    name = '';
    email = '';
    phone = '';
    branch = '';
  }
}