import 'package:flutter/material.dart';

class LocationSearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const LocationSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  State<LocationSearchBar> createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  late TextEditingController _controller;
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  // Popular cities for autocomplete
  final List<String> _citySuggestions = [
    'London',
    'New York',
    'Los Angeles',
    'Chicago',
    'Houston',
    'Phoenix',
    'Philadelphia',
    'San Antonio',
    'San Diego',
    'Dallas',
    'San Jose',
    'Austin',
    'Jacksonville',
    'Portland',
    'Seattle',
    'Denver',
    'Boston',
    'Miami',
    'Atlanta',
    'Vegas',
    'Tokyo',
    'Delhi',
    'Shanghai',
    'São Paulo',
    'Mexico City',
    'Cairo',
    'Mumbai',
    'Beijing',
    'Osaka',
    'Moscow',
    'Istanbul',
    'Paris',
    'Barcelona',
    'Rome',
    'Berlin',
    'Madrid',
    'Amsterdam',
    'Vienna',
    'Prague',
    'Budapest',
    'Dubai',
    'Bangkok',
    'Singapore',
    'Hong Kong',
    'Sydney',
    'Melbourne',
    'Toronto',
    'Vancouver',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_filterSuggestions);
  }

  @override
  void dispose() {
    _controller.removeListener(_filterSuggestions);
    _controller.dispose();
    super.dispose();
  }

  void _filterSuggestions() {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _suggestions = _citySuggestions
          .where((city) => city.toLowerCase().startsWith(query))
          .toList();
      _showSuggestions = _suggestions.isNotEmpty;
    });
  }

  void _selectSuggestion(String city) {
    _controller.text = city;
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
    _search();
  }

  void _search() {
    final city = _controller.text.trim();
    if (city.isNotEmpty) {
      widget.onSearch(city);
      _controller.clear();
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search city...',
              prefixIcon: const Icon(Icons.location_on),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _showSuggestions = false;
                          _suggestions = [];
                        });
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _search,
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _search(),
          ),
          // Suggestions dropdown
          if (_showSuggestions && _suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _suggestions
                    .take(5) // Show max 5 suggestions
                    .map(
                      (city) => InkWell(
                        onTap: () => _selectSuggestion(city),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                city,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
