import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/res/usecase.dart';
import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';
import 'package:new_tuneflow/src/auth/domain/repository/signup_repository.dart';

class SignupUseCase extends UseCase<DataState<SignupEntity>, void> {
  final SignupRepository _signupRepository;
  SignupUseCase(this._signupRepository);

  @override
  Future<DataState<SignupEntity>> call({
    void params,
    String? name,
    String? phone,
    String? email,
    String? password,
  }) async {
    return await _signupRepository.signupRequest(
      name!,
      phone!,
      email!,
      password!,
    );
  }

  Future<DataState<SignupEntity>> googleLogin(
    String name,
    String email,
  ) {
    return _signupRepository.googleLogin(name, email);
  }
}
