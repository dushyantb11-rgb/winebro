/// Non-web platforms: the console preview bridge is inert.
void listenForPreviewMessages(void Function(Map<String, dynamic>) onMessage) {}

void postToParent(Map<String, dynamic> message) {}

Map<String, String> initialQuery() => const {};
