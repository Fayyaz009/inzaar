class DailyQuote {
  final String text;
  final String author;
  final String? reference;

  const DailyQuote({
    required this.text,
    required this.author,
    this.reference,
  });
}

class QuoteRepository {
  static const List<DailyQuote> quotes = [
    DailyQuote(
      text:
          "The greatest jihad is to battle your own soul, to fight the evil within yourself.",
      author: "Prophet Muhammad (PBUH)",
    ),
    DailyQuote(
      text:
          "Be like a flower that gives its fragrance even to the hand that crushes it.",
      author: "Ali ibn Abi Talib (RA)",
    ),
    DailyQuote(
      text:
          "Yesterday I was clever, so I wanted to change the world. Today I am wise, so I am changing myself.",
      author: "Rumi",
    ),
    DailyQuote(
      text:
          "The heart that is full of the love of God is like a lamp that is full of oil.",
      author: "Abu Yahya",
    ),
    DailyQuote(
      text:
          "Patience is not the ability to wait, but the ability to keep a good attitude while waiting.",
      author: "Unknown",
    ),
    DailyQuote(
      text: "He who has no patience has no faith.",
      author: "Ali ibn Abi Talib (RA)",
    ),
    DailyQuote(
      text: "Speak only when your words are more beautiful than silence.",
      author: "Insha' Allah",
    ),
    DailyQuote(
      text: "The best of people are those that are most beneficial to people.",
      author: "Prophet Muhammad (PBUH)",
    ),
    DailyQuote(
      text:
          "Knowledge without action is insanity, and action without knowledge is vanity.",
      author: "Imam Al-Ghazali",
    ),
    DailyQuote(
      text: "Don't let your sorrow come higher than your knees.",
      author: "Abu Yahya",
    ),
    DailyQuote(
      text: "Gratitude is the secret of abundance.",
      author: "Maulana Rumi",
    ),
    DailyQuote(
      text: "Allah does not burden a soul beyond that it can bear.",
      author: "Quran",
      reference: "2:286",
    ),
    DailyQuote(
      text:
          "Kindness is a mark of faith, and whoever is not kind has no faith.",
      author: "Prophet Muhammad (PBUH)",
    ),
    DailyQuote(
      text: "A person's true wealth is the good he or she does in the world.",
      author: "Muhammad (PBUH)",
    ),
    DailyQuote(
      text: "To be calm is the highest achievement of the self.",
      author: "Zen Proverb",
    ),
  ];

  static DailyQuote getQuoteForToday() {
    final now = DateTime.now();
    final dayOfYear = now.day + (now.month * 31); // Simple hash for cycling
    return quotes[dayOfYear % quotes.length];
  }
}
