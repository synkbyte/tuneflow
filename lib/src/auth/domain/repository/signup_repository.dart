import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';

abstract class SignupRepository {
  Future<DataState<SignupEntity>> signupRequest(
    String name,
    String phone,
    String email,
    String password,
  );

  Future<DataState<SignupEntity>> googleLogin(
    String name,
    String email,
  );
}
