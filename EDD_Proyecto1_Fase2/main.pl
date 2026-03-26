use strict;
use warnings;
use lib '.';

use Gtk3 '-init';
use estructuras::ArbolAVLUsuario;
use gui::login;

my $avl_usuarios = estructuras::ArbolAVLUsuario->new();
gui::login::mostrar($avl_usuarios);
Gtk3->main();