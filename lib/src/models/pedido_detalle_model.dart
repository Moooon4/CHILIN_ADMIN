import 'dart:convert';

// Funciones para convertir entre JSON y PedidoDetalleModel
PedidoDetalleModel pedidoDetalleModelFromJson(String str) => PedidoDetalleModel.fromJson(json.decode(str));

String pedidoDetalleModelToJson(PedidoDetalleModel data) => json.encode(data.toJson());

class PedidoDetalleModel {
  // Propiedades
  String estado;
  DateTime fechaOrden;
  String id;
  List<Item> items;
  String metodoPago;
  num montoTotal;

  // Constructor
  PedidoDetalleModel({
    this.estado     = '',
    required this.fechaOrden,
    this.id         = '',
    this.items      = const [],
    this.metodoPago = '',
    this.montoTotal =  0.0,
  });

  factory PedidoDetalleModel.fromJson(Map<String, dynamic> json) => PedidoDetalleModel(
    estado    : json["estado"],
    fechaOrden: DateTime.parse(json["fechaOrden"]),
    id        : json["id"],
    items     : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    metodoPago: json["metodoPago"],
    montoTotal: json["montoTotal"],
  );

  Map<String, dynamic> toJson() => {
    "estado"    : estado,
    "fechaOrden": fechaOrden.toIso8601String(),
    "id"        : id,
    "items"     : List<dynamic>.from(items.map((x) => x.toJson())),
    "metodoPago": metodoPago,
    "montoTotal": montoTotal,
  };
}

class Item {
  // Propiedades
  Map<String, String>? atributos;
  int cantidad;
  String image;
  num precio;
  String titulo;

  // Constructor
  Item({
    this.atributos,
    this.cantidad = 0,
    this.image    = '',
    this.precio   = 0.0,
    this.titulo   = '',
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    atributos: json["atributos"] != null ? Map<String, String>.from(json["atributos"]) : null,
    cantidad: json["cantidad"],
    image   : json["image"],
    precio  : json["precio"],
    titulo  : json["titulo"],
  );

  Map<String, dynamic> toJson() => {
    "atributos": atributos,
    "cantidad" : cantidad,
    "image"    : image,
    "precio"   : precio,
    "titulo"   : titulo,
  };
}
