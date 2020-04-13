import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  UserProductItem(this.id, this.title, this.imageUrl);

  Future<void> _deleteProduct(
      BuildContext context, ScaffoldState scaffold, String productId) async {
    try {
      await Provider.of<Products>(context, listen: false).deleteProduct(id);
      scaffold.showSnackBar(SnackBar(
        content: Text('Item deleted successfully.', textAlign: TextAlign.center,),
      ));
    } catch (error) {
      scaffold.showSnackBar(SnackBar(
        content: Text('Delete item failed.', textAlign: TextAlign.center,),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).errorColor,
              ),
              onPressed: () async => _deleteProduct(context, scaffold, id),
            ),
          ],
        ),
      ),
    );
  }
}
