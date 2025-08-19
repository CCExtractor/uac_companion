// import 'dart:math';

// String generateUniqueId() {
//   final now = DateTime.now().millisecondsSinceEpoch;
//   final random = Random().nextInt(999999).toString().padLeft(6, '0');
//   return '$now-$random';
// }

String generateUniqueId() {
  return DateTime.now().microsecondsSinceEpoch.toString();
}