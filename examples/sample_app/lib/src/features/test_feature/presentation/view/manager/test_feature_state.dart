part of 'test_feature_bloc.dart';

abstract class TestFeatureState {}

class TestFeatureInitial extends TestFeatureState {}

class TestFeatureLoading extends TestFeatureState {}

class TestFeatureLoaded extends TestFeatureState {}

class TestFeatureError extends TestFeatureState {
  final String message;
  TestFeatureError(this.message);
}
