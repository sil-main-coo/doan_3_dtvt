class ProductModel {
  String? id;
  String? sanXuat;
  String? ten;
  int? trongLuong;
  String? xuatXu;
  DateTime? timeScan;
  String? image;
  String? gia;

  ProductModel({this.sanXuat, this.ten, this.trongLuong, this.xuatXu});

  ProductModel.fromJson(Map<String, dynamic> json,
      {String? id, String? image}) {
    if (id == null) {
      this.id = json['id'];
    } else {
      this.id = id;
    }
    this.image = image;
    gia = json['gia'].toString();
    sanXuat = json['san-xuat'];
    ten = json['ten'];
    trongLuong = json['trong-luong'];
    xuatXu = json['xuat-xu'];
    if (json['timeScan'] != null) {
      timeScan = DateTime.fromMillisecondsSinceEpoch(json['timeScan'] * 1000);
    } else {
      timeScan = DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['san-xuat'] = this.sanXuat;
    data['ten'] = this.ten;
    data['trong-luong'] = this.trongLuong;
    data['xuat-xu'] = this.xuatXu;
    data['timeScan'] = this.timeScan!.millisecondsSinceEpoch;
    data['gia'] = this.gia;
    data['image'] = this.image;
    return data;
  }
}
