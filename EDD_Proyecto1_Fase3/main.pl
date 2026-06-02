use strict;
use warnings;
use lib '.';

use Gtk3 '-init';

use estructuras::ArbolAVLUsuario;
use estructuras::ArbolBSTEquipos;
use estructuras::ListaDobleMedicamentos;
use estructuras::ArbolBInventario;
use estructuras::ListaCircularDobleProveedores;
use estructuras::TablaHash;
use estructuras::Grafo;
use estructuras::ListaAdyacencia;
use estructuras::ListaDobleSolicitud;
use estructuras::ListaEnlazadaHistorial;

use gui::login;
use gui::admin_panel;

my $avl_usuarios = estructuras::ArbolAVLUsuario->new();
my $bst_equipos = estructuras::ArbolBSTEquipos->new();
my $lista_meds = estructuras::ListaDobleMedicamentos->new();
my $arbol_b = estructuras::ArbolBInventario->new();
my $lista_prov = estructuras::ListaCircularDobleProveedores->new();
my $tabla_hash = estructuras::TablaHash->new();
my $grafo = estructuras::Grafo->new();
my $lista_adyacencia = estructuras::ListaAdyacencia->new();
my $lista_solicitudes = estructuras::ListaDobleSolicitud->new();
my $historial = estructuras::ListaEnlazadaHistorial->new();

my $context = {
    avl_usuarios => $avl_usuarios,
    bst_equipos => $bst_equipos,
    lista_meds => $lista_meds,
    arbol_b => $arbol_b,
    lista_prov => $lista_prov,
    tabla_hash => $tabla_hash,
    grafo => $grafo,
    lista_adyacencia => $lista_adyacencia,
    lista_solicitudes => $lista_solicitudes,
    historial => $historial
};

gui::login::mostrar($context);
#gui::admin_panel::mostrar($context);
Gtk3->main();