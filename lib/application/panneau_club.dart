import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduria/application/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PanneauClubPage extends StatefulWidget {
  final String clubId;
  final String clubName;
  final String clubEmoji;
  final bool isAdmin;

  const PanneauClubPage({
    super.key,
    required this.clubId,
    required this.clubName,
    required this.clubEmoji,
    this.isAdmin = false,
  });

  @override
  State<PanneauClubPage> createState() => _PanneauClubPageState();
}

class _PanneauClubPageState extends State<PanneauClubPage> {
  final Color burgundy = const Color(0xFF8B2323);
  final Color darkBlue = const Color(0xFF3B448F);
  final Color lavenderBg = const Color(0xFFFFF3FE);
  final TextStyle juraBold =
      const TextStyle(fontFamily: 'Jura', fontWeight: FontWeight.bold);

  final _messageController = TextEditingController();
  bool _isSending = false;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  final List<String> _allEmojis = [
    '❤️',
    '😂',
    '😮',
    '👏',
    '🔥',
    '😢',
    '😍',
    '🎉',
    '💪',
    '👍',
    '😎',
    '🤔',
    '😅',
    '🙏',
    '💯',
    '⚡',
    '🏆',
    '😱',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    final docRef = FirebaseFirestore.instance.collection('posts').doc();
    await docRef.set({
      'postId': docRef.id,
      'clubId': widget.clubId,
      'text': text,
      'imageUrl': '',
      'type': 'message',
      'reactions': {},
      'votedBy': [],
      'createdAt': Timestamp.now(),
      'authorId': _uid,
    });
    _messageController.clear();
    setState(() => _isSending = false);

    await NotificationService.sendNotificationToClub(
      clubId: widget.clubId,
      title: "💬 ${widget.clubName}",
      body: text,
    );
  }

  Future<void> _toggleReaction(
      String postId, Map<String, dynamic> post, String emoji) async {
    final reactions = Map<String, dynamic>.from(post['reactions'] ?? {});

    String? currentEmoji;
    for (var e in _allEmojis) {
      final list = List<String>.from(reactions[e] ?? []);
      if (list.contains(_uid)) {
        currentEmoji = e;
        break;
      }
    }

    final docRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (currentEmoji == emoji) {
      final list = List<String>.from(reactions[emoji] ?? []);
      list.remove(_uid);
      await docRef.update({'reactions.$emoji': list});
    } else {
      if (currentEmoji != null) {
        final oldList = List<String>.from(reactions[currentEmoji] ?? []);
        oldList.remove(_uid);
        await docRef.update({'reactions.$currentEmoji': oldList});
      }
      final newList = List<String>.from(reactions[emoji] ?? []);
      newList.add(_uid);
      await docRef.update({'reactions.$emoji': newList});
    }
  }

  Future<void> _vote(
      String postId, Map<String, dynamic> post, String option) async {
    final votedBy = List<String>.from(post['votedBy'] ?? []);

    if (votedBy.contains(_uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Vous avez déjà voté !",
              style: TextStyle(fontFamily: 'Jura')),
          backgroundColor: burgundy,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final votes = Map<String, dynamic>.from(post['votes'] ?? {});
    final count = (votes[option] ?? 0) as int;

    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'votes.$option': count + 1,
      'votedBy': [...votedBy, _uid],
    });
  }

  void _showVoteDialog() {
    final questionController = TextEditingController();
    final option1Controller = TextEditingController();
    final option2Controller = TextEditingController();
    final option3Controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Créer un vote",
                style: juraBold.copyWith(fontSize: 18, color: darkBlue)),
            const SizedBox(height: 15),
            _sheetField(questionController, "Question du vote"),
            const SizedBox(height: 10),
            _sheetField(option1Controller, "Option 1"),
            const SizedBox(height: 8),
            _sheetField(option2Controller, "Option 2"),
            const SizedBox(height: 8),
            _sheetField(option3Controller, "Option 3 (optionnel)"),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (questionController.text.isEmpty ||
                      option1Controller.text.isEmpty ||
                      option2Controller.text.isEmpty) return;
                  final options = [
                    option1Controller.text.trim(),
                    option2Controller.text.trim(),
                    if (option3Controller.text.isNotEmpty)
                      option3Controller.text.trim(),
                  ];
                  final votes = {for (var o in options) o: 0};
                  final docRef =
                      FirebaseFirestore.instance.collection('posts').doc();
                  await docRef.set({
                    'postId': docRef.id,
                    'clubId': widget.clubId,
                    'text': '',
                    'imageUrl': '',
                    'type': 'vote',
                    'voteQuestion': questionController.text.trim(),
                    'voteOptions': options,
                    'votes': votes,
                    'votedBy': [],
                    'reactions': {},
                    'createdAt': Timestamp.now(),
                    'authorId': _uid,
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: burgundy),
                child: Text("Publier le vote",
                    style:
                        juraBold.copyWith(color: Colors.white, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: TextStyle(fontFamily: 'Jura', color: darkBlue),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(fontFamily: 'Jura', color: darkBlue.withOpacity(0.4)),
        filled: true,
        fillColor: lavenderBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: darkBlue.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: darkBlue.withOpacity(0.2)),
        ),
      ),
    );
  }

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
            Text(widget.clubEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.clubName,
                    style: TextStyle(
                        fontFamily: 'Jura',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: darkBlue)),
                Text("Panneau d'affichage",
                    style: TextStyle(
                        fontFamily: 'Jura',
                        fontSize: 11,
                        color: darkBlue.withOpacity(0.5))),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('clubId', isEqualTo: widget.clubId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }
                final posts = snapshot.data!.docs.toList();

                // Tri ancien → récent (comme WhatsApp)
                posts.sort((a, b) {
                  final aDate = (a.data() as Map)['createdAt'] as Timestamp?;
                  final bDate = (b.data() as Map)['createdAt'] as Timestamp?;
                  if (aDate == null || bDate == null) return 0;
                  return aDate.compareTo(bDate);
                });

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
          ),
          if (widget.isAdmin) _buildAdminInput(),
        ],
      ),
    );
  }

  Widget _buildAdminInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: darkBlue.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showVoteDialog,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: darkBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.poll_outlined, color: darkBlue, size: 22),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: lavenderBg,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: darkBlue.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(fontFamily: 'Jura', color: darkBlue),
                decoration: InputDecoration(
                  hintText: "Écrire un message...",
                  hintStyle: TextStyle(
                      fontFamily: 'Jura',
                      color: darkBlue.withOpacity(0.4),
                      fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: burgundy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.clubEmoji, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text(
              "Vous êtes sur le panneau d'affichage du ${widget.clubName}",
              style: TextStyle(
                  fontFamily: 'Jura',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkBlue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.isAdmin
                  ? "Écrivez votre premier message ci-dessous !"
                  : "En attente des messages de l'administrateur...",
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
        ? (post['createdAt'] as Timestamp).toDate()
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
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: burgundy.withOpacity(0.1),
                  child: Text(widget.clubEmoji,
                      style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Admin ${widget.clubName}",
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
                ),
                if (widget.isAdmin)
                  IconButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('posts')
                          .doc(postId)
                          .delete();
                    },
                    icon: Icon(Icons.delete_outline,
                        color: Colors.red.withOpacity(0.6), size: 18),
                  ),
              ],
            ),
          ),
          if (post['text'] != null && post['text'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(post['text'],
                  style: TextStyle(
                      fontFamily: 'Jura', fontSize: 14, color: darkBlue)),
            ),
          if (post['imageUrl'] != null &&
              post['imageUrl'].toString().isNotEmpty)
            Image.network(post['imageUrl'],
                width: double.infinity, fit: BoxFit.cover, height: 200),
          if (post['type'] == 'vote') _buildVote(postId, post),
          _buildReactions(context, postId, post),
        ],
      ),
    );
  }

  Widget _buildVote(String postId, Map<String, dynamic> post) {
    final options = List<String>.from(post['voteOptions'] ?? []);
    final votes = Map<String, dynamic>.from(post['votes'] ?? {});
    final votedBy = List<String>.from(post['votedBy'] ?? []);
    final hasVoted = votedBy.contains(_uid);

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
          const SizedBox(height: 4),
          if (hasVoted)
            Text("✅ Vous avez déjà voté",
                style: TextStyle(
                    fontFamily: 'Jura',
                    fontSize: 11,
                    color: Colors.green.withOpacity(0.8))),
          const SizedBox(height: 8),
          ...options.map((option) {
            final count = (votes[option] ?? 0) as int;
            final total = votes.values.fold(0, (sum, v) => sum + (v as int));
            final percent = total > 0 ? count / total : 0.0;

            return GestureDetector(
              onTap: hasVoted ? null : () => _vote(postId, post, option),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: hasVoted
                      ? darkBlue.withOpacity(0.03)
                      : darkBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: hasVoted
                          ? darkBlue.withOpacity(0.05)
                          : darkBlue.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(option,
                          style: TextStyle(
                              fontFamily: 'Jura',
                              fontSize: 13,
                              color: hasVoted
                                  ? darkBlue.withOpacity(0.5)
                                  : darkBlue)),
                    ),
                    if (hasVoted)
                      Text("$count vote${count > 1 ? 's' : ''}",
                          style: TextStyle(
                              fontFamily: 'Jura',
                              fontSize: 11,
                              color: darkBlue.withOpacity(0.5))),
                    if (hasVoted) ...[
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

    String? myEmoji;
    for (var e in _allEmojis) {
      final list = List<String>.from(reactions[e] ?? []);
      if (list.contains(_uid)) {
        myEmoji = e;
        break;
      }
    }

    final activeEmojis = _allEmojis.where((e) {
      final list = List<String>.from(reactions[e] ?? []);
      return list.isNotEmpty;
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showEmojiPicker(context, postId, post),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: myEmoji != null
                    ? burgundy.withOpacity(0.1)
                    : darkBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: myEmoji != null
                        ? burgundy.withOpacity(0.3)
                        : darkBlue.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.add,
                      size: 14,
                      color: myEmoji != null
                          ? burgundy
                          : darkBlue.withOpacity(0.5)),
                  const SizedBox(width: 3),
                  Text(myEmoji ?? "😊", style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: activeEmojis.map((emoji) {
                  final list = List<String>.from(reactions[emoji] ?? []);
                  final count = list.length;
                  final isMine = list.contains(_uid);
                  return GestureDetector(
                    onTap: () => _toggleReaction(postId, post, emoji),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isMine
                            ? burgundy.withOpacity(0.15)
                            : burgundy.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isMine
                                ? burgundy.withOpacity(0.4)
                                : Colors.transparent),
                      ),
                      child: Text("$emoji $count",
                          style: const TextStyle(fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker(
      BuildContext context, String postId, Map<String, dynamic> post) {
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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _allEmojis.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _toggleReaction(postId, post, emoji);
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 30)),
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
