import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart';
import 'add_category_screen.dart';

class CategoryScreen extends StatelessWidget {
  static const routeName = '/categories';

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: StreamBuilder<List<CategoryModel>>(
        stream: categoryProvider.streamCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading categories'));
          }
          final categories = snapshot.data ?? [];
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryItem(category: category);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddCategoryScreen.routeName);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final CategoryModel category;

  const CategoryItem({required this.category});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      elevation: 4,
      child: ListTile(
        leading: category.image.isNotEmpty
            ? CachedNetworkImage(

          width: 50,
          height: 50,
          fit: BoxFit.cover, imageUrl: category.image,
        )
            : Icon(Icons.category, size: 50),
        title: Text(category.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: GestureDetector(
          onTap: () async {
            await categoryProvider.updateCategory(category.id, {'isFeatured': !(category.isFeatured ?? false)});
          },
          child: Row(
            children: [
              Text('Featured: '),
              Icon(
                category.isFeatured ?? false ? Icons.check_circle : Icons.check_circle_outline,
                color: category.isFeatured ?? false ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Navigate to edit category screen
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await categoryProvider.deleteCategory(category.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
