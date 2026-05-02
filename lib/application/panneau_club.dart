import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PanneauClubPage extends StatelessWidget {
  final String clubId;
  final String clubName;
  final String clubEmoji;

  const PanneauClubPage({
    super.key,
    required this.clubId,
    required this.clubName,
    required this.clubEmoji,
    this.isAdmin = false, // ajoute ceci
  });

  final bool isAdmin; // ajoute ceci

  final Color burgundy = const Color(0xFF8B2323);
  final Color darkBlue = const Color(0xFF3B448F);
  final Color lavenderBg = const Color(0xFFFFF3FE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lavenderBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
        ),
        title: Row(
          children: [
            Text(clubEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clubName,
                  style: TextStyle(
                      fontFamily: 'Jura',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: darkBlue),
                ),
                Text(
                  "Panneau d'affichage",
                  style: TextStyle(
                      fontFamily: 'Jura',
                      fontSize: 11,
                      color: darkBlue.withOpacity(0.5)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('clubId', isEqualTo: clubId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Pas encore de messages
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(clubName);
          }

          final posts = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (_, i) {
              final post = posts[i].data() as Map<String, dynamic>;
              return _buildPostCard(context, posts[i].id, post);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String clubName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(clubEmoji, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text(
              "Vous êtes sur le panneau d'affichage du $clubName",
              style: TextStyle(
                  fontFamily: 'Jura',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkBlue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "En attente des messages de l'administrateur...",
              style: TextStyle(
                  fontFamily: 'Jura',
                  fontSize: 13,
                  color: darkBlue.withOpacity(0.5)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(
      BuildContext context, String postId, Map<String, dynamic> post) {
    final createdAt = post['createdAt'] != null
        ? (post['createdAt'] as dynamic).toDate()
        : DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkBlue.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
              color: darkBlue.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header du post
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: burgundy.withOpacity(0.1),
                  child: Text(clubEmoji, style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Admin $clubName",
                        style: TextStyle(
                            fontFamily: 'Jura',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: darkBlue)),
                    Text(
                      "${createdAt.day}/${createdAt.month}/${createdAt.year} à ${createdAt.hour}h${createdAt.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                          fontFamily: 'Jura',
                          fontSize: 10,
                          color: darkBlue.withOpacity(0.4)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Contenu texte
          if (post['text'] != null && post['text'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(post['text'],
                  style: TextStyle(
                      fontFamily: 'Jura', fontSize: 14, color: darkBlue)),
            ),

          // Image si présente
          if (post['imageUrl'] != null &&
              post['imageUrl'].toString().isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(0)),
              child: Image.network(post['imageUrl'],
                  width: double.infinity, fit: BoxFit.cover, height: 200),
            ),

          // Vote si présent
          if (post['type'] == 'vote') _buildVote(postId, post),

          // Réactions emoji
          _buildReactions(context, postId, post),
        ],
      ),
    );
  }

  Widget _buildVote(String postId, Map<String, dynamic> post) {
    final options = List<String>.from(post['voteOptions'] ?? []);
    final votes = Map<String, dynamic>.from(post['votes'] ?? {});

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("📊 ${post['voteQuestion'] ?? 'Vote'}",
              style: TextStyle(
                  fontFamily: 'Jura',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: darkBlue)),
          const SizedBox(height: 8),
          ...options.map((option) {
            final count = (votes[option] ?? 0) as int;
            final total = votes.values.fold(0, (sum, v) => sum + (v as int));
            final percent = total > 0 ? count / total : 0.0;

            return GestureDetector(
              onTap: () async {
                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .update({'votes.$option': count + 1});
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: darkBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: darkBlue.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(option,
                          style: TextStyle(
                              fontFamily: 'Jura',
                              fontSize: 13,
                              color: darkBlue)),
                    ),
                    Text("$count vote${count > 1 ? 's' : ''}",
                        style: TextStyle(
                            fontFamily: 'Jura',
                            fontSize: 11,
                            color: darkBlue.withOpacity(0.5))),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: LinearProgressIndicator(
                        value: percent.toDouble(),
                        backgroundColor: darkBlue.withOpacity(0.1),
                        color: burgundy,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReactions(
      BuildContext context, String postId, Map<String, dynamic> post) {
    final reactions = Map<String, dynamic>.from(post['reactions'] ?? {});
    final emojis = ['❤️', '😂', '😮', '👏', '🔥', '😢'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
      child: Row(
        children: [
          // Bouton ajouter réaction
          GestureDetector(
            onTap: () => _showEmojiPicker(context, postId, reactions),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: darkBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: darkBlue.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, size: 14, color: darkBlue.withOpacity(0.5)),
                  const SizedBox(width: 3),
                  Text("😊", style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Réactions existantes
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: emojis.where((e) {
                  final count = reactions[e] ?? 0;
                  return count > 0;
                }).map((emoji) {
                  final count = reactions[emoji] ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: burgundy.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text("$emoji $count",
                        style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker(BuildContext context, String postId,
      Map<String, dynamic> currentReactions) {
    final emojis = ['❤️', '😂', '😮', '👏', '🔥', '😢'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Réagir",
                style: TextStyle(
                    fontFamily: 'Jura',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: darkBlue)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: emojis.map((emoji) {
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    final current = (currentReactions[emoji] ?? 0) as int;
                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(postId)
                        .update({'reactions.$emoji': current + 1});
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 32)),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
