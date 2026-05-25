import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

enum FeevoButtonStyle { primary, ghost, danger }

class FeevoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final FeevoButtonStyle style;
  final bool isLoading;
  final double? width;
  final double height;
  final Widget? icon;

  const FeevoButton({
    super.key,
    required this.label,
    this.onTap,
    this.style = FeevoButtonStyle.primary,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (style) {
      case FeevoButtonStyle.primary:
        return _PrimaryButton(
          label: label,
          onTap: onTap,
          isLoading: isLoading,
          height: height,
          icon: icon,
        );
      case FeevoButtonStyle.ghost:
        return _GhostButton(
          label: label,
          onTap: onTap,
          height: height,
          icon: icon,
        );
      case FeevoButtonStyle.danger:
        return _DangerButton(
          label: label,
          onTap: onTap,
          height: height,
        );
    }
  }
}

// ── Primary gradient button ──────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final double height;
  final Widget? icon;

  const _PrimaryButton({
    required this.label,
    this.onTap,
    this.isLoading = false,
    required this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            gradient: onTap == null
                ? const LinearGradient(
                    colors: [Color(0xFF4A2A8A), Color(0xFF045A6A)],
                  )
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: onTap == null
                ? []
                : [
                    BoxShadow(
                      color: AppColors.purple.withOpacity(0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Ghost button ─────────────────────────────────────────────
class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  final Widget? icon;

  const _GhostButton({
    required this.label,
    this.onTap,
    required this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 8)],
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.purple3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Danger button ─────────────────────────────────────────────
class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;

  const _DangerButton({
    required this.label,
    this.onTap,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0x4DEF4444)),
        backgroundColor: AppColors.errorBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.error,
        ),
      ),
    );
  }
}
