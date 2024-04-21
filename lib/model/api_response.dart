class ApiResponse {
  bool? status;
  Product? value;
  String? message;

  ApiResponse({this.status, this.value, this.message});

  ApiResponse.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    value = json['value'] != null ? Product.fromJson(json['value']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Status'] = status;
    if (value != null) {
      data['value'] = value!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Product {
  String? product;
  String? exdate;
  String? price;

  Product({this.product, this.exdate, this.price});

  Product.fromJson(Map<String, dynamic> json) {
    product = json['product'];
    exdate = json['exdate'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product'] = product;
    data['exdate'] = exdate;
    data['price'] = price;
    return data;
  }
}
