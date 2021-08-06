import 'package:cached_network_image/cached_network_image.dart';
import 'package:do_an_3/product_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _databaseReference =
      FirebaseDatabase.instance.reference().child('do-an-3');
  final _refImageStorage = FirebaseStorage.instance.ref().child('do-an-3');

  List<ProductModel> _products = [];

  bool _isFirst = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    _databaseReference.child('qr-code').onValue.listen((event) async {
      if (_isFirst) {
        _isFirst = false;
      } else {
        _showLoadingDialog();
        final product = await _getProductByID(event.snapshot.value);
        if (product != null) {
          setState(() {
            _products.insert(0, product);
            Navigator.pop(context); // đóng loading
            _showInfoDialog(product);
          });
        } else {
          Navigator.pop(context); // đóng loading
          _notExist(event.snapshot.value);
        }
      }
    });
  }

  Future _notExist(value) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Sản phẩm không tồn tại'),
              content:
                  Text('Mã sản phẩm "$value" không tồn tại trong hệ thống'),
              actions: [
                RaisedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK',
                    style: Theme.of(context)
                        .textTheme
                        .button!
                        .copyWith(color: Colors.white),
                  ),
                  color: Colors.blue,
                ),
              ],
            ));
  }

  Future _showInfoDialog(ProductModel productModel) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24))),
              child: Container(
                height: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    if (productModel.image != null)
                      SizedBox(
                        height: 80,
                        width: 120,
                        child: CachedNetworkImage(
                          imageUrl: productModel.image!,
                          placeholder: (context, url) => SizedBox(),
                          errorWidget: (context, url, error) => Icon(
                            Icons.error,
                            size: 24,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Tên: ${productModel.ten!}',
                      style: Theme.of(context).textTheme.title,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                        'Trọng lượng: ${productModel.trongLuong!.toString()}g'),
                    SizedBox(
                      height: 8,
                    ),
                    Text('Sản xuất: ${productModel.sanXuat!}'),
                    SizedBox(
                      height: 8,
                    ),
                    Text('Xuất xứ: ${productModel.xuatXu!}'),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Giá: '),
                        Text(
                          '${productModel.gia!}',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RaisedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'HỦY BỎ',
                            style: Theme.of(context)
                                .textTheme
                                .button!
                                .copyWith(color: Colors.white),
                          ),
                          color: Colors.red,
                        ),
                        RaisedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'Thanh toán thành công',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            ));
                          },
                          child: Text(
                            'THANH TOÁN',
                            style: Theme.of(context)
                                .textTheme
                                .button!
                                .copyWith(color: Colors.white),
                          ),
                          color: Colors.blue,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ));
  }

  void _showLoadingDialog() {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: const CircularProgressIndicator(),
            ));
  }

  Future<ProductModel?> _getProductByID(String id) async {
    try {
      final snapshot =
          await _databaseReference.child('san-phams').child(id).once();
      if (snapshot.value != null) {
        final json = Map<String, dynamic>.from(snapshot.value);
        final image = await _getImage(id);

        return ProductModel.fromJson(json, id: id, image: image);
      }

      return null;
    } catch (e) {
      throw e;
    }
  }

  Future<String?> _getImage(String id) async {
    try {
      return await _refImageStorage.child('$id.png').getDownloadURL();
    } catch (e) {
      try {
        return await _refImageStorage.child('$id.jpg').getDownloadURL();
      } catch (ex) {}
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách sản phẩm'),
      ),
      body: ListView(
        children: List<Widget>.generate(
            _products.length,
            (index) => ListTile(
                  onTap: () => _showInfoDialog(_products[index]),
                  contentPadding: const EdgeInsets.all(8),
                  leading: (_products[index].image != null)
                      ? SizedBox(
                          height: 50,
                          width: 80,
                          child: CachedNetworkImage(
                            imageUrl: _products[index].image!,
                            placeholder: (context, url) => SizedBox(),
                            errorWidget: (context, url, error) => Icon(
                              Icons.error,
                              size: 24,
                            ),
                          ),
                        )
                      : null,
                  title: Column(
                    children: [
                      Text(_products[index].ten!),
                      Text('Giá: ${_products[index].gia!}',
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  trailing: Text(
                    'Quét lúc: ${_products[index].timeScan!.hour}:${_products[index].timeScan!.minute}:${_products[index].timeScan!.second}',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11),
                  ),
                )),
      ),
    );
  }
}
