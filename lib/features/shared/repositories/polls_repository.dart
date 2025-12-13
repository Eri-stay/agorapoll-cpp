import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/poll_model.dart';

class PollsRepository {
  final FirebaseFirestore _firestore;

  PollsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // 1. Create a new poll
  Future<void> createPoll(Poll poll) async {
    try {
      await _firestore
          .collection('polls')
          .doc(poll.id)
          .set(poll.toMap())
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception('Failed to create poll: $e');
    }
  }

  // 2. Get stream of polls created by specific user
  Stream<List<Poll>> getMyPolls(String userId) {
    return _firestore
        .collection('polls')
        .where('creatorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Poll.fromMap(doc.data());
          }).toList();
        });
  }

  // 3. Get stream of a specific poll by ID
  Stream<Poll?> getPollStream(String pollId) {
    return _firestore
        .collection('polls')
        .doc(pollId)
        .snapshots()
        .map((doc) => doc.exists ? Poll.fromMap(doc.data()!) : null);
  }

  // 4. Get user's vote (if voted) for a specific poll
  Future<List<String>> getUserVote(String pollId, String userId) async {
    try {
      final doc = await _firestore
          .collection('polls')
          .doc(pollId)
          .collection('votes')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        // Return list of selected options (even if only one)
        return List<String>.from(doc.data()!['selectedOptions'] ?? []);
      }
      return [];
    } catch (e) {
      print("Error getting vote: $e");
      return [];
    }
  }

  // 5. Vote in a poll
  Future<void> vote({
    required String pollId,
    required String userId,
    required List<String> selectedOptions,
  }) async {
    try {
      // Write to the votes subcollection -> document with user ID
      await _firestore
          .collection('polls')
          .doc(pollId)
          .collection('votes')
          .doc(userId)
          .set({
            'userId': userId,
            'selectedOptions': selectedOptions,
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to vote: $e');
    }
  }

  // 6. Отримати потік всіх голосів за опитування
  Stream<QuerySnapshot> getVotesStream(String pollId) {
    return _firestore
        .collection('polls')
        .doc(pollId)
        .collection('votes')
        .snapshots();
  }

  // 7. Отримати дані користувача за ID
  Future<DocumentSnapshot> getUserData(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }

  // 8. Знайти опитування за кодом
  Future<Poll?> findPollByCode(String code) async {
    try {
      final querySnapshot = await _firestore
          .collection('polls')
          .where(
            'code',
            isEqualTo: code.toUpperCase(),
          ) // Important: codes are stored in UpperCase
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Poll.fromMap(querySnapshot.docs.first.data());
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error finding poll: $e');
    }
  }

  // 9. Видалити опитування (поки що без видалення голосів)
  Future<void> deletePoll(String pollId) async {
    try {
      await _firestore.collection('polls').doc(pollId).delete();
    } catch (e) {
      throw Exception('Failed to delete poll: $e');
    }
  }

  // 10. Оновити опитування (для закриття)
  Future<void> updatePoll(String pollId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('polls').doc(pollId).update(data);
    } catch (e) {
      throw Exception('Failed to update poll: $e');
    }
  }
}
