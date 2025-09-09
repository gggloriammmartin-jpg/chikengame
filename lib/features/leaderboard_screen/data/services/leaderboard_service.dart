import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/firebase_leaderboard_datasource.dart';
import '../datasources/local_user_datasource.dart';
import '../repositories/leaderboard_repository_impl.dart';
import '../repositories/user_repository_impl.dart';

class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  LeaderboardRepository? _leaderboardRepository;
  UserRepository? _userRepository;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final firestore = FirebaseFirestore.instance;
    final prefs = await SharedPreferences.getInstance();
    
    final firebaseDataSource = FirebaseLeaderboardDataSourceImpl(firestore);
    final localUserDataSource = LocalUserDataSourceImpl(prefs);
    
    _leaderboardRepository = LeaderboardRepositoryImpl(firebaseDataSource);
    _userRepository = UserRepositoryImpl(localUserDataSource);
    _isInitialized = true;
  }

  // Leaderboard methods
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 15}) async {
    await _ensureInitialized();
    return await _leaderboardRepository!.getLeaderboard(limit: limit);
  }

  Stream<List<LeaderboardEntry>> getLeaderboardStream({int limit = 15}) {
    _ensureInitializedSync();
    return _leaderboardRepository!.getLeaderboardStream(limit: limit);
  }

  Future<bool> updatePlayerScore(String nickname, int score) async {
    print('LeaderboardService: updatePlayerScore called with nickname: $nickname, score: $score');
    await _ensureInitialized();
    final result = await _leaderboardRepository!.updatePlayerScore(nickname, score);
    print('LeaderboardService: updatePlayerScore result: $result');
    return result;
  }

  Future<bool> isNicknameAvailable(String nickname) async {
    await _ensureInitialized();
    return await _leaderboardRepository!.isNicknameAvailable(nickname);
  }

  Future<bool> createPlayer(String nickname) async {
    await _ensureInitialized();
    return await _leaderboardRepository!.createPlayer(nickname);
  }

  // User methods
  Future<User?> getCurrentUser() async {
    await _ensureInitialized();
    return await _userRepository!.getCurrentUser();
  }

  Future<bool> setNickname(String nickname) async {
    await _ensureInitialized();
    return await _userRepository!.setNickname(nickname);
  }

  Future<bool> clearNickname() async {
    await _ensureInitialized();
    return await _userRepository!.clearNickname();
  }

  // Private helper methods
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  void _ensureInitializedSync() {
    if (!_isInitialized) {
      throw StateError('LeaderboardService must be initialized before use');
    }
  }
}
