import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final bool isFavorite;
  final void Function(String) onFavoriteToggle;
  final void Function(String) onTap;

  RecipeCard({
    required this.recipe,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = recipe['image'] ?? '';
    final label = recipe['label'] ?? 'Sem nome';
    final calories = (recipe['calories'] as double?)?.toInt() ?? 0;
    final cuisineType =
        (recipe['cuisineType'] as List?)?.join(', ') ?? 'Não disponível';
    final ingredients = (recipe['ingredients'] as List?)?.length ?? 0;
    final preparationUrl = recipe['url'] ?? '';
    final recipeId = preparationUrl;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: InkWell(
        onTap: () => onTap(preparationUrl),
        child: Card(
          elevation: 5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text('Calorias: $calories',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Tipo de culinária: $cuisineType',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Ingredientes: $ingredients',
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () => onFavoriteToggle(recipeId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
