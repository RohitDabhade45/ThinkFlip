class CardModel {
  final String title;
  final String description;
  final String imageUrl;

  CardModel({required this.title, required this.description, this.imageUrl = ''});

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}

class MessageRequest {
  final String modelType;
  final String prompt;
  final int? number;

  MessageRequest({
    required this.modelType, 
    required this.prompt,
    this.number,
  });

  Map<String, dynamic> toJson() {
    final map = {
      "modelType": modelType,
      "prompt": prompt,
    };
    if (number != null) {
      map["number"] = number.toString();
    }
    return map;
  }
}

class MessageResponse {
  final List<CardModel> result;

  MessageResponse({required this.result});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      result: (json['result'] as List)
          .map((item) => CardModel.fromJson(item))
          .toList(),
    );
  }
}
