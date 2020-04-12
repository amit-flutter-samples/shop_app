import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = 'edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editProduct =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');

  var _isInt = true;
  var _inItValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInt) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _inItValues = {
          'title': _editProduct.title,
          'description': _editProduct.description,
          'price': _editProduct.price.toString()
        };

        _imageUrlController.text = _editProduct.imageUrl;
      }
    }
    _isInt = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    _resetLoader(true);
    if (_editProduct.id == null) {
      Provider.of<Products>(context, listen: false)
          .addProduct(_editProduct)
          .then((_) {
        _resetLoader(false);
        Navigator.of(context).pop();
      }).catchError((error) {
        _resetLoader(false);
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occured'),
                  content: Text('Something went wrong.'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Okay'),
                      onPressed: () => Navigator.of(ctx).pop(),
                    )
                  ],
                ));
      });
    } else {
      Provider.of<Products>(context, listen: false).updateProduct(_editProduct);
      _resetLoader(false);
      Navigator.of(context).pop();
    }
  }

  void _resetLoader(value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm)
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                autovalidate: true,
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _inItValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        return value.isEmpty ? 'Please enter title' : null;
                      },
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_priceFocusNode),
                      onSaved: (value) {
                        _editProduct = Product(
                            title: value,
                            price: _editProduct.price,
                            description: _editProduct.description,
                            id: _editProduct.id,
                            imageUrl: _editProduct.imageUrl,
                            isFavorite: _editProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _inItValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter price';
                        } else if (double.tryParse(value) == null) {
                          return 'Please enter valid price';
                        } else if (double.parse(value) <= 0) {
                          return 'Please enter positive number';
                        } else {
                          return null;
                        }
                      },
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode),
                      onSaved: (value) {
                        _editProduct = Product(
                            title: _editProduct.title,
                            price: double.parse(value),
                            description: _editProduct.description,
                            id: _editProduct.id,
                            imageUrl: _editProduct.imageUrl,
                            isFavorite: _editProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _inItValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        return value.isEmpty
                            ? 'Please enter description'
                            : null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                            title: _editProduct.title,
                            price: _editProduct.price,
                            description: value,
                            id: _editProduct.id,
                            imageUrl: _editProduct.imageUrl,
                            isFavorite: _editProduct.isFavorite);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter your image url')
                                : FittedBox(
                                    child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover))),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.url,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            validator: (value) {
                              return value.isEmpty ? 'Please enter url' : null;
                            },
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) {
                              _editProduct = Product(
                                  title: _editProduct.title,
                                  price: _editProduct.price,
                                  description: _editProduct.description,
                                  id: _editProduct.id,
                                  imageUrl: value,
                                  isFavorite: _editProduct.isFavorite);
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
