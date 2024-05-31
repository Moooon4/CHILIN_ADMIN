// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations

import 'package:chilin_administrador/src/models/pedido_detalle_model.dart';
import 'package:chilin_administrador/src/models/pedido_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PedidoPage extends StatefulWidget {
  @override
  State<PedidoPage> createState() => _PedidoPageState();
}

class _PedidoPageState extends State<PedidoPage> {
  @override
  Widget build(BuildContext context) {
    // De esta manera estoy tomando el argumento si viene
    final PedidoModel? pedidoData = ModalRoute.of(context)?.settings.arguments as PedidoModel?;

    return Scaffold(
      appBar: AppBar(
        // Agregando nombre a la pantalla Detalle Factura
        title: Row(
          children: [
            const Text(
              ' ',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
          ],
        ),
      ),

      // Agregando al body
      body: Column(
        children: [
          // Agregando el logo Chilín
          SizedBox(
            width: double.infinity,
            height: 40,
            child: Image.asset(
              'assets/chilin.png',
              fit: BoxFit.contain,
            ),
          ),

          // Encabezado del pedido
          Container(
            height: 150,
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: pedidoData!.fotoPerfil.isNotEmpty 
                    ? ClipOval(
                        child: Container(
                          color: Colors.grey[200], 
                          child: Image.network(
                            pedidoData.fotoPerfil,
                            fit: BoxFit.contain, 
                          ),
                        )
                      )
                    : Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200], 
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                ),
                SizedBox(width: 15),
                Expanded(
                  flex: 3,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${pedidoData.nombre.toUpperCase()} ${pedidoData.apellido.toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                        Container(
                          margin: EdgeInsets.only(top: 3.0), 
                          child: Row(
                            children: [
                              Icon(Icons.phone, color: Colors.green),
                              SizedBox(width: 8.0),
                              Text(pedidoData.telefono, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.green)),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 3.0), 
                          child: Row(
                            children: [
                              Icon(Icons.email_outlined),
                              SizedBox(width: 8.0),
                              Text(pedidoData.email, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 3.0), 
                          child: Row(
                            children: [
                              Icon(Icons.person),
                              SizedBox(width: 8.0),
                              Text(pedidoData.username, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ),

          // Espacio para el cuerpo de la factura
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('Usuarios').doc(pedidoData.idCliente).collection('Ordenes').doc(pedidoData.idOrden).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  var doc = snapshot.data!;
                  
                  // Parseando la fecha correctamente
                  final fechaOrdenTimestamp = doc['fechaOrden'] as Timestamp;
                  final fechaOrden          = fechaOrdenTimestamp.toDate();
                  
                  // Mapeando los items del pedido
                  final itemsList = (doc['items'] as List<dynamic>).map((item) {
                    return Item(
                      atributos: item['atributos'] != null ? Map<String, String>.from(item['atributos']) : null,
                      cantidad: item['cantidad'],
                      image   : item['image'],
                      precio  : item['precio'],
                      titulo  : item['titulo'],
                    );
                  }).toList();

                  final pedido = PedidoDetalleModel(
                    estado    : doc['estado'],
                    fechaOrden: fechaOrden,
                    id        : doc.id,
                    items     : itemsList,
                    metodoPago: doc['metodoPago'],
                    montoTotal: doc['montoTotal'],
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Fecha de orden: '),
                          Text('${pedido.fechaOrden}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),   
                        ],
                      ),
                      SizedBox(height: 5),

                      // ListView.builder para mostrar la lista de artículos
                      Expanded(
                        child: SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: 600,
                            ),
                            child: ListView.builder(
                              itemCount: pedido.items.length,
                              itemBuilder: (context, index) {
                                final item = pedido.items[index];
                                return Card(
                                  child: ListTile(
                                    leading: Image.network(item.image, width: 60, height: 100, fit: BoxFit.cover),
                                    title: Text(item.titulo),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Cantidad: ${item.cantidad}'),
                                        if (item.atributos != null)
                                          Text('${item.atributos!.entries.map((e) => '${e.key}: ${e.value}').join(', ')}'),
                                        Row(
                                          children: [
                                            Text('Precio: \$${item.precio.toStringAsFixed(2)}'),
                                            Spacer(),
                                            Text('Total: \$${(double.parse(item.precio.toStringAsFixed(2)) * item.cantidad).toStringAsFixed(2)}'),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 40,right: 10, left: 10),
                        child: Row(
                          children: [
                            Text('Método de Pago: ${pedido.metodoPago}'),
                            Spacer(),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 17
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Monto Total: ',
                                  ),
                                  TextSpan(
                                    text: '\$${pedido.montoTotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      // Botón finalizar pedido
                      if (pedido.estado == 'OrderStatus.pending') // Condición para mostrar el botón
                        Container(
                          margin: EdgeInsets.only(bottom: 20, top: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Agrega aquí la lógica para finalizar el pedido
                                // ignore: unnecessary_null_comparison
                                if (pedidoData != null) {
                                  await FirebaseFirestore.instance
                                    .collection('Usuarios')
                                    .doc(pedidoData.idCliente)
                                    .collection('Ordenes')
                                    .doc(pedidoData.idOrden)
                                    .update({'estado': 'OrderStatus.finished'});

                                  // Volver a la pantalla de pedidos pendientes
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                textStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              child: Text('FINALIZAR PEDIDO'),
                            ),
                          ),
                        ),

                    ],
                  );

                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}