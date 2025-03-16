class GamePackage {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isPremium;
  final List<String> samplePrompts;
  final String category;
  bool isSelected;

  GamePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isPremium,
    required this.samplePrompts,
    required this.category,
    this.isSelected = false,
  });
}

final List<GamePackage> gamePackages = [
  // Free Packages
  GamePackage(
    id: 'getting_started',
    name: 'Getting Started',
    description: 'Perfect for warming up the party with simple drinking rules and challenges.',
    icon: '🎮',
    isPremium: false,
    category: 'Warm-Up (Free)',
    samplePrompts: [
      '[player], take a sip if you\'ve ever skipped class',
      '[player], choose someone to take a drink with you',
      'Last person to touch their nose drinks',
      '[player], give 2 drinks to [random]',
      'Everyone younger than [player] drinks',
    ],
  ),
  GamePackage(
    id: 'getting_tipsy',
    name: 'Getting Tipsy',
    description: 'Step it up a notch with more challenging and entertaining drinking tasks.',
    icon: '🍻',
    isPremium: false,
    category: 'Warm-Up (Free)',
    samplePrompts: [
      '[player], if you\'ve ever been caught in a lie, give out 3 drinks',
      'Everyone who\'s been late today drinks',
      '[player] gives out drinks equal to their siblings',
      '[player] and [random] must play rock, paper, scissors. Loser drinks!',
      '[player], if you got ghosted after a date, give out 2 drinks',
    ],
  ),

  // Premium Packages
  GamePackage(
    id: 'never_have_i_ever',
    name: 'Never Have I Ever',
    description: 'Classic drinking game with a twist! Reveal secrets and drink to what you\'ve done.',
    icon: '🤔',
    isPremium: true,
    category: 'Classics',
    samplePrompts: [
      '[player] starts: Never have I ever sent a text to the wrong person',
      '[player] starts: Never have I ever gone skinny dipping',
      '[player] starts: Never have I ever faked being sick to skip work',
      '[player] must drink if [random] has done more traveling',
      'Everyone who\'s done what [player] says must drink',
    ],
  ),
  GamePackage(
    id: 'most_likely_to',
    name: 'Most Likely To',
    description: 'Find out what your friends really think about who would most likely do what!',
    icon: '👀',
    isPremium: true,
    category: 'Classics',
    samplePrompts: [
      'Who\'s most likely to become a millionaire? [player] decides, they drink!',
      'Point at who\'s most likely to move abroad. [player] counts down from 3!',
      '[player] picks who\'s most likely to become famous',
      'Most likely to get married first? [player] counts to 3!',
      '[player] decides who\'s most likely to win the lottery',
    ],
  ),
  GamePackage(
    id: 'couples_night',
    name: 'Couples Night',
    description: 'Perfect for date night or couples party with romantic and fun challenges.',
    icon: '❤️',
    isPremium: true,
    category: 'Special Occasions',
    samplePrompts: [
      'Kiss your partner if you\'ve ever forgotten an anniversary',
      'Take turns complimenting each other',
      'Share your first date story',
    ],
  ),
  GamePackage(
    id: 'girls_night',
    name: 'Girls Night',
    description: 'Ultimate girls night out edition with female-focused fun and challenges.',
    icon: '👯‍♀️',
    isPremium: true,
    category: 'Special Occasions',
    samplePrompts: [
      'Drink if you\'ve ever borrowed clothes without asking',
      'Take a sip if you\'ve cried watching a romance movie',
      'Everyone wearing makeup drinks',
    ],
  ),
  GamePackage(
    id: 'boys_night',
    name: 'Boys Night',
    description: 'Bros night out challenges designed for the guys to have a great time.',
    icon: '🤜🤛',
    isPremium: true,
    category: 'Special Occasions',
    samplePrompts: [
      'Drink if you\'ve ever tried to impress someone at the gym',
      'Take a shot if you\'ve lost in FIFA today',
      'Everyone with a beard drinks twice',
    ],
  ),
  GamePackage(
    id: 'truth_or_drink',
    name: 'Truth or Drink',
    description: 'Answer truthfully to personal questions or take a drink to avoid answering!',
    icon: '🤫',
    isPremium: true,
    category: 'Challenges',
    samplePrompts: [
      'What\'s your biggest regret or take a drink',
      'Reveal your last DM or drink twice',
      'Share your most embarrassing moment or finish your drink',
    ],
  ),
  GamePackage(
    id: 'party_challenges',
    name: 'Party Challenges',
    description: 'Exciting physical and social challenges to spice up the night and get everyone involved.',
    icon: '🎉',
    isPremium: true,
    category: 'Challenges',
    samplePrompts: [
      'Challenge someone to a dance-off or drink',
      'Do your best celebrity impression or take two drinks',
      'Make everyone laugh or finish your drink',
    ],
  ),
  GamePackage(
    id: 'wildcards',
    name: 'Wildcards',
    description: 'Expect the unexpected with these random and surprising game-changing challenges.',
    icon: '🃏',
    isPremium: true,
    category: 'Challenges',
    samplePrompts: [
      'Switch drinks with the person to your right',
      'Everyone trades seats and drinks',
      'Create a new rule for the game',
    ],
  ),
  
  // Flirty Fun package in Classics category
  GamePackage(
    id: 'flirty_fun',
    name: 'Flirty Fun',
    description: 'Playful questions and light challenges to create chemistry and break the ice.',
    icon: '💋',
    isPremium: true,
    category: 'Classics',
    samplePrompts: [
      '[player], give a compliment to [random] or take a drink',
      'Everyone votes on who has the best smile. [player] counts to 3!',
      '[player], share your best pickup line or take two drinks',
      '[player], if you\'ve ever had a crush on someone in this room, take a drink',
      'Truth: [player], who in this room would you go on a date with?',
      '[player], make eye contact with [random] for 10 seconds or drink',
      'Everyone who\'s been on a date this month drinks',
    ],
  ),
  
  // Heat It Up package in Challenges category
  GamePackage(
    id: 'heat_it_up',
    name: 'Heat It Up',
    description: 'More daring challenges that push comfort zones and increase intimacy.',
    icon: '🔥',
    isPremium: true,
    category: 'Challenges',
    samplePrompts: [
      '[player], whisper something in [random]\'s ear that would make them blush',
      '[player], take a body shot off of [random] or take three drinks',
      'Everyone votes on who\'s the most seductive. [player] counts to 3!',
      '[player], demonstrate your best dance move or finish your drink',
      '[player], share a secret fantasy or take two drinks',
      '[player] and [random] must hold hands until the next round',
      'Everyone who\'s kissed someone in the last week drinks',
    ],
  ),
  
  // No Limits package in Challenges category
  GamePackage(
    id: 'no_limits',
    name: 'No Limits',
    description: 'The most provocative and intimate category for those looking to push boundaries.',
    icon: '🌶️',
    isPremium: true,
    category: 'Challenges',
    samplePrompts: [
      '[player], remove an item of clothing or take three drinks',
      '[player] and [random] must kiss or both finish their drinks',
      '[player], share your wildest experience or take four drinks',
      'Everyone votes on who\'s the most adventurous in the bedroom. [player] counts to 3!',
      '[player], give [random] a sensual massage for 30 seconds or drink',
      '[player], describe your perfect night with [random] or finish your drink',
      'Everyone who\'s ever skinny dipped drinks twice',
    ],
  ),
]; 