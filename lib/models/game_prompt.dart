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
    if (requiresPlayer && targetPlayer != null) {
      // Replace [player] with the target player's name (no bold)
      formattedText = formattedText.replaceAll('[player]', targetPlayer);
      
      // Handle additional random players if needed, ensuring they're different from targetPlayer
      while (formattedText.contains('[random]')) {
        String randomPlayer;
        do {
          randomPlayer = players[Random().nextInt(players.length)];
        } while (randomPlayer == targetPlayer && players.length > 1);
        
        formattedText = formattedText.replaceFirst('[random]', randomPlayer);
      }
    }
    return formattedText;
  }

  static List<GamePrompt> generatePromptsFromPackages(List<GamePackage> packages) {
    List<GamePrompt> prompts = [];
    
    for (var package in packages) {
      for (var promptText in package.samplePrompts) {
        bool requiresPlayer = promptText.contains('[player]') || promptText.contains('[random]');
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