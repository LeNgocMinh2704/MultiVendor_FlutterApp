class NotificationsModel {
  final String uid;
  final String heading;
  final String content;

  NotificationsModel({required this.uid, required this.heading, required this.content});

  NotificationsModel.fromMap(Map<String, dynamic> data, this.uid)
      : heading = data['heading'],
        content = data['content'];
}
