import 'package:intl/intl.dart';

class GiggModel {
  String giggName;
  String giggId;
  DateTime postedAt;
  String description;

  GiggModel.fromSearchResponse(Map<String, dynamic> data) {
    DateFormat dateFormat = DateFormat('yyyy-MM-ddTHH:mm:ss+00:00');

    giggName = data['gigg_name']['raw'];
    giggId = data['gigg_id']['raw'];
    postedAt = dateFormat.parse(data['posted_at']['raw']);
    description = data['description']['raw'];
  }
}
