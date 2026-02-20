import 'package:flutter/material.dart';
import '../../constants.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'Tout';
  final List<String> _filters = ['Tout', 'Publications', 'Groupes', 'Personnes'];

  final List<Map<String, dynamic>> _recentSearches = [
    {'term': 'Projet Alpha', 'type': 'publication'},
    {'term': 'Direction Technique', 'type': 'groupe'},
    {'term': 'Marie Dupont', 'type': 'personne'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              hintStyle: const TextStyle(color: AppColors.textHint),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: const Color.fromARGB(255, 252, 251, 255),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                      },
                      selectedColor: AppColors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : const Color.fromARGB(255, 0, 0, 0),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: AppColors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      body: _searchController.text.isEmpty
          ? _buildRecentSearches()
          : _buildSearchResults(),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recherches récentes',
                style: AppTextStyles.heading3,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _recentSearches.clear();
                  });
                },
                child: const Text('Effacer'),
              ),
            ],
          ),
        ),
        ..._recentSearches.map((search) {
          IconData icon;
          switch (search['type']) {
            case 'publication':
              icon = Icons.article;
              break;
            case 'groupe':
              icon = Icons.group;
              break;
            case 'personne':
              icon = Icons.person;
              break;
            default:
              icon = Icons.history;
          }
          return ListTile(
            leading: Icon(icon, color: AppColors.textSecondary),
            title: Text(search['term']),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                setState(() {
                  _recentSearches.remove(search);
                });
              },
            ),
            onTap: () {
              _searchController.text = search['term'];
              setState(() {});
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView(
      children: [
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.article, color: AppColors.white),
          ),
          title: const Text('Résultat de recherche 1'),
          subtitle: const Text('Publication • Il y a 2h'),
          onTap: () {},
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}