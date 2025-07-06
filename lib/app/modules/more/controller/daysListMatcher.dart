//* Need in order to match the already selected days list while updating alarm so that we can show the previously selected option as selected option

class DaysListMatcher {
  static bool matches(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    final sortedA = [...a]..sort();
    final sortedB = [...b]..sort();
    for (int i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) return false;
    }
    return true;
  }
}