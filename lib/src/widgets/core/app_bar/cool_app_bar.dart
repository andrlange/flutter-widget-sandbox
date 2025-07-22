import 'package:flutter/material.dart';

class CoolAppBar extends StatelessWidget implements PreferredSizeWidget {
  CoolAppBar({super.key, this.menuOnRight = false,});

  late bool isMainPage;

  /// The title to display when [isMainPage] is false.
  String? pageTitle;

  /// If true, the navigation menu icon appears on the right.
  /// If false (default), it appears on the left.
  final bool menuOnRight;

  /// URL for the avatar image. If null or empty, [avatarFallbackText] is used.
  String? avatarImageUrl;

  /// Fallback text for the avatar when no image is available (e.g., "AB").
  String? avatarFallbackText;

  /// Background color for the avatar when [avatarFallbackText] is used.
  late Color avatarBackgroundColor;

  /// List of custom action widgets to display on the right side of the app bar,
  /// before the avatar and exit button.
  late List<Widget> rightActions;

  /// Callback for when the home icon is pressed.
  VoidCallback? onHomePressed;

  /// Callback for when the exit icon is pressed.
  VoidCallback? onExitPressed;

  /// Callback for when the menu icon is pressed.
  VoidCallback? onMenuPressed;

  /// The height of the app bar, typically [kToolbarHeight].
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    this.isMainPage = true;
    this.pageTitle;
    this.avatarImageUrl;
    this.avatarFallbackText = 'JD'; // Default fallback text
    this.avatarBackgroundColor = Colors.blueGrey;
    this.rightActions = const [];
    this.onHomePressed;
    this.onExitPressed;
    this.onMenuPressed;

    // Common action buttons
    final Widget menuButton = IconButton(
      icon: const Icon(Icons.menu, color: Colors.black),
      onPressed: null,
    );
    final Widget homeButton = IconButton(
      icon: const Icon(Icons.home, color: Colors.black),
      onPressed: null,
    );
    final Widget exitButton = IconButton(
      icon: const Icon(Icons.exit_to_app, color: Colors.black),
      onPressed: null,
    );

    // Center content (Company Logo or Page Title)
    final Widget centerContent = isMainPage
        ? _buildCompanyLogo()
        : Text(
            pageTitle ?? 'Page Title',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          );

    // Build the avatar widget
    final Widget avatar = _buildAvatar();

    // Assemble the left and right side widgets based on configuration
    final List<Widget> leftSideWidgets = <Widget>[];
    final List<Widget> rightSideWidgets = <Widget>[];

    if (menuOnRight) {
      // If menu is on the right, home is the only icon on the far left.
      leftSideWidgets.add(homeButton);
      rightSideWidgets.add(menuButton);
    } else {
      // Default: menu and home are on the left.
      leftSideWidgets.add(menuButton);
      leftSideWidgets.add(homeButton);
    }

    // Add injectable actions, avatar, and exit button to the right side

    rightSideWidgets.add(avatar);
    rightSideWidgets.add(exitButton);
    rightSideWidgets.insertAll(0, rightActions); //
    // Insert
    // custom actions

    return Container(
      color: Colors.grey[300], // Background color #ddd
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Left side
              Row(children: leftSideWidgets),
              // Center (Expanded to allow flexible spacing for content)
              Expanded(child: Center(child: centerContent)),
              // Right side
              Row(children: rightSideWidgets),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the company logo widget.
  Widget _buildCompanyLogo() {
    return Image.network(
      'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
      height: kToolbarHeight * 0.6,
      fit: BoxFit.contain,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return const Icon(
              Icons.business,
              color: Colors.black,
              size: kToolbarHeight * 0.5,
            ); // Fallback icon for logo
          },
    );
  }

  /// Builds the avatar widget, supporting image or fallback text.
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 18, // Slightly larger for better tap target
      backgroundColor: avatarBackgroundColor,
      child: avatarImageUrl != null && avatarImageUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                avatarImageUrl!,
                width: 36, // Match CircleAvatar radius * 2
                height: 36,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) => _buildFallbackAvatar(avatarFallbackText),
              ),
            )
          : _buildFallbackAvatar(avatarFallbackText),
    );
  }

  /// Builds the fallback text avatar.
  Widget _buildFallbackAvatar(String? fallbackText) {
    return Text(
      (fallbackText ?? '?').toUpperCase(), // Ensure uppercase for fallback
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
