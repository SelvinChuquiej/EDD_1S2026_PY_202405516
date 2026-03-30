package gui::user_panelPerfil;

use strict;
use warnings;
use Gtk3;

sub mostrar {
    my ($usuario_logueado, $mi_avl, $mi_bst, $lista_meds, $arbol_b, $lista_prov, $mi_matriz) = @_;

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("Mi Perfil - Personal Medico");
    $ventana->set_default_size(450, 400);
    $ventana->set_position('center');

    my $vbox = Gtk3::Box->new('vertical', 20);
    $vbox->set_border_width(30);
    $ventana->add($vbox);

    my $caja_superior = Gtk3::Box->new('horizontal', 10);
    $vbox->pack_start($caja_superior, 0, 0, 0);

    my $btn_volver = Gtk3::Button->new_with_label("Volver al Menu Principal");
    $caja_superior->pack_start($btn_volver, 0, 0, 0);
    $btn_volver->signal_connect(clicked => sub {
        $ventana->hide();
        require gui::user_panel;
        gui::user_panel::mostrar($usuario_logueado, $mi_avl, $mi_bst, $lista_meds, $arbol_b, $lista_prov, $mi_matriz);
    });

    my $lbl_titulo = Gtk3::Label->new();
    $lbl_titulo->set_markup("<span size='x-large' weight='bold'>Mi Perfil de Usuario</span>");
    $vbox->pack_start($lbl_titulo, 0, 0, 0);

    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(15);
    $grid->set_column_spacing(15);
    $grid->set_halign('center');
    $vbox->pack_start($grid, 0, 0, 0);

    my $colegio = $usuario_logueado->{numero_colegio} || "N/A";
    my $tipo    = $usuario_logueado->{tipo_usuario} || "N/A";
    my $depto   = $usuario_logueado->{departamento} || "N/A";
    my $especi  = $usuario_logueado->{especialidad} || "N/A";

    my $lbl_col = Gtk3::Label->new(); $lbl_col->set_markup("<b>$colegio</b>");
    my $lbl_tip = Gtk3::Label->new(); $lbl_tip->set_markup("<b>$tipo</b>");
    my $lbl_dep = Gtk3::Label->new(); $lbl_dep->set_markup("<b>$depto</b>");
    my $lbl_esp = Gtk3::Label->new(); $lbl_esp->set_markup("<b>$especi</b>");

    $grid->attach(Gtk3::Label->new("Número de Colegio:"), 0, 0, 1, 1);
    $grid->attach($lbl_col, 1, 0, 1, 1);

    $grid->attach(Gtk3::Label->new("Tipo de Usuario:"), 0, 1, 1, 1);
    $grid->attach($lbl_tip, 1, 1, 1, 1);

    $grid->attach(Gtk3::Label->new("Departamento:"), 0, 2, 1, 1);
    $grid->attach($lbl_dep, 1, 2, 1, 1);

    $grid->attach(Gtk3::Label->new("Especialidad:"), 0, 3, 1, 1);
    $grid->attach($lbl_esp, 1, 3, 1, 1);

    $grid->attach(Gtk3::Label->new("Nombre Completo:"), 0, 4, 1, 1);
    my $ent_nombre = Gtk3::Entry->new();
    $ent_nombre->set_text($usuario_logueado->{nombre_completo} || "");
    $grid->attach($ent_nombre, 1, 4, 1, 1);

    $grid->attach(Gtk3::Label->new("Nueva Contrasenia:"), 0, 5, 1, 1);
    my $ent_pass = Gtk3::Entry->new();
    $ent_pass->set_visibility(0);
    $ent_pass->set_placeholder_text("Dejar vacio para no cambiar");
    $grid->attach($ent_pass, 1, 5, 1, 1);

    my $btn_guardar = Gtk3::Button->new_with_label("Guardar Cambios");
    $btn_guardar->set_size_request(200, 40);
    $vbox->pack_start($btn_guardar, 0, 0, 0);

    $btn_guardar->signal_connect(clicked => sub {
        my $nuevo_nombre = $ent_nombre->get_text();
        my $nuevo_pass = $ent_pass->get_text();

        if ($nuevo_nombre eq '') {
            mostrar_mensaje($ventana, "warning", "El nombre no puede estar vacio.");
            return;
        }

        $usuario_logueado->{nombre_completo} = $nuevo_nombre;
        if ($nuevo_pass ne '') {
            $usuario_logueado->{contrasena} = $nuevo_pass;
        }

        mostrar_mensaje($ventana, "info", "Perfil actualizado correctamente en el sistema.");
        $ventana->hide();
        require gui::user_panel;
        gui::user_panel::mostrar($usuario_logueado, $mi_avl, $mi_bst, $lista_meds, $arbol_b, $lista_prov, $mi_matriz);
    });

    $ventana->show_all();
}

sub mostrar_mensaje {
    my ($parent, $tipo, $texto) = @_;
    my $dialogo = Gtk3::MessageDialog->new($parent, 'destroy-with-parent', $tipo, 'ok', $texto);
    $dialogo->run();
    $dialogo->destroy();
}

1;