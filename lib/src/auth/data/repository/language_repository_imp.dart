import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/auth/data/data_source/language_data_source.dart';
import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';
import 'package:new_tuneflow/src/auth/domain/repository/language_repository.dart';

class LanguageRepositoryImp implements LanguageRepository {
  final LanguageApiService _languageApiService;
  LanguageRepositoryImp(this._languageApiService);

  @override
  Future<DataState<SignupEntity>> updateLanguage(
    int id,
    List languages,
  ) async {
    return await _languageApiService.updateLanguage(id, languages);
  }
}
