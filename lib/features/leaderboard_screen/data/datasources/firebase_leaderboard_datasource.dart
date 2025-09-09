import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/leaderboard_entry.dart';

abstract class FirebaseLeaderboardDataSource {
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 15});
  Stream<List<LeaderboardEntry>> getLeaderboardStream({int limit = 15});
  Future<bool> updatePlayerScore(String nickname, int score);
  Future<bool> isNicknameAvailable(String nickname);
  Future<bool> createPlayer(String nickname);
}

class FirebaseLeaderboardDataSourceImpl implements FirebaseLeaderboardDataSource {
  final FirebaseFirestore _firestore;
  static const String _playersCollection = 'players';

  FirebaseLeaderboardDataSourceImpl(this._firestore);

  @override
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 15}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_playersCollection)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      final List<LeaderboardEntry> leaderboard = [];
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        final doc = querySnapshot.docs[i];
        final data = doc.data();
        leaderboard.add(LeaderboardEntry(
          id: doc.id,
          nickname: data['nickname'] ?? '',
          score: data['score'] ?? 0,
          rank: i + 1,
        ));
      }

      return leaderboard;
    } catch (e) {
      print('Error getting leaderboard: $e');
      return [];
    }
  }

  @override
  Stream<List<LeaderboardEntry>> getLeaderboardStream({int limit = 15}) {
    return _firestore
        .collection(_playersCollection)
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final List<LeaderboardEntry> leaderboard = [];
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        leaderboard.add(LeaderboardEntry(
          id: doc.id,
          nickname: data['nickname'] ?? '',
          score: data['score'] ?? 0,
          rank: i + 1,
        ));
      }
      return leaderboard;
    });
  }

  @override
  Future<bool> updatePlayerScore(String nickname, int score) async {
    try {
      print('FirebaseDataSource: Searching for player with nickname: $nickname');
      final querySnapshot = await _firestore
          .collection(_playersCollection)
          .where('nickname', isEqualTo: nickname)
          .get();

      print('FirebaseDataSource: Found ${querySnapshot.docs.length} documents');

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final currentScore = doc.data()['score'] ?? 0;
        print('FirebaseDataSource: Current score for $nickname: $currentScore');
        
        // Обновляем счет только если новый счет больше
        if (score > currentScore) {
          print('FirebaseDataSource: Updating score from $currentScore to $score');
          await doc.reference.update({'score': score});
          print('Score updated for $nickname: $score');
          return true;
        } else {
          print('New score $score is not higher than current score $currentScore for $nickname');
          return false;
        }
      } else {
        print('Player not found: $nickname, creating new player');
        // Создаем нового игрока с текущим счетом
        await _firestore.collection(_playersCollection).add({
          'nickname': nickname,
          'score': score,
        });
        print('New player created: $nickname with score: $score');
        return true;
      }
    } catch (e) {
      print('Error updating player score: $e');
      return false;
    }
  }

  @override
  Future<bool> isNicknameAvailable(String nickname) async {
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

  @override
  Future<bool> createPlayer(String nickname) async {
    try {
      final playerData = {
        'nickname': nickname,
        'score': 0,
      };
      await _firestore.collection(_playersCollection).add(playerData);
      print('Player created successfully: $nickname');
      return true;
    } catch (e) {
      print('Error creating player: $e');
      return false;
    }
  }
}
