import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/res/usecase.dart';
import 'package:new_tuneflow/src/auth/domain/entites/login_entity.dart';
import 'package:new_tuneflow/src/auth/domain/repository/login_repository.dart';

class LoginUseCase extends UseCase<DataState<LoginEntity>, void> {
  final LoginRepository _loginRepository;
  LoginUseCase(this._loginRepository);

  @override
  Future<DataState<LoginEntity>> call({
    void params,
    String? identifier,
    String? password,
  }) async {
    return await _loginRepository.loginRequest(identifier!, password!);
  }
}
