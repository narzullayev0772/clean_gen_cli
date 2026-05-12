import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/use_cases/fetch_test_feature_use_case.dart';

part 'test_feature_state.dart';
part 'test_feature_event.dart';

class TestFeatureBloc extends Bloc<TestFeatureEvent, TestFeatureState> {
  final FetchTestFeatureUseCase _fetchTestFeatureUseCase;

  TestFeatureBloc(this._fetchTestFeatureUseCase) : super(TestFeatureInitial());

  Future<void> loadTestFeature() async {
    emit(TestFeatureLoading());
    try {
      final result = await _fetchTestFeatureUseCase();
      // handle result
      emit(TestFeatureLoaded());
    } catch (e) {
      emit(TestFeatureError(e.toString()));
    }
  }
}
