import '../../domain/entities/leaderboard_entry.dart';

class HtmlGenerator {
  static String generateLeaderboardUrl({
    required String nickname,
    required List<LeaderboardEntry> leaderboardData,
    required double statusBarHeight,
    required bool showWelcome,
  }) {
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Leaderboard</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap');
    
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    body {
      font-family: 'Poppins', Arial, sans-serif;
      background: linear-gradient(180deg, #E8F4FD 0%, #FFE066 30%, #FFB84D 60%, #FF8C42 100%);
      margin: 0;
      padding: ${statusBarHeight + 20}px 20px 20px 20px;
      color: #2C1810;
      min-height: 100vh;
      overflow-x: hidden;
    }
    
    .container {
      max-width: 600px;
      margin: 0 auto;
      text-align: center;
      padding-top: 60px;
    }
    
    .header {
      margin-bottom: 30px;
    }
    
    .title {
      font-size: 2.8em;
      font-weight: 700;
      color: #8B4513;
      text-shadow: 2px 2px 4px rgba(255,255,255,0.3);
      margin-bottom: 10px;
    }
    
    .welcome-card {
      background: rgba(255, 255, 255, 0.9);
      border: 2px solid #D4AF37;
      border-radius: 20px;
      padding: 25px;
      margin-bottom: 30px;
      backdrop-filter: blur(10px);
      box-shadow: 0 8px 32px rgba(0,0,0,0.2);
    }
    
    .welcome-title {
      font-size: 1.5em;
      font-weight: 600;
      color: #8B4513;
      margin-bottom: 0;
    }
    
    .leaderboard {
      background: rgba(255, 255, 255, 0.85);
      border: 2px solid #D4AF37;
      border-radius: 20px;
      padding: 20px;
      backdrop-filter: blur(10px);
      box-shadow: 0 8px 32px rgba(0,0,0,0.2);
      height: calc(100vh - ${statusBarHeight + 120}px);
      overflow-y: auto;
    }
    
    .player {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 18px 20px;
      margin: 12px 0;
      background: rgba(255, 248, 220, 0.8);
      border: 1px solid #D4AF37;
      border-radius: 15px;
      transition: all 0.3s ease;
      position: relative;
      overflow: hidden;
    }
    
    .player:hover {
      background: rgba(255, 215, 0, 0.2);
      border-color: #FFD700;
      transform: translateY(-2px);
      box-shadow: 0 4px 15px rgba(255, 215, 0, 0.3);
    }
    
    .player.current-user {
      background: rgba(34, 139, 34, 0.2);
      border-color: #228B22;
      box-shadow: 0 4px 15px rgba(34, 139, 34, 0.3);
    }
    
    .rank {
      font-size: 1.8em;
      font-weight: 700;
      color: #8B4513;
      min-width: 40px;
      text-shadow: 1px 1px 2px rgba(255,255,255,0.5);
    }
    
    .rank.first {
      color: #FFD700;
      text-shadow: 0 0 10px rgba(255, 215, 0, 0.8);
    }
    
    .rank.second {
      color: #C0C0C0;
      text-shadow: 1px 1px 2px rgba(0,0,0,0.3);
    }
    
    .rank.third {
      color: #CD7F32;
      text-shadow: 1px 1px 2px rgba(0,0,0,0.3);
    }
    
    .player-info {
      flex: 1;
      text-align: left;
      margin-left: 15px;
    }
    
    .name {
      font-size: 1.3em;
      font-weight: 600;
      color: #2C1810;
      margin-bottom: 4px;
    }
    
    .name.current-user {
      color: #228B22;
    }
    
    .score {
      font-size: 1.1em;
      font-weight: 500;
      color: #8B4513;
    }
    
    .score.current-user {
      color: #228B22;
    }
    
    .trophy {
      font-size: 1.2em;
      margin-right: 8px;
    }
    
    .loading {
      text-align: center;
      padding: 40px;
      color: #5D4037;
      font-size: 1.1em;
    }
    
    .spinner {
      border: 3px solid #D4AF37;
      border-top: 3px solid #FFD700;
      border-radius: 50%;
      width: 30px;
      height: 30px;
      animation: spin 1s linear infinite;
      margin: 0 auto 15px;
    }
    
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    
    /* Стили для скроллбара */
    .leaderboard::-webkit-scrollbar {
      width: 8px;
    }
    
    .leaderboard::-webkit-scrollbar-track {
      background: rgba(212, 175, 55, 0.3);
      border-radius: 4px;
    }
    
    .leaderboard::-webkit-scrollbar-thumb {
      background: #D4AF37;
      border-radius: 4px;
    }
    
    .leaderboard::-webkit-scrollbar-thumb:hover {
      background: #FFD700;
    }
  </style>
</head>
<body>
  <div class="container">
    ${showWelcome ? '''
    <div class="welcome-card">
      <h2 class="welcome-title">Welcome, $nickname!</h2>
    </div>
    ''' : ''}
    
    <div class="leaderboard">
      ${_generateLeaderboardHTML(leaderboardData, nickname)}
    </div>
  </div>
</body>
</html>
''';
    
    return 'data:text/html;charset=utf-8,${Uri.encodeComponent(htmlContent)}';
  }

  static String _generateLeaderboardHTML(List<LeaderboardEntry> leaderboardData, String nickname) {
    if (leaderboardData.isEmpty) {
      return '''
        <div class="loading">
          <div class="spinner"></div>
          <p>Loading leaderboard...</p>
        </div>
      ''';
    }

    String html = '';
    for (final player in leaderboardData) {
      final playerName = player.nickname;
      final score = player.score;
      final rank = player.rank;
      final isCurrentUser = playerName == nickname;
      
      String rankClass = '';
      if (rank == 1) rankClass = 'first';
      else if (rank == 2) rankClass = 'second';
      else if (rank == 3) rankClass = 'third';
      
      String playerClass = isCurrentUser ? 'current-user' : '';
      
      html += '''
        <div class="player $playerClass">
          <div class="rank $rankClass">$rank</div>
          <div class="player-info">
            <div class="name $playerClass">$playerName</div>
          </div>
          <div class="score $playerClass">${_formatScore(score)}</div>
        </div>
      ''';
    }
    
    return html;
  }

  static String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    } else {
      return score.toString();
    }
  }
}
