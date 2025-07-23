import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../consts/app_colors.dart';
import '../models/ai_model.dart';
import '../providers/chat_provider.dart';
import 'package:provider/provider.dart';

class IOSDropdownMenu extends StatefulWidget {
  final VoidCallback? onModelSelected;
  
  const IOSDropdownMenu({
    super.key,
    this.onModelSelected,
  });

  @override
  State<IOSDropdownMenu> createState() => _IOSDropdownMenuState();
}

class _IOSDropdownMenuState extends State<IOSDropdownMenu> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showDropdown() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            width: 230,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 50),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground.resolveFrom(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CupertinoColors.separator.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...ModelConfiguration.availableModels.map((model) => 
                          _buildModelOption(model)
                        ).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  

  Widget _buildModelOption(AIModel model) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final isSelected = chatProvider.selectedModel?.id == model.id;
        
        return CupertinoButton(
          padding: EdgeInsets.zero,
                     onPressed: () {
             chatProvider.setSelectedModel(model);
             widget.onModelSelected?.call();
             _removeOverlay();
           },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                ? CupertinoColors.activeBlue.withOpacity(0.1)
                : null,
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator.resolveFrom(context),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label.resolveFrom(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        model.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.secondaryLabel.resolveFrom(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    CupertinoIcons.check_mark,
                    size: 16,
                    color: CupertinoColors.activeBlue,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _showDropdown,
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  chatProvider.selectedModel?.name ?? 'ChatGPT',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, 
                    fontSize: 16
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 13,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
} 