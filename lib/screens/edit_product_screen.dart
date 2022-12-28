import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/product_model.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  static const routeName = '/edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _isInit = true;

  var _editedProduct =
      Product(id: '', title: '', description: '', price: 0.0, imageUrl: '');

  var _initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': ''
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    // var uuid = Uuid();
    // _editedProduct = Product(
    //     id: uuid.v1(), title: '', description: '', price: 0.0, imageUrl: '');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context, listen: false)
            .findById(productId as String);
        _initValues = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
          // 'imageUrl': _editedProduct.imageUrl
          'imageUrl': ''
        };

        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() {
    bool _isValid = _form.currentState?.validate() as bool;
    if (!_isValid) return;
    _form.currentState?.save();
    if (_editedProduct.id == '') {
      Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
    } else {
      Provider.of<Products>(context, listen: false)
          .editProduct(_editedProduct.id, _editedProduct);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _form,
            child: SingleChildScrollView(
                child: Column(children: [
              TextFormField(
                initialValue: _initValues['title'],
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                onSaved: (value) {
                  if (value == null) return;
                  _editedProduct = Product(
                      id: _editedProduct.id,
                      title: value,
                      description: _editedProduct.description,
                      price: _editedProduct.price,
                      isFavorite: _editedProduct.isFavorite,
                      imageUrl: _editedProduct.imageUrl);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please provide a value';
                  }
                  if ((value as String).isEmpty) {
                    return 'Please provide a value';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initValues['price'],
                decoration: const InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please enter a price';
                  }
                  if (value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Please enter a number greater than 0';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value == null) return;
                  _editedProduct = Product(
                      id: _editedProduct.id,
                      title: _editedProduct.title,
                      description: _editedProduct.description,
                      isFavorite: _editedProduct.isFavorite,
                      price: double.parse(value),
                      imageUrl: _editedProduct.imageUrl);
                },
              ),
              TextFormField(
                initialValue: _initValues['description'],
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if (value == null) {
                    return 'Please provide a description';
                  }
                  if (value.isEmpty) {
                    return 'Please provide a description';
                  }
                  if (value.length < 10) {
                    return 'Should be atleast 10 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value == null) return;
                  _editedProduct = Product(
                      id: _editedProduct.id,
                      title: _editedProduct.title,
                      isFavorite: _editedProduct.isFavorite,
                      description: value,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl);
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey)),
                    child: _imageUrlController.text.isEmpty
                        ? const Text("Enter a url")
                        : FittedBox(
                            child: Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Expanded(
                      child: TextFormField(
                    // initialValue: _initValues['imageUrl'],
                    decoration: InputDecoration(labelText: 'Image URL'),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    controller: _imageUrlController,
                    focusNode: _imageUrlFocusNode,
                    validator: (value) {
                      if (value == null) {
                        return 'Please enter an image URL';
                      }
                      if (value.isEmpty) {
                        return 'Please enter an image URL';
                      }
                      if (!value.startsWith('http') &&
                          !value.startsWith('https')) {
                        return 'Please enter a valid image URL';
                      }
                      if (!value.endsWith('.png') &&
                          !value.endsWith('.jpg') &&
                          !value.endsWith('.jpeg')) {
                        return 'Please enter a valid image URL';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (value == null) return;
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          isFavorite: _editedProduct.isFavorite,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: value);
                    },
                    onEditingComplete: () {
                      setState(() {});
                    },
                    onFieldSubmitted: (_) {
                      _saveForm();
                    },
                  )),
                ],
              )
            ]))),
      ),
    );
  }
}