import 'package:flutter/material.dart';
import 'package_selection_page.dart';

class PlayerSetupScreen extends StatefulWidget {
  final bool quickDrinkMode;

  const PlayerSetupScreen({
    super.key,
    required this.quickDrinkMode,
  });

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final List<String> _players = ['Player 1', 'Player 2'];
  final TextEditingController _playerNameController = TextEditingController();
  final FocusNode _playerNameFocusNode = FocusNode();

  @override
  void dispose() {
    _playerNameController.dispose();
    _playerNameFocusNode.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _playerNameController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        _players.add(name);
        _playerNameController.clear();
      });
      _playerNameFocusNode.requestFocus();
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
  }

  void _navigateToPackageSelection() {
    if (_players.length >= 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PackageSelectionPage(
            players: _players,
            quickDrinkMode: widget.quickDrinkMode,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need at least 2 players to continue'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Players'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _players.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(_players[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removePlayer(index),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _playerNameController,
                    focusNode: _playerNameFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Player Name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addPlayer,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _navigateToPackageSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
} 