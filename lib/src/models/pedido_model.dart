import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

PedidoModel pedidoModelFromJson(String str) => PedidoModel.fromJson(json.decode(str));

String pedidoModelToJson(PedidoModel data) => json.encode(data.toJson());

class PedidoModel {
  String idCliente;
  String nombre;
  String apellido;
  String fotoPerfil;
  String telefono;
  String email;
  String username;

  String idOrden;
  Timestamp? fechaOrden;
  List<Map<String, dynamic>> detalleOrden;
  String metodoPago;
  num montoTotal;
  String estado;

  PedidoModel({
    this.idCliente    = '',
    this.nombre       = '',
    this.apellido     = '',
    this.fotoPerfil   = '',
    this.telefono     = '',
    this.email        = '',
    this.username     = '',
    this.idOrden      = '',
    this.fechaOrden,
    this.detalleOrden = const [],
    this.metodoPago   = '',
    this.montoTotal   = 0,
    this.estado       = '',
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) => PedidoModel(
    idCliente   : json["idCliente"],
    nombre      : json["nombre"],
    apellido    : json["apellido"],
    fotoPerfil  : json["fotoPerfil"],
    telefono    : json["telefono"],
    email       : json["email"],
    username    : json["username"],

    idOrden     : json["idOrden"],
    fechaOrden  : json["fechaOrden"],
    detalleOrden: json["detalleOrden"] != null 
                    ? List<Map<String, dynamic>>.from(json["detalleOrden"].map((x) => x)) 
                    : [],
    metodoPago  : json["metodoPago"],
    montoTotal  : json["montoTotal"].toDouble(),
    estado      : json["estado"],
  );

  Map<String, dynamic> toJson() => {
    "idCliente"   : idCliente,
    "nombre"      : nombre,
    "apellido"    : apellido,
    "fotoPerfil"  : fotoPerfil,
    "telefono"    : telefono,
    "email"       : email,
    "username"    : username,
    
    "idOrden"     : idOrden,
    "fechaOrden"  : fechaOrden,
    "detalleOrden": List<dynamic>.from(detalleOrden.map((x) => x)),
    "metodoPago"  : metodoPago,
    "montoTotal"  : montoTotal,
    "estado"      : estado,
  };
}
