import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/res/usecase.dart';
import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';
import 'package:new_tuneflow/src/auth/domain/repository/language_repository.dart';

class LanguageUseCase extends UseCase<DataState<SignupEntity>, void> {
  final LanguageRepository _languageRepository;
  LanguageUseCase(this._languageRepository);

  @override
  Future<DataState<SignupEntity>> call({
    void params,
    int? id,
    List? languages,
  }) async {
    return await _languageRepository.updateLanguage(id!, languages!);
  }
}
