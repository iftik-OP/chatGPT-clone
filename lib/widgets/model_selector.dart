import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/ai_model.dart';
import '../consts/app_colors.dart';

class ModelSelector extends StatelessWidget {
  const ModelSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        return PopupMenuButton<AIModel>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                chatProvider.selectedModel.name,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: AppColors.white70,
                size: 16,
              ),
            ],
          ),
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.surface,
          itemBuilder: (context) => _buildModelItems(context, chatProvider),
          onSelected: (AIModel model) {
            chatProvider.setSelectedModel(model);
          },
        );
      },
    );
  }

  List<PopupMenuEntry<AIModel>> _buildModelItems(BuildContext context, ChatProvider chatProvider) {
    final items = <PopupMenuEntry<AIModel>>[];
    
    final providers = <String, List<AIModel>>{};
    for (final model in ModelConfiguration.availableModels) {
      providers.putIfAbsent(model.provider, () => []).add(model);
    }

    for (final entry in providers.entries) {
      final provider = entry.key;
      final models = entry.value;

      items.add(
        PopupMenuItem<AIModel>(
          enabled: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              provider,
              style: const TextStyle(
                color: AppColors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );

      for (final model in models) {
        final isSelected = chatProvider.selectedModel.id == model.id;
        items.add(
          PopupMenuItem<AIModel>(
            value: model,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getModelIcon(model.provider),
                    color: isSelected ? AppColors.primary : AppColors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.name,
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.white,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          model.description,
                          style: const TextStyle(
                            color: AppColors.white70,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check,
                      color: AppColors.primary,
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
        );
      }

      if (entry.key != providers.keys.last) {
        items.add(
          const PopupMenuDivider(),
        );
      }
    }

    return items;
  }

  IconData _getModelIcon(String provider) {
    switch (provider.toLowerCase()) {
      case 'openai':
        return Icons.smart_toy;
      case 'anthropic':
        return Icons.psychology;
      case 'google':
        return Icons.explore;
      default:
        return Icons.auto_awesome;
    }
  }
} 