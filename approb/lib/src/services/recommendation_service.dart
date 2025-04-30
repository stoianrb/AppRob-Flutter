class RecommendationService {
  // Exemplu simplu pentru recomandări pe baza unui algoritm de preferințe
  List<String> getRecommendations(String userId) {
    // Aici poți integra un algoritm de recomandare bazat pe istoricul utilizatorului
    // De exemplu, folosești istoricul programărilor din Firestore
    if (userId == 'user123') {
      return ['Recomandare 1', 'Recomandare 2'];
    }
    return ['Recomandare standard'];
  }
}
