import 'package:cloud_firestore/cloud_firestore.dart';

class DebugService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _playersCollection = 'players';

  // Очищаем все данные игроков (только для разработки!)
  static Future<void> clearAllPlayers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_playersCollection)
          .get();
      
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
        print('Deleted player: ${doc.id}');
      }
      
      print('All players cleared!');
    } catch (e) {
      print('Error clearing players: $e');
    }
  }

  // Получаем всех игроков для отладки
  static Future<void> listAllPlayers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_playersCollection)
          .get();
      
      print('=== All Players ===');
      for (final doc in querySnapshot.docs) {
        print('ID: ${doc.id}, Data: ${doc.data()}');
      }
      print('==================');
    } catch (e) {
      print('Error listing players: $e');
    }
  }
}
