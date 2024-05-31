// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, use_key_in_widget_constructors, avoid_unnecessary_containers

import 'package:chilin_administrador/src/models/producto_model.dart';
import 'package:chilin_administrador/src/providers/productos_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:chilin_administrador/src/bloc/provider.dart';

class HomePage extends StatelessWidget {

  // El provider donde se maneja la informacion a base de datos
  final productosProvider = ProductosProvider();

  @override
  Widget build(BuildContext context) {
    // La clase creada anteriormente
    // Tenemos acceso a todos los metodos y propiedades que estan definidos en el bloc
    // final bloc = Provider.of( context );

    return Scaffold(
      appBar:AppBar(
        title: Row(
          children: [
            Image.asset('assets/chilin.png', scale: 4,),
            const SizedBox(
              width: 10.0,
            ),
            const Text(
              '| ',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Color(0xFF272727)),
            ),
            const Text(
              'Hola, Fernando',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Color(0xFF272727))/*
              shadows: [Shadow(color: Colors.grey, offset: Offset(2, 2), blurRadius: 1,)]),*/
            )
          ],
        ),
      ),

      // Text('Email: ${ bloc?.email } '),
      // Divider(),
      // Text('Password: ${ bloc?.password }')
  
      body: _crearListado(),

      // Boto para crear un nuevo producto
      floatingActionButton: _crearBoton( context ),
    );
  }

  // Listamos la informacion desde base de datos
  Widget _crearListado() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Productos').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // Validación por si tiene los datos cargados o no
        if (snapshot.hasData) {
          final productos = snapshot.data!.docs.map((doc) => ProductoModel(
            id             : doc.id,
            descripcion    : doc['descripcion'],
            estado         : doc['estado'],
            idCategoria    : doc['idCategoria'],
            imagen         : doc['imagen'],
            isFeatured     : doc['isFeatured'],
            nombre         : doc['nombre'],
            nombreCategoria: doc['nombreCategoria'],
            precio         : doc['precio'],
            tipoProducto   : doc['tipoProducto'],
          )).toList();

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, i) => _crearItem(context, productos[i]),
          );
        } else if (snapshot.hasError) {
          // Retornar un widget de error si ocurre un error en el stream
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // Retornamos un indicador de carga mientras se obtienen los datos
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // Creamos los items individuales 
  Widget _crearItem( context, ProductoModel producto ) {
    // el Dismissible lo agregamos para eliminar algun producto
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Color(0xFFD32F2F),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Icon(Icons.delete, color: Color(0xFFFFFFFF), size: 25), // Icono a la izquierda
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(Icons.delete, color: Color(0xFFFFFFFF), size: 25), // Icono a la derecha
            ),
          ],
        ),
      ),
      onDismissed: (direction) {

        // Aqui vamos a borrar el items
        productosProvider.borrarProducto( producto.id );
      },

      child: Card(
        elevation: 4.0,
        margin: EdgeInsets.only(left: 30, bottom: 20, right: 30),
        child: ListTile(
          onTap: () {
            Navigator.pushNamed(context, 'producto', arguments: producto);
          },
          title: Container(
            child: Padding(
              padding: EdgeInsets.all(0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded (
                    flex: 1, // La imagen ocupa el 50% del ancho
                    child: FadeInImage(
                      fadeInDuration: Duration( milliseconds: 200 ),
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: AssetImage('assets/preloader.gif'),
                      image: NetworkImage(producto.imagen),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    flex: 1, // El texto ocupa el 50% del ancho
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titulo
                        Center(
                          child: Text(
                            producto.nombre,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF272727),
                            ),
                          ),
                        ),
            
                        // Vamos dejando un espacio
                        SizedBox(height: 5),
            
                        // Categoria y Precio
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Widget para la categoría con un icono y texto
                            Row(
                              children: [
                                Icon(Icons.restaurant_menu_rounded, size: 18.0, color: Color(0xFFF57C00)), 
                                SizedBox(width: 3),
                                Text(
                                  producto.nombreCategoria,
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF57C00)
                                  ),
                                ),
                              ],
                            ),
                            // Widget para el precio
                            Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '\$${producto.precio.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4F4F4F),
                                ),
                              ),
                            ),
                          ],
                        ),
            
                        // Descripcion
                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(bottom: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0), // Redondea los bordes del Container
                            color: Color(0xFFF6F6F6), // Color de fondo del Container
                          ),
                          padding: EdgeInsets.all(5.0),
                          constraints: BoxConstraints(minHeight: 110),
                          child: 
                          Text(
                            producto.descripcion,
                            style: TextStyle(
                              fontSize: 12.0
                            ),
                          ),
                        ),
            
                        // Disponible y Destacado
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Disponible:',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF4F4F4F),
                                  ),
                                ),
                                SizedBox(width: 3),
            
                                if (producto.estado == 'Disponible') 
                                Container(
                                  child: Icon( Icons.circle_rounded, size: 18.0, color: Color(0xFF388E3C)),
                                )
                                else
                                Container(
                                  child: Icon( Icons.circle_outlined, size: 18.0, color: Color(0xFFD32F2F)),
                                ),
                              ],
                            ),
                            // Widget para el destacado
                            Row(
                              children: [
                                Text(
                                  'Destacado:',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF4F4F4F),
                                  ),
                                ),
                                SizedBox(width: 3),
            
                                if (producto.isFeatured == true) 
                                Container(
                                  child: Icon( Icons.star, size: 18.0, color: Color(0xFF388E3C)),
                                )
                                else
                                Container(
                                  child: Icon( Icons.star_border, size: 18.0, color: Color(0xFFD32F2F)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearBoton( context ) {
    return Container(
      margin: EdgeInsets.only(left: 30),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, 'pedidos'),
              child: Icon(Icons.assignment_returned_outlined),
              // Cambiamos el color a la aplicacion
              backgroundColor: Color(0xffff9e37),
              foregroundColor: Color(0xFFFFFFFF),
              heroTag: "Pedidos",
            ),
            FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, 'producto'),
              child: Icon(Icons.add),
              // Cambiamos el color a la aplicacion
              backgroundColor: Color(0xFF272727),
              foregroundColor: Color(0xFFFFFFFF),
              heroTag: "Agregar",
            ),
          ]
      ),
    );
  }
}