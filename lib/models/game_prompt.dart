import 'game_package.dart';
import 'dart:math';

class GamePrompt {
  final String text;
  final bool requiresPlayer;
  final bool isGroupPrompt;

  const GamePrompt({
    required this.text,
    this.requiresPlayer = false,
    this.isGroupPrompt = false,
  });

  String getFormattedText(List<String> players, {String? targetPlayer}) {
    if (isGroupPrompt) return text;
    
    String formattedText = text;
    
    // Replace "Current player" with the target player's name
    if (formattedText.contains('Current player')) {
      if (targetPlayer != null) {
        formattedText = formattedText.replaceAll('Current player', targetPlayer);
      } else if (players.isNotEmpty) {
        formattedText = formattedText.replaceAll('Current player', players[Random().nextInt(players.length)]);
      }
    }
    
    // Replace "another player" with a random player's name, ensuring they're different from targetPlayer
    while (formattedText.contains('another player')) {
      if (players.isEmpty) break;
      
      String randomPlayer;
      if (targetPlayer != null && players.length > 1) {
        do {
          randomPlayer = players[Random().nextInt(players.length)];
        } while (randomPlayer == targetPlayer && players.length > 1);
      } else {
        randomPlayer = players[Random().nextInt(players.length)];
      }
      
      formattedText = formattedText.replaceFirst('another player', randomPlayer);
    }
    
    return formattedText;
  }

  static List<GamePrompt> generatePromptsFromPackages(List<GamePackage> packages) {
    List<GamePrompt> prompts = [];
    
    for (var package in packages) {
      for (var promptText in package.samplePrompts) {
        bool requiresPlayer = promptText.contains('Current player') || promptText.contains('another player');
        bool isGroupPrompt = promptText.toLowerCase().contains('everyone') || 
                           promptText.toLowerCase().contains('all players');
        
        prompts.add(GamePrompt(
          text: promptText,
          requiresPlayer: requiresPlayer,
          isGroupPrompt: isGroupPrompt,
        ));
      }
    }
    
    return prompts;
  }
} 