import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/chat_model.dart';
import '../../services/groq_service.dart';
import 'package:ecmobile/theme/app_colors.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatSession session;

  const ChatDetailPage({Key? key, required this.session}) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GroqService _groqService = GroqService();

  late List<ChatMessage> _messages;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages = widget.session.messages; // Load tin nhắn ban đầu từ session truyền vào
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final String text = _controller.text;
    final String timeNow = DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now());

    setState(() {
      _messages.add(ChatMessage(content: text, role: 'user', timestamp: timeNow));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    // 1. Lưu tin nhắn User vào Firebase NGAY LẬP TỨC
    await _updateFirestore();

    // 2. Gọi AI
    String aiResponse = await _groqService.sendMessageToGroq(
        text,
        _messages.sublist(0, _messages.length - 1)
    );

    if (!mounted) return;

    setState(() {
      _messages.add(ChatMessage(content: aiResponse, role: 'ai', timestamp: timeNow));
      _isLoading = false;
    });
    _scrollToBottom();

    // 3. Lưu tin nhắn AI vào Firebase
    await _updateFirestore();
  }

  // Hàm cập nhật Firebase
  Future<void> _updateFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('chat_sessions')
          .doc(widget.session.sessionId)
          .update({
        'messages': _messages.map((e) => e.toJson()).toList(),
        'lastUpdated': DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now()),
      });
    } catch (e) {
      print("Lỗi lưu tin nhắn: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Sử dụng StreamBuilder ở đây để nếu User đổi tên Chat ở màn hình trước,
        // hoặc đổi trên web, thì ở đây cũng tự cập nhật tên mới luôn.
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('chat_sessions').doc(widget.session.sessionId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.exists) {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              return Text(
                data['sessionName'] ?? widget.session.sessionName,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              );
            }
            return Text(widget.session.sessionName);
          },
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final msg = _messages[index];
                final isUser = msg.role == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                        color: isUser ? AppColors.primary.withOpacity(0.15) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: isUser ? const Radius.circular(12) : const Radius.circular(0),
                          bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                        ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt, size: 16, color: Colors.orange),
                              const SizedBox(width: 5),
                              Text("Darter AI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                            ],
                          ),
                        if (!isUser) const SizedBox(height: 4),
                        Text(msg.content, style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(
                          msg.timestamp,
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                          textAlign: isUser ? TextAlign.right : TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Hỏi về sản phẩm...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.send, color: Colors.white),
                  mini: true,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}