import 'package:equatable/equatable.dart';
import 'package:payfussion/data/models/community_form/community_form_model.dart';


abstract class CommunityFormState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PostInitial extends CommunityFormState {}

class PostLoading extends CommunityFormState {}

class PostAdded extends CommunityFormState {}

class PostLoaded extends CommunityFormState {
  final List<CommunityFormModel> posts;
  PostLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class PostError extends CommunityFormState {
  final String message;
  PostError(this.message);

  @override
  List<Object?> get props => [message];
}
