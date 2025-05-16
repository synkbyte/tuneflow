import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';

abstract class LanguageRepository {
  Future<DataState<SignupEntity>> updateLanguage(int id, List languages);
}
