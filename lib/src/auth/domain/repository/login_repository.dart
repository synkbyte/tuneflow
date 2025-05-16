import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/auth/domain/entites/login_entity.dart';

abstract class LoginRepository {
  Future<DataState<LoginEntity>> loginRequest(
    String identifier,
    String password,
  );
}
