import 'dart:math';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:receitas_app/screens/favorite_recipes_screen.dart';
import '../widgets/recipe_card.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receitaria',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFFFB703),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFB8500),
          foregroundColor: Colors.white,
        ),
      ),
      home: RecipeListScreen(),
    );
  }
}

class RecipeListScreen extends StatefulWidget {
  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _recipes;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Set<String> _favoriteRecipes = {};
  List<dynamic> _featuredRecipes = [];

  // Armazena os filtros temporários e finais
  Map<String, bool> _filters = {
    'american': false,
    'asian': false,
    'indian': false,
    'vegan': false,
    'vegetarian': false,
    'wheat-free': false,
    'gluten-free': false,
    'breakfast': false,
    'lunch/dinner': false,
    'starter': false,
    'main course': false,
    'desserts': false,
    'pasta': false,
  };

  // Filtros temporários enquanto o modal está aberto
  Map<String, bool> _tempFilters = {};

  @override
  void initState() {
    super.initState();
    _fetchRandomRecipes();
  }

  void _fetchRandomRecipes() {
    setState(() {
      _recipes = _apiService.searchRecipes('random').then((data) {
        setState(() {
          _featuredRecipes = List.from(data['hits'])
            ..shuffle()
            ..take(4).toList();
        });
        return data;
      });
      _isSearching = false;
    });
  }

  void _searchRecipes() {
    final Map<String, dynamic> activeFilters = {};

    // Adiciona filtros ativos
    _filters.forEach((key, value) {
      if (value) {
        if (key == 'american' || key == 'asian' || key == 'indian') {
          if (activeFilters.containsKey('cuisineType')) {
            activeFilters['cuisineType'] += ',${key}';
          } else {
            activeFilters['cuisineType'] = key;
          }
        }
      }

      if (value) {
        if (key == 'breakfast' || key == 'lunch/dinner') {
          if (activeFilters.containsKey('mealType')) {
            activeFilters['mealType'] += ',${key}';
          } else {
            activeFilters['mealType'] = key;
          }
        }
      }

      if (value) {
        if (key == 'vegetarian' ||
            key == 'vegan' ||
            key == 'wheat-free' ||
            key == 'gluten-free') {
          if (activeFilters.containsKey('Health')) {
            activeFilters['Health'] += ',${key}';
          } else {
            activeFilters['Health'] = key;
          }
        }
      }

      if (value) {
        if (key == 'desserts' ||
            key == 'pasta' ||
            key == 'starter' ||
            key == 'main course') {
          if (activeFilters.containsKey('dishType')) {
            activeFilters['dishType'] += ',${key}';
          } else {
            activeFilters['dishType'] = key;
          }
        }
      }
    });

    setState(() {
      _recipes = _apiService.searchRecipes(
        _searchController.text,
        filters: activeFilters,
      );
      _isSearching = true;
    });
  }

  void _resetToHome() {
    _searchController.clear();
    _fetchRandomRecipes();
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

  void _openFilterModal() {
    setState(() {
      _tempFilters = Map.from(
          _filters); // Copia o estado atual dos filtros para edição temporária
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Para permitir que o modal ocupe mais espaço
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 60.0), // Espaçamento para o botão fixo
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text(
                              'Cozinha',
                              style: TextStyle(
                                fontWeight: FontWeight
                                    .bold, // Define o texto como negrito
                              ),
                            ),
                            subtitle: Column(
                              children: [
                                CheckboxListTile(
                                  title: const Text('Americana'),
                                  value: _tempFilters['american'] ?? false,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _tempFilters['american'] = value ?? false;
                                    });
                                  },
                                ),
                                CheckboxListTile(
                                  title: const Text('Asiática'),
                                  value: _tempFilters['asian'] ?? false,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _tempFilters['asian'] = value ?? false;
                                    });
                                  },
                                ),
                                CheckboxListTile(
                                  title: const Text('Indiana'),
                                  value: _tempFilters['indian'] ?? false,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _tempFilters['indian'] = value ?? false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            title: const Text(
                              'Período',
                              style: TextStyle(
                                fontWeight: FontWeight
                                    .bold, // Define o texto como negrito
                              ),
                            ),
                            subtitle: Column(
                              children: [
                                CheckboxListTile(
                                  title: const Text('Café da manhã'),
                                  value: _tempFilters['breakfast'] ?? false,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _tempFilters['breakfast'] =
                                          value ?? false;
                                    });
                                  },
                                ),
                                CheckboxListTile(
                                  title: const Text('Almoço/Jantar'),
                                  value: _tempFilters['lunch/dinner'] ?? false,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _tempFilters['lunch/dinner'] =
                                          value ?? false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            title: const Text(
                              'Dieta',
                              style: TextStyle(
                                fontWeight: FontWeight
                                    .bold, // Define o texto como negrito
                              ),
                            ),
                            subtitle: Column(
                              children: [
                                CheckboxListTile(
                                  title: const Text('Vegetariana'),
                                  value: _tempFilters['vegetarian'] ?? false,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _tempFilters['vegetarian'] =
                                          value ?? false;
                                    });
                                  },
                                ),
                                CheckboxListTile(
                                  title: const Text('Vegana'),
                                  value: _tempFilters['vegan'] ?? false,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _tempFilters['vegan'] = value ?? false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            title: const Text(
                              'Restrições',
                              style: TextStyle(
                                fontWeight: FontWeight
                                    .bold, // Define o texto como negrito
                              ),
                            ),
                            subtitle: Column(
                              children: [
                                CheckboxListTile(
                                  title: const Text('Sem glúten'),
                                  value: _tempFilters['gluten-free'] ?? false,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _tempFilters['gluten-free'] =
                                          value ?? false;
                                    });
                                  },
                                ),
                                CheckboxListTile(
                                  title: const Text('Sem farinha de trigo'),
                                  value: _tempFilters['wheat-free'] ?? false,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _tempFilters['wheat-free'] =
                                          value ?? false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            title: const Text(
                              'Tipo',
                              style: TextStyle(
                                fontWeight: FontWeight
                                    .bold, // Define o texto como negrito
                              ),
                            ),
                            subtitle: Column(
                              children: [
                                CheckboxListTile(
                                  title: const Text('Sobremesas'),
                                  value: _tempFilters['desserts'] ?? false,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _tempFilters['desserts'] = value ?? false;
                                    });
                                  },
                                ),
                                CheckboxListTile(
                                  title: const Text('Massas'),
                                  value: _tempFilters['pasta'] ?? false,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _tempFilters['pasta'] = value ?? false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            title: const Text(
                              'Categoria',
                              style: TextStyle(
                                fontWeight: FontWeight
                                    .bold, // Define o texto como negrito
                              ),
                            ),
                            subtitle: Column(
                              children: [
                                CheckboxListTile(
                                  title: const Text('Entradas'),
                                  value: _tempFilters['starter'] ?? false,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _tempFilters['starter'] = value ?? false;
                                    });
                                  },
                                ),
                                CheckboxListTile(
                                  title: const Text('Prato principal'),
                                  value: _tempFilters['main course'] ?? false,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _tempFilters['main course'] =
                                          value ?? false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    left: 320,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filters = Map.from(_tempFilters);
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // Cor do texto
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor:
                            const Color(0xFFFB8500), // Cor de fundo
                        textStyle: const TextStyle(
                          fontSize: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text('Aplicar filtros'),
                    ),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFFB8500),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Página Inicial'),
              onTap: () {
                Navigator.pop(context);
                _fetchRandomRecipes();
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoriteRecipesScreen(
                      favoriteRecipes: _favoriteRecipes,
                      allRecipes: _featuredRecipes,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Image.network(
                  'https://i.postimg.cc/rF3xyPGc/Black-And-White-Aesthetic-Minimalist-Modern-Simple-Typography-Coconut-Cosmetics-Logo-removebg-previe.png',
                  height: 32, // Ajuste o tamanho conforme necessário
                  fit: BoxFit
                      .cover, // Ajusta a imagem para caber no espaço disponível
                ),
                backgroundColor: const Color(0xFFFB8500),
                pinned: true,
                expandedHeight: 0.0,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 24.0, left: 16.0, right: 16.0, bottom: 12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar receitas...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0), // Ajuste o padding aqui
                        child: IconButton(
                          icon: const Icon(Icons.filter_alt),
                          onPressed: _openFilterModal,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(
                            right: 8.0), // Ajuste o padding aqui
                        child: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _searchRecipes,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (value) => _searchRecipes(),
                  ),
                ),
              ),
              if (_isSearching) ...[
                FutureBuilder<Map<String, dynamic>>(
                  future: _recipes,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(child: Text('Erro: ${snapshot.error}')),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!['hits'].isEmpty) {
                      return const SliverToBoxAdapter(
                        child:
                            Center(child: Text('Nenhuma receita encontrada')),
                      );
                    } else {
                      final recipes = snapshot.data!['hits'];

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final recipe = recipes[index]['recipe'];
                            return _buildRecipeCard(recipe);
                          },
                          childCount: recipes.length,
                        ),
                      );
                    }
                  },
                ),
              ] else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Image.network(
                        'https://i.postimg.cc/Vv3vw2xV/C-pia-de-Black-And-White-Aesthetic-Minimalist-Modern-Simple-Typography-Coconut-Cosmetics-Logo-1.png',
                        height: 32, // Ajuste o tamanho conforme necessário
                        fit: BoxFit
                            .contain, // Ajusta a imagem para caber no espaço disponível
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recipe = _featuredRecipes[index]['recipe'] ?? {};
                      return _buildRecipeCard(recipe);
                    },
                    childCount: min(_featuredRecipes.length, 4),
                  ),
                ),
              ],
            ],
          ),
          if (_isSearching) ...[
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: _resetToHome,
                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                backgroundColor: const Color(0xFFFB8500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final preparationUrl =
        recipe['url'] ?? ''; // Valor padrão para URL do preparo
    final recipeId = preparationUrl; // Pode ser usado um ID único se disponível
    final isFavorite = _favoriteRecipes.contains(recipeId);

    return RecipeCard(
      recipe: recipe,
      isFavorite: isFavorite,
      onFavoriteToggle: _toggleFavorite,
      onTap: _launchURL,
    );
  }
}
