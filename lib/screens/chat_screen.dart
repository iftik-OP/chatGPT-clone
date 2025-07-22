import 'package:chat_gpt_clone/consts/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/conversation.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/ai_typing_indicator.dart';
import '../widgets/model_selector.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollDown = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final atBottom = _scrollController.offset >=
        _scrollController.position.maxScrollExtent - 20;
    if (_showScrollDown == atBottom) {
      setState(() {
        _showScrollDown = !atBottom;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chat = Provider.of<ChatProvider>(context);
    chat.addListener(_scrollToBottom);
  }

  @override
  void dispose() {
    final chat = Provider.of<ChatProvider>(context, listen: false);
    chat.removeListener(_scrollToBottom);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildChatHistoryItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildChatTile(Conversation conversation, bool isActive, ChatProvider chatProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          chatProvider.selectConversation(conversation);
          Navigator.pop(context);
        },
        onLongPress: () {
          _showConversationOptions(context, conversation, chatProvider);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatProvider.getConversationTitle(conversation),
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      chatProvider.getTimeAgo(conversation),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
                const Icon(
                  Icons.more_horiz,
                  size: 16,
                  color: Colors.white70,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConversationOptions(BuildContext context, Conversation conversation, ChatProvider chatProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF202123),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete conversation', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, conversation, chatProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy, color: Colors.white70),
              title: const Text('Copy conversation', style: TextStyle(color: Colors.white70)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Conversation conversation, ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202123),
        title: const Text('Delete Conversation', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${chatProvider.getConversationTitle(conversation)}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              chatProvider.deleteConversation(conversation.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.white70,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationsList(ChatProvider chatProvider) {
    if (chatProvider.conversations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: Colors.white54,
              ),
              SizedBox(height: 16),
              Text(
                'No conversations yet',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Start a new chat to begin',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final conversations = chatProvider.conversations;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    List<Widget> widgets = [];

    final todayConversations = conversations.where((conv) {
      final convDate = DateTime(conv.timestamp.year, conv.timestamp.month, conv.timestamp.day);
      return convDate.isAtSameMomentAs(today);
    }).toList();

    if (todayConversations.isNotEmpty) {
      widgets.add(_buildChatHistoryItem('Today'));
      widgets.addAll(todayConversations.map((conv) => _buildChatTile(
        conv,
        chatProvider.selectedConversation?.id == conv.id,
        chatProvider,
      )));
    }

    final yesterdayConversations = conversations.where((conv) {
      final convDate = DateTime(conv.timestamp.year, conv.timestamp.month, conv.timestamp.day);
      return convDate.isAtSameMomentAs(yesterday);
    }).toList();

    if (yesterdayConversations.isNotEmpty) {
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 16));
      widgets.add(_buildChatHistoryItem('Yesterday'));
      widgets.addAll(yesterdayConversations.map((conv) => _buildChatTile(
        conv,
        chatProvider.selectedConversation?.id == conv.id,
        chatProvider,
      )));
    }

    final previousConversations = conversations.where((conv) {
      final convDate = DateTime(conv.timestamp.year, conv.timestamp.month, conv.timestamp.day);
      return convDate.isBefore(yesterday);
    }).toList();

    if (previousConversations.isNotEmpty) {
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 16));
      widgets.add(_buildChatHistoryItem('Previous 7 days'));
      widgets.addAll(previousConversations.map((conv) => _buildChatTile(
        conv,
        chatProvider.selectedConversation?.id == conv.id,
        chatProvider,
      )));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) => Drawer(
          child: Container(
            color: const Color(0xFF202123),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
                  child: Row(
                    children: [
                      const Text(
                        'ChatGPT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        chatProvider.createNewConversation();
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'New chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Expanded(
                  child: _buildConversationsList(chatProvider),
                ),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white12),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildBottomTile(Icons.person_outline, 'My Account', () {
                        Navigator.pop(context);
                      }),
                      const SizedBox(height: 8),
                      _buildBottomTile(Icons.settings_outlined, 'Settings', () {
                        Navigator.pop(context);
                      }),
                      const SizedBox(height: 8),
                      _buildBottomTile(Icons.logout, 'Log out', () {
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      appBar: AppBar(
        leading: Builder(builder: (context) => InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: Icon(Icons.menu, color: AppColors.iconGray),
        ),) ,
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) => Text(
            chatProvider.selectedConversation != null 
                ? chatProvider.getConversationTitle(chatProvider.selectedConversation!)
                : 'ChatGPT',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
        ),
        centerTitle: true,
        actions: [
          const ModelSelector(),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chat, _) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: chat.isLoading ? chat.messages.length + 1 : chat.messages.length,
                      itemBuilder: (context, index) {
                        if (chat.isLoading && index == chat.messages.length) {
                          return const Padding(
                            padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                            child: AITypingIndicator(),
                          );
                        }
                        return ChatBubble(message: chat.messages[index]);
                      },
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.inputField,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: const MessageInput(),
              ),
            ],
          ),
          if (_showScrollDown)
            Positioned(
              bottom: 110,
              right: MediaQuery.sizeOf(context).width/2 -20 ,
              child: FloatingActionButton(
                shape: CircleBorder(),
                mini: true,
                backgroundColor: AppColors.inputField,
                onPressed: _scrollToBottom,
                child: const Icon(Icons.arrow_downward, color: Colors.white54, size: 20,),
              ),
            ),
        ],
      ),
    );
  }
}

