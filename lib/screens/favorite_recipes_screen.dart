import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/recipe_card.dart';

class FavoriteRecipesScreen extends StatefulWidget {
  final Set<String> favoriteRecipes;
  final List<dynamic> allRecipes;

  FavoriteRecipesScreen({
    required this.favoriteRecipes,
    required this.allRecipes,
  });

  @override
  _FavoriteRecipesScreenState createState() => _FavoriteRecipesScreenState();
}

class _FavoriteRecipesScreenState extends State<FavoriteRecipesScreen> {
  late Set<String> _favoriteRecipes;
  late List<dynamic> _allRecipes;

  @override
  void initState() {
    super.initState();
    // Inicialize os filtros e receitas com os valores fornecidos
    _favoriteRecipes = widget.favoriteRecipes;
    _allRecipes = widget.allRecipes;
  }

  @override
  Widget build(BuildContext context) {
    // Filtra as receitas favoritas com base na URL
    final favoriteRecipesList = _allRecipes
        .where((recipe) => _favoriteRecipes.contains(recipe['recipe']['url']))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Image.network(
          'https://i.postimg.cc/rF3xyPGc/Black-And-White-Aesthetic-Minimalist-Modern-Simple-Typography-Coconut-Cosmetics-Logo-removebg-previe.png',
          height: 32,
          fit: BoxFit.cover,
        ),
        backgroundColor: Color(0xFFFB8500),
      ),
      body: favoriteRecipesList.isEmpty
          ? Center(
              child: Text(
                'Você ainda não tem favoritos :(',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: favoriteRecipesList.length,
              itemBuilder: (context, index) {
                final recipe = favoriteRecipesList[index]['recipe'];
                return _buildRecipeCard(recipe);
              },
            ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final preparationUrl = recipe['url'] ?? '';
    final recipeId = preparationUrl; // Pode ser usado um ID único se disponível
    final isFavorite = _favoriteRecipes.contains(recipeId);

    return RecipeCard(
      recipe: recipe,
      isFavorite: isFavorite,
      onFavoriteToggle: _toggleFavorite,
      onTap: _launchURL,
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o URL: $url';
    }
  }

  void _toggleFavorite(String recipeId) {
    setState(() {
      if (_favoriteRecipes.contains(recipeId)) {
        _favoriteRecipes.remove(recipeId);
      } else {
        _favoriteRecipes.add(recipeId);
      }
    });
  }
}
