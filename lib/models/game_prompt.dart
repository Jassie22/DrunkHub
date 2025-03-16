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
    
    // Always replace [player] with the target player's name, regardless of requiresPlayer flag
    if (formattedText.contains('[player]')) {
      if (targetPlayer != null) {
        formattedText = formattedText.replaceAll('[player]', targetPlayer);
      } else if (players.isNotEmpty) {
        // If no target player is provided but we have players, use a random one
        formattedText = formattedText.replaceAll('[player]', players[Random().nextInt(players.length)]);
      }
    }
    
    // Handle additional random players if needed, ensuring they're different from targetPlayer
    while (formattedText.contains('[random]')) {
      if (players.isEmpty) break; // Safety check
      
      String randomPlayer;
      if (targetPlayer != null && players.length > 1) {
        // Ensure random player is different from target player if possible
        do {
          randomPlayer = players[Random().nextInt(players.length)];
        } while (randomPlayer == targetPlayer && players.length > 1);
      } else {
        // Just pick a random player
        randomPlayer = players[Random().nextInt(players.length)];
      }
      
      formattedText = formattedText.replaceFirst('[random]', randomPlayer);
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