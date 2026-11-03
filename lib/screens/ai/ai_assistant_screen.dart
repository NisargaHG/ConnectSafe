
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

class AIAssistantScreen extends StatefulWidget {
const AIAssistantScreen({super.key});

@override
State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
final TextEditingController messageController =
TextEditingController();

final ScrollController scrollController =
ScrollController();

final ApiService _api = ApiService.instance;

final List<Map<String, String>> messages = [
{
"sender": "ai",
"message":
"Hello! I'm your ConnectSafe AI Assistant. How can I help you today?",
},
];

bool isLoading = false;

@override
void dispose() {
messageController.dispose();
scrollController.dispose();
super.dispose();
}

// =========================================================
// SEND MESSAGE TO DJANGO AI ASSISTANT
// =========================================================

Future<void> sendMessage() async {
final text = messageController.text.trim();

if (text.isEmpty || isLoading) {
return;
}

FocusScope.of(context).unfocus();

messageController.clear();

setState(() {
messages.add({
"sender": "user",
"message": text,
});

isLoading = true;
});

_scrollToBottom();

try {
debugPrint(
'Sending AI Assistant message: $text',
);

final result = await _api.post(
'ai-assistant/',
{
'message': text,
},
);

debugPrint(
'AI Assistant response: $result',
);

String aiResponse;

if (result is Map<String, dynamic>) {
aiResponse =
result['response']?.toString() ??
result['answer']?.toString() ??
result['message']?.toString() ??
'I could not generate a response.';
} else {
aiResponse = 'Invalid response received from AI.';
}

if (!mounted) return;

setState(() {
messages.add({
"sender": "ai",
"message": aiResponse,
});

isLoading = false;
});

_scrollToBottom();
} catch (e) {
debugPrint(
'AI Assistant error: $e',
);

if (!mounted) return;

setState(() {
messages.add({
"sender": "ai",
"message":
"Sorry, I couldn't connect to the AI Assistant. Please try again.",
});

isLoading = false;
});

_scrollToBottom();
}
}

// =========================================================
// SCROLL TO BOTTOM
// =========================================================

void _scrollToBottom() {
WidgetsBinding.instance.addPostFrameCallback((_) {
if (!scrollController.hasClients) {
return;
}

scrollController.animateTo(
scrollController.position.maxScrollExtent,
duration: const Duration(
milliseconds: 300,
),
curve: Curves.easeOut,
);
});
}

// =========================================================
// MESSAGE BUBBLE
// =========================================================

Widget _messageBubble(
Map<String, String> message,
) {
final bool isUser =
message["sender"] == "user";

return Align(
alignment: isUser
? Alignment.centerRight
    : Alignment.centerLeft,
child: Container(
margin: const EdgeInsets.symmetric(
vertical: 6,
),
padding: const EdgeInsets.all(14),
constraints: const BoxConstraints(
maxWidth: 310,
),
decoration: BoxDecoration(
color: isUser
? AppColors.primary
    : AppColors.surface,
borderRadius: BorderRadius.only(
topLeft: const Radius.circular(16),
topRight: const Radius.circular(16),
bottomLeft: Radius.circular(
isUser ? 16 : 4,
),
bottomRight: Radius.circular(
isUser ? 4 : 16,
),
),
border: isUser
? null
    : Border.all(
color: AppColors.border,
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
if (!isUser) ...[
Row(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(
Icons.smart_toy_rounded,
size: 18,
color: AppColors.primary,
),
const SizedBox(width: 6),
const Text(
'ConnectSafe AI',
style: TextStyle(
fontSize: 11,
fontWeight: FontWeight.bold,
color: AppColors.primary,
),
),
],
),
const SizedBox(height: 6),
],
Text(
message["message"] ?? "",
style: TextStyle(
color: isUser
? Colors.white
    : AppColors.textPrimary,
fontSize: 14,
height: 1.4,
),
),
],
),
),
);
}

// =========================================================
// LOADING BUBBLE
// =========================================================

Widget _loadingBubble() {
return Align(
alignment: Alignment.centerLeft,
child: Container(
margin: const EdgeInsets.symmetric(
vertical: 6,
),
padding: const EdgeInsets.symmetric(
horizontal: 16,
vertical: 13,
),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: AppColors.border,
),
),
child: const Row(
mainAxisSize: MainAxisSize.min,
children: [
SizedBox(
width: 18,
height: 18,
child: CircularProgressIndicator(
strokeWidth: 2,
color: AppColors.primary,
),
),
SizedBox(width: 10),
Text(
'AI is thinking...',
style: TextStyle(
color: AppColors.textSecondary,
fontSize: 13,
),
),
],
),
),
);
}

// =========================================================
// BUILD
// =========================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,

// =====================================================
// APP BAR
// =====================================================

appBar: AppBar(
backgroundColor: AppColors.background,
elevation: 0,
centerTitle: true,
title: Row(
mainAxisSize: MainAxisSize.min,
children: [
Container(
padding: const EdgeInsets.all(7),
decoration: BoxDecoration(
color: AppColors.primary.withValues(
alpha: 0.12,
),
shape: BoxShape.circle,
),
child: const Icon(
Icons.smart_toy_rounded,
color: AppColors.primary,
size: 22,
),
),
const SizedBox(width: 8),
const Text(
"AI Assistant",
style: TextStyle(
color: AppColors.textPrimary,
fontWeight: FontWeight.bold,
),
),
],
),
),

// =====================================================
// BODY
// =====================================================

body: Column(
children: [
Expanded(
child: ListView.builder(
controller: scrollController,
padding: const EdgeInsets.fromLTRB(
16,
10,
16,
16,
),
itemCount:
messages.length +
(isLoading ? 1 : 0),
itemBuilder: (context, index) {
if (isLoading &&
index == messages.length) {
return _loadingBubble();
}

return _messageBubble(
messages[index],
);
},
),
),

// =================================================
// INPUT AREA
// =================================================

SafeArea(
top: false,
child: Container(
padding: const EdgeInsets.fromLTRB(
12,
8,
12,
12,
),
decoration: BoxDecoration(
color: AppColors.background,
border: Border(
top: BorderSide(
color: AppColors.border,
),
),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.end,
children: [
Expanded(
child: TextField(
controller:
messageController,
enabled: !isLoading,
minLines: 1,
maxLines: 4,
textInputAction:
TextInputAction.send,
onSubmitted: (_) {
sendMessage();
},
decoration:
InputDecoration(
hintText:
"Ask about an emergency...",
filled: true,
fillColor:
Colors.white,
prefixIcon:
const Icon(
Icons.chat_outlined,
color: AppColors
    .textSecondary,
),
border:
OutlineInputBorder(
borderRadius:
BorderRadius
    .circular(14),
borderSide:
const BorderSide(
color:
AppColors.border,
),
),
enabledBorder:
OutlineInputBorder(
borderRadius:
BorderRadius
    .circular(14),
borderSide:
const BorderSide(
color:
AppColors.border,
),
),
focusedBorder:
OutlineInputBorder(
borderRadius:
BorderRadius
    .circular(14),
borderSide:
const BorderSide(
color:
AppColors.primary,
width: 1.5,
),
),
contentPadding:
const EdgeInsets
    .symmetric(
horizontal: 14,
vertical: 13,
),
),
),
),

const SizedBox(width: 10),

// SEND BUTTON
Container(
width: 52,
height: 52,
decoration:
const BoxDecoration(
color:
AppColors.primary,
shape: BoxShape.circle,
),
child: IconButton(
onPressed: isLoading
? null
    : sendMessage,
icon: const Icon(
Icons.send_rounded,
color: Colors.white,
),
),
),
],
),
),
),
],
),
);
}
}

