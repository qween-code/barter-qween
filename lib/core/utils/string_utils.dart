/// Utility functions for string operations
class StringUtils {
  /// Normalizes Turkish characters for search
  /// Converts: ı->i, İ->i, ş->s, Ş->s, ğ->g, Ğ->g, ü->u, Ü->u, ö->o, Ö->o, ç->c, Ç->c
  static String normalizeTurkish(String text) {
    return text
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'c');
  }

  /// Checks if a text contains a query (Turkish-aware)
  static bool turkishContains(String text, String query) {
    return normalizeTurkish(text).contains(normalizeTurkish(query));
  }
}
