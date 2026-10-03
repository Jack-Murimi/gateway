import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/customer_repository.dart';
import '../data/mock_customer_repository.dart';
import '../domain/customer.dart';

part 'customer_providers.g.dart';

/// Customer repository.
@riverpod
CustomerRepository customerRepository(Ref ref) {
  return MockCustomerRepository();
}

/// All customers.
@riverpod
Future<List<Customer>> customers(Ref ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getCustomers();
}
