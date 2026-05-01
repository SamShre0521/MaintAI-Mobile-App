import 'package:flutter/material.dart';

class IssueResolutionPrompt extends StatelessWidget {
  final VoidCallback onResolved;
  final VoidCallback onNotResolved;

  const IssueResolutionPrompt({
    super.key,
    required this.onResolved,
    required this.onNotResolved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4DCC8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Is your issue resolved?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E2E2E),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ResolutionButton(
                  icon: Icons.thumb_up_alt_rounded,
                  iconColor: Color(0xFF22C55E),
                  text: 'Yes, resolved',
                  onTap: onResolved,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResolutionButton(
                  icon: Icons.thumb_down_alt_rounded,
                  iconColor: Color(0xFFEF4444),
                  text: 'No, not resolved',
                  onTap: onNotResolved,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResolutionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final VoidCallback onTap;

  const _ResolutionButton({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4DCC8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}