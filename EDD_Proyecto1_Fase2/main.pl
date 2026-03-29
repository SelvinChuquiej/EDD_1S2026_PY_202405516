use strict;
use warnings;
use lib '.';

use Gtk3 '-init';
use estructuras::ArbolAVLUsuario;
use estructuras::ArbolBSTEquipos;
use gui::login;

my $avl_usuarios = estructuras::ArbolAVLUsuario->new();
my $bst_equipos = estructuras::ArbolBSTEquipos->new();

gui::login::mostrar($avl_usuarios, $bst_equipos);
Gtk3->main();