import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import './edit_product_screen.dart';
import '../providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = 'user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context).getProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final productsList = productsData.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: productsData.items.length,
            itemBuilder: (ctx, index) => Column(
              children: <Widget>[
                UserProductItem(productsList[index].id,
                    productsList[index].title, productsList[index].imageUrl),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
