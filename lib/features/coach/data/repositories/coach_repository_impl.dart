import 'package:untitled/features/coach/data/datasources/coach_remote_data_source.dart';
import 'package:untitled/features/coach/domain/entities/chat_message.dart';
import 'package:untitled/features/coach/domain/repositories/coach_repository.dart';

class CoachRepositoryImpl implements CoachRepository {
  final CoachRemoteDataSource remoteDataSource;

  CoachRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> sendMessage({
    required String systemPrompt,
    required List<ChatMessage> history,
  }) {
    return remoteDataSource.sendMessage(systemPrompt: systemPrompt, history: history);
  }
}
