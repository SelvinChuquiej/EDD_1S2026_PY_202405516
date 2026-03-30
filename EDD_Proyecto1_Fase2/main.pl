use strict;
use warnings;
use lib '.';

use Gtk3 '-init';

use estructuras::ArbolAVLUsuario;
use estructuras::ArbolBSTEquipos;
use estructuras::ListaDobleMedicamentos;
use estructuras::ArbolBInventario;
use estructuras::ListaCircularProveedores;
use estructuras::MatrizDispersaLabMed;

use gui::login;
use gui::admin_panel;

my $avl_usuarios = estructuras::ArbolAVLUsuario->new();
my $bst_equipos = estructuras::ArbolBSTEquipos->new();
my $lista_meds = estructuras::ListaDobleMedicamentos->new();
my $arbol_b = estructuras::ArbolBInventario->new();
my $lista_prov = estructuras::ListaCircularProveedores->new();
my $mi_matriz = estructuras::MatrizDispersaLabMed->new();

gui::admin_panel::mostrar($avl_usuarios, $bst_equipos, $lista_meds, $arbol_b, $lista_prov, $mi_matriz); 
#gui::login::mostrar($avl_usuarios, $bst_equipos, $lista_meds, $arbol_b, $lista_prov);
Gtk3->main();