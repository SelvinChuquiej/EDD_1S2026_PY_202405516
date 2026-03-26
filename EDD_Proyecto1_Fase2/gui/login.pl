use strict;
use warnings;
use lib '..'; # Para encontrar tus módulos locales

# Importar el módulo de GTK3
use Gtk3 '-init';

# Importar tus estructuras
use estructuras::ArbolAVLUsuario;
use json::CargaUsuario;

my $mi_avl = estructuras::ArbolAVLUsuario->new();
json::CargaUsuario::cargar_desde_archivo("../usuarios.json", $mi_avl);

my $ventana = Gtk3::Window->new('toplevel');
$ventana->set_title("EDD MedTrack - Iniciar Sesion");
$ventana->set_default_size(400, 350);
$ventana->set_position('center');
$ventana->signal_connect(destroy => sub { Gtk3->main_quit() });

# Contenedor principal (Caja vertical)
my $caja_principal = Gtk3::Box->new('vertical', 10);
$caja_principal->set_border_width(30);
$ventana->add($caja_principal);

# Título
my $lbl_titulo = Gtk3::Label->new();
$lbl_titulo->set_markup("<span size='x-large' weight='bold'>LOGIN</span>");
$caja_principal->pack_start($lbl_titulo, 0, 0, 15);

# Campo: Usuario (Número de Colegio)
my $lbl_usuario = Gtk3::Label->new("USUARIO");
$lbl_usuario->set_halign('start');
$caja_principal->pack_start($lbl_usuario, 0, 0, 0);

my $entry_usuario = Gtk3::Entry->new();
$caja_principal->pack_start($entry_usuario, 0, 0, 5);

# Campo: Contraseña
my $lbl_pass = Gtk3::Label->new("CONTRASENA");
$lbl_pass->set_halign('start');
$caja_principal->pack_start($lbl_pass, 0, 0, 0);

my $entry_pass = Gtk3::Entry->new();
$entry_pass->set_visibility(0); # Oculta los caracteres (como asteriscos)
$caja_principal->pack_start($entry_pass, 0, 0, 5);

# Botón de Login
my $btn_login = Gtk3::Button->new_with_label("Iniciar Sesion");
$caja_principal->pack_start($btn_login, 0, 0, 20);

$btn_login->signal_connect(clicked => sub {
    my $usuario_ingresado = $entry_usuario->get_text();
    my $pass_ingresada    = $entry_pass->get_text();
    
    # Validar Administrador General (Credenciales especiales)
    if ($usuario_ingresado eq 'AdminHospital' && $pass_ingresada eq 'MedTrack2025') {
        mostrar_mensaje($ventana, "info", "¡Bienvenido Administrador General!");
        # Aquí luego llamaremos a la ventana de admin_panel.pl
        return;
    }
    
    # Validar Personal Médico en el Árbol AVL
    my $nodo_usuario = $mi_avl->buscar($usuario_ingresado);
    
    if (defined $nodo_usuario && $nodo_usuario->{contrasena} eq $pass_ingresada) {
        my $mensaje = "¡Bienvenido " . $nodo_usuario->{tipo_usuario} . " " . $nodo_usuario->{nombre_completo} . "!";
        mostrar_mensaje($ventana, "info", $mensaje);
        # Aquí luego llamaremos a la ventana de user_panel.pl
    } else {
        mostrar_mensaje($ventana, "error", "Credenciales incorrectas. Verifique sus datos.");
    }
});

sub mostrar_mensaje {
    my ($parent, $tipo, $texto) = @_;
    my $tipo_dialogo = ($tipo eq "error") ? 'error' : 'info';
    
    my $dialogo = Gtk3::MessageDialog->new(
        $parent, 'destroy-with-parent',
        $tipo_dialogo, 'ok',
        $texto
    );
    $dialogo->run();
    $dialogo->destroy();
}

$ventana->show_all();
Gtk3->main();