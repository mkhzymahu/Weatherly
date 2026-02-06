import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          if (!settings.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom AppBar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      // Temperature Unit Section
                      _buildModernSection(
                        context,
                        icon: Icons.thermostat,
                        title: 'Temperature Unit',
                        child: _buildTemperatureUnitSelector(context, settings),
                      ),
                      const SizedBox(height: 16),
                      // Theme Section
                      _buildModernSection(
                        context,
                        icon: Icons.palette,
                        title: 'Appearance',
                        child: _buildThemeSelector(context, settings),
                      ),
                      const SizedBox(height: 16),
                      // Notifications Section
                      _buildModernSection(
                        context,
                        icon: Icons.notifications_active,
                        title: 'Notifications',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Enable Notifications',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Weather alerts & updates',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch.adaptive(
                                    value: settings.notificationsEnabled,
                                    onChanged: (value) {
                                      settings.setNotifications(value);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Refresh Interval Section
                      _buildModernSection(
                        context,
                        icon: Icons.schedule,
                        title: 'Auto Refresh',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Refresh Interval',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${settings.refreshInterval} min',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 6,
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 12,
                                  ),
                                  overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 16,
                                  ),
                                ),
                                child: Slider(
                                  value: settings.refreshInterval.toDouble(),
                                  min: 5,
                                  max: 60,
                                  divisions: 11,
                                  label: '${settings.refreshInterval} min',
                                  onChanged: (value) {
                                    settings.setRefreshInterval(value.toInt());
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '5 min',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    Text(
                                      '60 min',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // About Section
                      _buildModernSection(
                        context,
                        icon: Icons.info,
                        title: 'About',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _buildAboutTile('App Version', '1.0.0'),
                              const Divider(height: 20),
                              _buildAboutTile('Weather Data', 'OpenWeatherMap API'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModernSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!
                  : Colors.white,
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]!
                  : Colors.grey[50]!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.08,
              ),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: Theme.of(context).primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTile(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureUnitSelector(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[700]
            : Colors.grey[200],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUnitButton(
            context,
            'C',
            settings.temperatureUnit == 'C',
            () => settings.setTemperatureUnit('C'),
          ),
          _buildUnitButton(
            context,
            'F',
            settings.temperatureUnit == 'F',
            () => settings.setTemperatureUnit('F'),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitButton(
    BuildContext context,
    String unit,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          '°$unit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final themes = {
      ThemeMode.light: ('Light', Icons.light_mode),
      ThemeMode.dark: ('Dark', Icons.dark_mode),
      ThemeMode.system: ('System', Icons.brightness_auto),
    };

    return Column(
      children: themes.entries.map((entry) {
        final isSelected = entry.key == settings.themeMode;
        return GestureDetector(
          onTap: () => settings.setThemeMode(entry.key),
          child: Container(
            margin: EdgeInsets.only(
              bottom: entry != themes.entries.last ? 8 : 0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 2,
              ),
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  entry.value.$2,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[500],
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  entry.value.$1,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
