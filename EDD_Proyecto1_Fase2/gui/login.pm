package gui::login;

use strict;
use warnings;
use Gtk3;
use gui::admin_panel; 

sub mostrar {
    my ($mi_avl, $mi_bst, $mi_lista_meds, $mi_arbol_b, $mi_lista_prov, $mi_matriz) = @_; 

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("EDD MedTrack - Iniciar Sesion");
    $ventana->set_default_size(400, 380);
    $ventana->set_position('center');
    
    $ventana->signal_connect(destroy => sub { Gtk3->main_quit() });

    my $caja_principal = Gtk3::Box->new('vertical', 10);
    $caja_principal->set_border_width(30);
    $ventana->add($caja_principal);

    my $lbl_titulo = Gtk3::Label->new();
    $lbl_titulo->set_markup("<span size='x-large' weight='bold'>LOGIN</span>");
    $caja_principal->pack_start($lbl_titulo, 0, 0, 15);

    my $entry_usuario = Gtk3::Entry->new();
    $caja_principal->pack_start(Gtk3::Label->new("USUARIO"), 0, 0, 0);
    $caja_principal->pack_start($entry_usuario, 0, 0, 5);

    my $entry_pass = Gtk3::Entry->new();
    $entry_pass->set_visibility(0);
    $caja_principal->pack_start(Gtk3::Label->new("CONTRASENA"), 0, 0, 0);
    $caja_principal->pack_start($entry_pass, 0, 0, 5);

    my $btn_login = Gtk3::Button->new_with_label("Iniciar Sesion");
    $caja_principal->pack_start($btn_login, 0, 0, 15);

    my $btn_info = Gtk3::Button->new_with_label("Informacion del Estudiante");
    $caja_principal->pack_start($btn_info, 0, 0, 5);

    $btn_login->signal_connect(clicked => sub {
        my $u = $entry_usuario->get_text();
        my $p = $entry_pass->get_text();

        if ($u eq 'AdminHospital' && $p eq 'MedTrack2025') {
            $ventana->hide();
            require gui::admin_panel;
            gui::admin_panel::mostrar($mi_avl, $mi_bst, $mi_lista_meds, $mi_arbol_b, $mi_lista_prov, $mi_matriz);
        } else {
            my $nodo = $mi_avl->buscar($u);
            if (defined $nodo && $nodo->{contrasena} eq $p) {
                $ventana->hide();
                require gui::user_panel;
                gui::user_panel::mostrar($nodo, $mi_avl, $mi_bst, $mi_lista_meds, $mi_arbol_b, $mi_lista_prov, $mi_matriz);
            } else {
                mostrar_mensaje($ventana, "error", "Datos incorrectos");
            }
        }
    });

    $btn_info->signal_connect(clicked => sub {
        my $info_texto = "<span size='large' weight='bold'>Datos del Desarrollador</span>\n\n" .
                         "<b>Nombre:</b> Selvin Raúl Chuquiej Andrade\n" .
                         "<b>Carnet:</b> 202405516\n" .
                         "<b>Curso:</b> Estructura de Datos Seccion A";
                         
        my $dialogo = Gtk3::MessageDialog->new($ventana, 'destroy-with-parent', 'info', 'ok', "");
        $dialogo->set_markup($info_texto);
        $dialogo->run();
        $dialogo->destroy();
    });

    $ventana->show_all();
}

sub mostrar_mensaje {
    my ($p, $tipo, $msg) = @_;
    my $d = Gtk3::MessageDialog->new($p, 'destroy-with-parent', $tipo, 'ok', $msg);
    $d->run(); $d->destroy();
}

1;