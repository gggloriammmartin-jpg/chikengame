import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _playersCollection = 'players';

  // Проверяем, занят ли ник
  static Future<bool> isNicknameAvailable(String nickname) async {
    try {
      print('Checking if nickname exists: $nickname');
      final querySnapshot = await _firestore
          .collection(_playersCollection)
          .where('nickname', isEqualTo: nickname)
          .get();
      print('Found ${querySnapshot.docs.length} documents with this nickname');
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking nickname availability: $e');
      return false;
    }
  }

  // Создаем нового игрока
  static Future<bool> createPlayer(String nickname) async {
    try {
      final player = Player(
        nickname: nickname,
        score: 0,
      );

      await _firestore
          .collection(_playersCollection)
          .add(player.toMap());

      print('Player created successfully: $nickname');
      return true;
    } catch (e) {
      print('Error creating player: $e');
      return false;
    }
  }

  // Обновляем счет игрока
  static Future<bool> updatePlayerScore(String nickname, int newScore) async {
    try {
      // Находим документ игрока по никнейму
      final querySnapshot = await _firestore
          .collection(_playersCollection)
          .where('nickname', isEqualTo: nickname)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('Player not found: $nickname');
        return false;
      }

      final playerDoc = querySnapshot.docs.first;
      final currentScore = playerDoc.data()['score'] ?? 0;
      
      // Обновляем только если новый счет больше
      if (newScore > currentScore) {
        await playerDoc.reference.update({
          'score': newScore,
        });
        print('Score updated for $nickname: $newScore');
      } else {
        print('Score not updated for $nickname: $newScore <= $currentScore');
      }

      return true;
    } catch (e) {
      print('Error updating player score: $e');
      return false;
    }
  }

  // Получаем лидерборд
  static Future<List<Player>> getLeaderboard({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_playersCollection)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Player.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting leaderboard: $e');
      return [];
    }
  }

  // Получаем данные конкретного игрока
  static Future<Player?> getPlayer(String nickname) async {
    try {
      final querySnapshot = await _firestore
          .collection(_playersCollection)
          .where('nickname', isEqualTo: nickname)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Player.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error getting player: $e');
      return null;
    }
  }

  // Стрим лидерборда в реальном времени
  static Stream<List<Player>> getLeaderboardStream({int limit = 10}) {
    return _firestore
        .collection(_playersCollection)
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Player.fromMap(doc.data()))
            .toList());
  }
}
