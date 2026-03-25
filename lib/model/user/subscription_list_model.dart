//
//
//
// class SubscriptionData {
//   ResponseData? responseData;
//
//   SubscriptionData({this.responseData});
//
//   SubscriptionData.fromJson(Map<String, dynamic> json) {
//     responseData = json['responseData'] != null
//         ? new ResponseData.fromJson(json['responseData'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.responseData != null) {
//       data['responseData'] = this.responseData!.toJson();
//     }
//     return data;
//   }
// }
//
// class ResponseData {
//   Pagination? pagination;
//   List<SubscriptionListData>? data;
//
//   ResponseData({this.pagination, this.data});
//
//   ResponseData.fromJson(Map<String, dynamic> json) {
//     pagination = json['pagination'] != null
//         ? new Pagination.fromJson(json['pagination'])
//         : null;
//     if (json['data'] != null) {
//       data = <SubscriptionListData>[];
//       json['data'].forEach((v) {
//         data!.add(new SubscriptionListData.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.pagination != null) {
//       data['pagination'] = this.pagination!.toJson();
//     }
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Pagination {
//   int? totalItems;
//   int? perPage;
//   int? currentPage;
//   int? totalPages;
//
//   Pagination(
//       {this.totalItems, this.perPage, this.currentPage, this.totalPages});
//
//   Pagination.fromJson(Map<String, dynamic> json) {
//     totalItems = json['total_items'];
//     perPage = json['per_page'];
//     currentPage = json['currentPage'];
//     totalPages = json['totalPages'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['total_items'] = this.totalItems;
//     data['per_page'] = this.perPage;
//     data['currentPage'] = this.currentPage;
//     data['totalPages'] = this.totalPages;
//     return data;
//   }
// }
//
// class SubscriptionListData {
//   int? id;
//   String? productIdentifier;
//   String? purchaseDate;
//   String? amount;
//   String? store;
//   String? storeTransactionId;
//   String? originalAppUserId;
//   String? createdAt;
//   String? updatedAt;
//
//   SubscriptionListData(
//       {this.id,
//         this.productIdentifier,
//         this.purchaseDate,
//         this.amount,
//         this.store,
//         this.storeTransactionId,
//         this.originalAppUserId,
//         this.createdAt,
//         this.updatedAt});
//
//   SubscriptionListData.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     productIdentifier = json['product_identifier'];
//     purchaseDate = json['purchase_date'];
//     amount = json['amount'];
//     store = json['store'];
//     storeTransactionId = json['store_transaction_id'];
//     originalAppUserId = json['original_app_user_id'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['product_identifier'] = this.productIdentifier;
//     data['purchase_date'] = this.purchaseDate;
//     data['amount'] = this.amount;
//     data['store'] = this.store;
//     data['store_transaction_id'] = this.storeTransactionId;
//     data['original_app_user_id'] = this.originalAppUserId;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
//
