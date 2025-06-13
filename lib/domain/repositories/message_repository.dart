import '../entities/message.dart';

abstract class MessageRepository {
  Future<Message?> sendMessage(Message message);
}