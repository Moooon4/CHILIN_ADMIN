// ignore_for_file: prefer_const_constructors, unused_local_variable, unnecessary_null_comparison, use_key_in_widget_constructors, avoid_print, unused_field, avoid_init_to_null, avoid_unnecessary_containers, sized_box_for_whitespace, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'dart:io';

import 'package:chilin_administrador/src/models/producto_model.dart';
import 'package:chilin_administrador/src/providers/productos_provider.dart';
import 'package:chilin_administrador/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductoPage extends StatefulWidget {
  @override
  State<ProductoPage> createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  // id para el formulario
  final formKey = GlobalKey<FormState>();
  // id para el scaffold
  final scaffoldkey = GlobalKey<ScaffoldState>();

  // Propiedad para el modelo
  ProductoModel producto = ProductoModel();
  final productosProvider = ProductosProvider();

  // Para verificar que no le demos dos veces al boton de guardar
  bool _guardando = false;

  // Propiedad para almecenar la fotografia
  File? foto = null;

  @override
  Widget build(BuildContext context) {
    // De esta manera estoy tomando el argumento si viene
    final ProductoModel? prodData =
        ModalRoute.of(context)?.settings.arguments as ProductoModel?;

    if (prodData != null) {
      producto = prodData;
    }

    return Scaffold(
      key: scaffoldkey,
      appBar: AppBar(
        title: Row(
          children: const [
            Text('Productos',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20))
          ],
        ),

        // Vamos a crear las apciones para tomar foto o tomarla de la galeria
        // Si el producto tiene foto, no vamos a permitir modificar
        actions: producto.id == ''
            ? [
                IconButton(
                  icon: Icon(Icons.photo_library_rounded, color: Colors.black),
                  onPressed: _seleccionarFoto,
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_a_photo_rounded,
                    color: Colors.black,
                  ),
                  onPressed: _tomarFoto,
                )
              ]
            : null,
      ),

      // Body
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Container(
            // Aquí va el resto de tu código
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _mostrarFoto(),
                  _crearNombre(),
                  SizedBox(height: 20),
                  _crearDescripcion(),
                  Row(
                    children: [
                      // 30% de la pantalla
                      Expanded(flex: 3, child: _crearTipoProducto()),
                      // 70% de la pantalla
                      Expanded(flex: 7, child: _crearPrecio()),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      // 50% de la pantalla
                      Expanded(
                          flex: 5,
                          child: Text(
                            'Seleccione Categoría:',
                            textAlign: TextAlign.center,
                          )),
                      // 50% de la pantalla
                      Expanded(flex: 5, child: _seleccionarCategoria()),
                    ],
                  ),
                  SizedBox(height: 20),
                  _crearDisponible(),
                  SizedBox(height: 10),
                  _crearBoton()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearNombre() {
    // El TextFormField trabaja directamente con un formulario
    return TextFormField(
      // inicializamos el valor con la propiedad de la clase
      initialValue: producto.nombre,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: 'Nombre Producto'),
      // El onsave se ejecuta luego del validator
      onSaved: (value) => producto.nombre = value!,
      // Vamos a crear las validaciones
      validator: (value) {
        if (value!.length < 5) {
          return 'Ingrese un nombre de producto valido';
        } else {
          return null;
        }
      },
    );
  }

  Widget _crearDescripcion() {
    // El TextFormField trabaja directamente con un formulario
    return Container(
      // Altura definida
      height: 100,
      // color: Colors.grey[100],
      child: SingleChildScrollView(
        child: TextFormField(
          // inicializamos el valor con la propiedad de la clase
          initialValue: producto.descripcion,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Descripción del Producto',
            border: OutlineInputBorder(
              borderSide: BorderSide.none, // Quita el borde del TextFormField
            ),
          ),
          maxLines: null, // Esto permite que el campo sea multilinea
          // El onsave se ejecuta luego del validator
          onSaved: (value) => producto.descripcion = value!,
          // Vamos a crear las validaciones
          validator: (value) {
            if (value!.length < 5) {
              return 'Ingrese una descripción de producto valida';
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }

  Widget _crearTipoProducto() {
    // El TextFormField trabaja directamente con un formulario
    return Text(
      'Presentación:\nUNIDAD',
      textAlign: TextAlign.start,
    );
  }

  Widget _crearPrecio() {
    // El TextFormField trabaja directamente con un formulario
    return TextFormField(
      initialValue: producto.precio.toStringAsFixed(2),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: 'Precio'),
      // El onsave se ejecuta luego del validator
      onSaved: (value) => producto.precio = double.parse(value!),
      // aqui la validacion es importante porque
      // lleva un numero a fuerza
      validator: (value) {
        // Validamos que sea numero
        // si regres true es un numero
        if (utils.isNumeric(value!)) {
          return null;
        } else {
          return 'Ingresa un precio valido';
        }
      },
    );
  }

  Widget _seleccionarCategoria() {
    Map<int, String> categorias = {
      1: "Tradicionales",
      2: "Especialidades",
      3: "Postres",
      4: "Bebidas",
    };

    // print( producto.idCategoria );

    String? _categoriaSeleccionada;

    return DropdownButton<int>(
      value: producto.idCategoria.isNotEmpty
          ? int.parse(producto.idCategoria)
          : null,
      hint: Text('Seleccionar categoría'),
      onChanged: (int? newValue) {
        setState(() {
          // Asignar el nuevo valor de categoría a producto.idCategoria
          producto.idCategoria = newValue.toString();

          // Asignar el nombre de la categoría a producto.nombreCategoria
          producto.nombreCategoria = categorias[newValue]!;
        });
      },
      items: categorias.keys.map((int key) {
        return DropdownMenuItem<int>(
          value: key,
          child: Text(categorias[key]!),
        );
      }).toList(),
    );
  }

  Widget _crearBoton() {
    // print("Valor de producto.id: ${producto.id}");

    return ElevatedButton.icon(
      onPressed: (_guardando) ? null : _submit,
      style: ElevatedButton.styleFrom(
        foregroundColor: Color(0xFFF57C00),
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        elevation: 0,
      ),
      label: Text(
        (producto.id == '') ? 'Guardar' : 'Actualizar',
      ),
      icon: Icon(Icons.save),
    );
  }

  Widget _crearDisponible() {
    // Aqui vamos a colocar dos swich uno para disponible y otro para destacado
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: SwitchListTile(
            value: producto.estado ==
                "Disponible", // Convertir a true si es "Disponible", false si no lo es
            title: Text('Disponible'),
            activeColor: Color(0xffff9e37),
            onChanged: (value) => setState(() {
              // Actualizar el estado según el valor del Switch
              producto.estado = value ? "Disponible" : "No Disponible";
            }),
          ),
        ),
        Flexible(
          flex: 1,
          child: SwitchListTile(
            value: producto.isFeatured,
            title: Text('Destacado'),
            activeColor: Color(0xffff9e37),
            onChanged: (value) => setState(() {
              producto.isFeatured = value;
            }),
          ),
        ),
      ],
    );
  }

  // Para mostrar el mensaje cuando se guarda
  void mostrarSnackbar(String mensaje) {
    final snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1500),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  // Método para el manejo de imágenes
  _seleccionarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        foto = foto = File(pickedFile.path); // No necesitas convertirlo a File
      });
    }
  }

  // Widget para mostrar la foto seleccionada
  Widget _mostrarFoto() {
    if (foto != null) {
      return Image.file(
        // Usar la ruta directamente del objeto pickedFile
        File(foto!.path),
        height: 300.0,
        fit: BoxFit.cover,
      );
    } else if (producto.imagen != '') {
      return Image.network(
        producto.imagen,
        height: 300.0,
        width: 300.0,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'assets/no-image.png',
        height: 300.0,
        fit: BoxFit.cover,
      );
    }
  }

  _tomarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        foto = foto = File(pickedFile.path); // No necesitas convertirlo a File
      });
    }
  }

  // Metodo para controlar el submit
  void _submit() async {
    // una forma
    // Verificamos que el formulario es valido
    // if ( formKey.currentState!.validate() ) {
    //   // Cuando el formulario es valido
    // }

    // Otra forma
    if (!formKey.currentState!.validate()) return;

    // Todo el codigo de aqui abajo solamente sucedera cuandoe el formulario sea valido
    // disparamos los onsave
    // Esto dispara todos los text form field que esten en el formulario
    formKey.currentState!.save();

    // Guadamos el estado
    setState(() {
      _guardando = true;
    });

    // print( producto.titulo );
    // print( producto.valor );
    // print( producto.fotoUrl );

    // Creamos un producto porque no existe
    if (producto.id == '') {
      print(foto?.path);
      await productosProvider.crearProducto(producto, foto);

      mostrarSnackbar('Registro guardado');
      // editamos el producto porque ya existe
    } else {
      // print("editar");
      productosProvider.editarProducto(producto);

      mostrarSnackbar('Registro actualizado');
    }

    setState(() {
      _guardando = false;
    });

    // volvemos al listado de los productos
    Navigator.pop(context);
  }
}
