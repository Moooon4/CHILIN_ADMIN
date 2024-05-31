// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, avoid_function_literals_in_foreach_calls

import 'package:chilin_administrador/src/models/pedido_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PedidosPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Text('Pedidos pendientes',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15))
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () async{
              await Navigator.pushNamed(context, 'finalizado');
            },
            child: 
            Text(
              'Pedidos finalizados',
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w600, 
                fontSize: 14, 
              ),
            ),
          ),

          SizedBox(width: 10)
        ],
      ),

      body: _crearListado(),
    );
  }

  Widget _crearListado() {
    return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('Usuarios').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          final usuarios = snapshot.data!.docs;

          return FutureBuilder<List<PedidoModel>>(
            future: _obtenerPedidosDeUsuarios(usuarios),
            builder: (BuildContext context, AsyncSnapshot<List<PedidoModel>> pedidosSnapshot) {
              if (pedidosSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (pedidosSnapshot.hasError) {
                return Center(child: Text('Error: ${pedidosSnapshot.error}'));
              }
              if (pedidosSnapshot.hasData && pedidosSnapshot.data!.isNotEmpty) {
                final pedidos = pedidosSnapshot.data!;
                return ListView.builder(
                  itemCount: pedidos.length,
                  itemBuilder: (context, i) => _crearItem(context, pedidos[i]),
                );
              } else {
                return Center(child: Text('No hay pedidos disponibles.'));
              }
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // Obtenemos los pedidos de los usuarios
  Future<List<PedidoModel>> _obtenerPedidosDeUsuarios(List<DocumentSnapshot> usuarios) async {
    List<PedidoModel> pedidos = [];

    for (var usuarioDoc in usuarios) {
      final ordenesSnapshot = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(usuarioDoc.id)
        .collection('Ordenes')
        .get();

      if (ordenesSnapshot.docs.isNotEmpty) {
        for (var orden in ordenesSnapshot.docs) {
          if (orden['estado'] == 'OrderStatus.pending') {
            final pedido = PedidoModel(
              idCliente : usuarioDoc.id,
              nombre    : usuarioDoc['nombre'],
              apellido  : usuarioDoc['apellido'],
              fotoPerfil: usuarioDoc['fotoPerfil'],
              telefono  : usuarioDoc['numeroTelefono'],
              email     : usuarioDoc['email'],
              username  : usuarioDoc['username'],
              
              idOrden   : orden.id,
              fechaOrden: orden['fechaOrden'],
              metodoPago: orden['metodoPago'],
              montoTotal: orden['montoTotal'],
              estado    : orden['estado'],
            );
            pedidos.add(pedido);
          }
        }
      }
    }

    return pedidos;
  }

  // Creamos el listado de los datos
  Widget _crearItem(context, PedidoModel pedido) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.only(left: 30, bottom: 20, right: 30),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, 'pedido', arguments: pedido);
        },
        title: Container(
          padding: EdgeInsets.all(0),
          height: 100, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  pedido.fotoPerfil.isEmpty
                    ? Icon(Icons.account_circle_sharp, size: 30)
                    : CircleAvatar(
                        radius: 15,
                        backgroundImage: NetworkImage(pedido.fotoPerfil),
                      ),
                  SizedBox(width: 5),
                  Text(
                    '${pedido.nombre.toUpperCase()} ${pedido.apellido.toUpperCase()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Metodo de pago: ${pedido.metodoPago}'),
                        Row(
                          children: [
                            Text('Estado del pedido: Pendiente '),
                            Icon(Icons.circle_rounded, size: 25.0, color: Color(0xFF388E3C)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${pedido.montoTotal.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}