EDD MedTrack – Manual Técnico
Universidad de San Carlos de Guatemala
Estructuras de Datos – 1S2026

Descripción General del Sistema
EDD MedTrack es un sistema de gestión de inventario hospitalario desarrollado en Perl que implementa manualmente estructuras de datos lineales:
- Lista Doblemente Enlazada
- Lista Circular Simple
- Lista Enlazada Simple
- Lista Circular Doblemente Enlazada
- Matriz Dispersa
El sistema permite gestionar medicamentos, proveedores, solicitudes y comparación de precios, además de generar reportes gráficos mediante Graphviz.


1) Lista Doblemente Enlazada – Inventario
- inventario/InventarioDLinkedList.pm
- inventario/NodoInventario.pm

Propósito: Almacena medicamentos ordenados por código para permitir búsquedas y recorridos eficientes.
Decisiones de Diseño:
- Se utiliza lista doble para permitir eliminación en O(1) cuando se tiene referencia.
- Se mantienen punteros head y tail.
- Se evita ordenamiento posterior insertando en posición correcta.

2) Lista Circular de Listas – Proveedores
- proveedores/ProveedorCircularLinkedList.pm
- proveedores/NodoProveedor.pm

Propósito: Gestiona proveedores y su historial de entregas, cada proveedor contiene una lista enlazada simple de entregas.
Decisiones de Diseño:
- Lista circular para permitir recorrido continuo.
- Cada proveedor encapsula su propia lista de entregas.


3) Lista Circular Doblemente Enlazada – Solicitudes
- solicitudes/SolicitudCircularDLinkedList.pm
- solicitudes/NodoSolicitud.pm
- solicitudes/HistorialLinkedList.pm

Propósito: Gestiona solicitudes pendientes de reabastecimiento.
Decisiones de Diseño:
- Circularidad para flujo continuo.
- Doble enlace para eliminación en O(1).
- Se mantiene contador size.

4) Lista Enlazada Simple – Entregas
- entregas/EntregaLinkedList.pm
- entregas/NodoEntrega.pm

Propósito: Almacena historial de entregas por proveedor.
Decisiones de Diseño:
- No se usa tail para mantener simplicidad.
- Solo se requiere recorrido secuencial.

5) Matriz Dispersa – Comparación de Precios
- matriz/MatrizDispersa.pm
- matriz/NodoCabecera.pm
- matriz/NodoValor.pm

Propósito: Relaciona laboratorios y medicamentos permitiendo comparar precios.
Decisiones de Diseño
- No se utiliza arreglo bidimensional.
- Solo se almacenan combinaciones existentes.
- NodoValor tiene 4 punteros (right, left, up, down).
- Cabeceras ordenadas alfabéticamente.