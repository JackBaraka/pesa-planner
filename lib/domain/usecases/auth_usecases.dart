import 'package:pesa_planner/domain/repositories/auth_repository_contract.dart';

class AuthUseCases {
  final AuthRepositoryContract repository;

  AuthUseCases(this.repository);

  Stream<AppUser> get currentUser => repository.user;
}
