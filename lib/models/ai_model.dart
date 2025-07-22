class AIModel {
  final String id;
  final String name;
  final String description;
  final String provider;
  final bool supportsImages;
  final bool supportsVision;

  const AIModel({
    required this.id,
    required this.name,
    required this.description,
    required this.provider,
    this.supportsImages = false,
    this.supportsVision = false,
  });

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ModelConfiguration {
  static const List<AIModel> availableModels = [
    AIModel(
      id: 'gpt-4o',
      name: 'GPT-4o',
      description: 'Most capable model for complex tasks',
      provider: 'OpenAI',
      supportsImages: true,
      supportsVision: true,
    ),
    AIModel(
      id: 'gpt-4o-mini',
      name: 'GPT-4o Mini',
      description: 'Fast and efficient for most tasks',
      provider: 'OpenAI',
      supportsImages: true,
      supportsVision: true,
    ),
    AIModel(
      id: 'gpt-3.5-turbo',
      name: 'GPT-3.5 Turbo',
      description: 'Fast and cost-effective',
      provider: 'OpenAI',
      supportsImages: false,
      supportsVision: false,
    ),
    AIModel(
      id: 'gpt-4-turbo',
      name: 'GPT-4 Turbo',
      description: 'Powerful model with vision capabilities',
      provider: 'OpenAI',
      supportsImages: true,
      supportsVision: true,
    ),
  ];

  static AIModel get defaultModel => availableModels.firstWhere(
    (model) => model.id == 'gpt-4o-mini',
    orElse: () => availableModels.first,
  );

  static AIModel getModelById(String id) {
    return availableModels.firstWhere(
      (model) => model.id == id,
      orElse: () => defaultModel,
    );
  }

  static List<AIModel> getModelsByProvider(String provider) {
    return availableModels.where((model) => model.provider == provider).toList();
  }

  static List<AIModel> getModelsWithVision() {
    return availableModels.where((model) => model.supportsVision).toList();
  }
} 