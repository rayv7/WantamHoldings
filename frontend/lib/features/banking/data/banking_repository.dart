import '../../../core/api/api_client.dart';

class BankingRepository {
  BankingRepository(this.api);
  final ApiClient api;

  Future<Map<String, dynamic>> login(String email, String password) async =>
      Map<String, dynamic>.from(
        await api.post(
          '/auth/login',
          data: {'email': email, 'password': password},
        ),
      );
  Future<Map<String, dynamic>> register(Map<String, String> data) async =>
      Map<String, dynamic>.from(await api.post('/auth/register', data: data));
  Future<Map<String, dynamic>> profile() async =>
      Map<String, dynamic>.from(await api.get('/users/profile'));
  Future<Map<String, dynamic>> updateProfile(Map<String, String> data) async =>
      Map<String, dynamic>.from(await api.patch('/users/profile', data: data));
  Future<dynamic> customers({String? search}) => api.get(
    '/customers',
    query: {
      'page': 1,
      'limit': 50,
      if (search != null && search.isNotEmpty) 'search': search,
    },
  );
  Future<dynamic> accounts({String? search}) => api.get(
    '/accounts',
    query: {
      'page': 1,
      'limit': 50,
      if (search != null && search.isNotEmpty) 'search': search,
    },
  );
  Future<dynamic> account(String number) => api.get('/accounts/number/$number');
  Future<dynamic> balance(String number) =>
      api.get('/accounts/$number/balance');
  Future<dynamic> statement(String number, {String? from, String? to}) =>
      api.get(
        '/transactions/statement/$number',
        query: {
          if (from?.isNotEmpty ?? false) 'from': from,
          if (to?.isNotEmpty ?? false) 'to': to,
        },
      );
  Future<dynamic> createCustomer(Map<String, String> data) =>
      api.post('/customers', data: data);
  Future<dynamic> updateCustomer(String id, Map<String, String> data) =>
      api.patch('/customers/$id', data: data);
  Future<dynamic> createAccount(Map<String, String> data) =>
      api.post('/accounts', data: data);
  Future<dynamic> updateAccount(String id, Map<String, String> data) =>
      api.patch('/accounts/$id', data: data);
  Future<dynamic> accountAction(String id, String action) =>
      api.patch('/accounts/$id/$action');
  Future<dynamic> transaction(String type, Map<String, String> data) =>
      api.post('/transactions/$type', data: data);
}
