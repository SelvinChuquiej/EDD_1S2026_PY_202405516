package gui::user_panel;

use strict;
use warnings;
use Gtk3;

sub mostrar {
    my ($usuario_logueado, $mi_avl, $mi_bst, $lista_meds, $arbol_b, $lista_prov, $mi_matriz) = @_;

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("Panel de Personal Medico");
    $ventana->set_default_size(700, 400);
    $ventana->set_position('center');

    my $vbox = Gtk3::Box->new('vertical', 20);
    $vbox->set_border_width(30);
    $ventana->add($vbox);

    my $hbox_header = Gtk3::Box->new('horizontal', 10);
    $vbox->pack_start($hbox_header, 0, 0, 0);

    my $nombre_doctor = $usuario_logueado->{nombre_completo} || "Usuario";
    my $especialidad  = $usuario_logueado->{especialidad} || "General";

    my $departamento  = $usuario_logueado->{departamento} || "";

    my $lbl_bienvenida = Gtk3::Label->new();
    $lbl_bienvenida->set_markup("<span size='x-large' weight='bold'>Bienvenido(a), $nombre_doctor</span>\n<span size='medium' color='gray'>Depto: $departamento</span>");
    $lbl_bienvenida->set_halign('start');
    $hbox_header->pack_start($lbl_bienvenida, 1, 1, 0);

    my $btn_cerrar_sesion = Gtk3::Button->new_with_label("Cerrar Sesion");
    $hbox_header->pack_end($btn_cerrar_sesion, 0, 0, 0);

    $btn_cerrar_sesion->signal_connect(clicked => sub {
        $ventana->hide();
        require gui::login;
        gui::login::mostrar($mi_avl, $mi_bst, $lista_meds, $arbol_b, $lista_prov, $mi_matriz);
    });

    my $caja_botones = Gtk3::Box->new('vertical', 15);
    $vbox->pack_start($caja_botones, 1, 1, 0);

    my $lbl_permisos = Gtk3::Label->new();
    $lbl_permisos->set_markup("<span weight='bold'>Acciones Permitidas para tu Departamento:</span>");
    $caja_botones->pack_start($lbl_permisos, 0, 0, 0);

    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(15);
    $grid->set_column_spacing(15);
    $grid->set_halign('center');
    $caja_botones->pack_start($grid, 0, 0, 0);

    my $btn_meds= Gtk3::Button->new_with_label("Consultar / Recetar Medicamentos");
    my $btn_sumi = Gtk3::Button->new_with_label("Consultar / Utilizar Suministros");
    my $btn_equip = Gtk3::Button->new_with_label("Consultar / Asignar Equipo");

    $btn_meds->set_size_request(250, 50);
    $btn_sumi->set_size_request(250, 50);
    $btn_equip->set_size_request(250, 50);

    my $fila = 0;

    # 1. Medicina General (DEP-MED) -> MEDICAMENTOS + SUMINISTROS
    if ($departamento eq 'DEP-MED' || $departamento =~ /Medicina/i) {
        $grid->attach($btn_meds, 0, $fila++, 1, 1);
        $grid->attach($btn_sumi, 0, $fila++, 1, 1);
    }
    # 2. Cirugía (DEP-CIR) -> EQUIPO + SUMINISTROS
    elsif ($departamento eq 'DEP-CIR' || $departamento =~ /Cirugía/i) {
        $grid->attach($btn_equip, 0, $fila++, 1, 1);
        $grid->attach($btn_sumi, 0, $fila++, 1, 1);
    }
    # 3. Laboratorio (DEP-LAB) -> EQUIPO
    elsif ($departamento eq 'DEP-LAB' || $departamento =~ /Laboratorio/i) {
        $grid->attach($btn_equip, 0, $fila++, 1, 1);
    }
    # 4. Farmacia (DEP-FAR) -> MEDICAMENTOS
    elsif ($departamento eq 'DEP-FAR' || $departamento =~ /Farmacia/i) {
        $grid->attach($btn_meds, 0, $fila++, 1, 1);
    }
    else {
        my $lbl_error = Gtk3::Label->new("No tienes permisos asignados a ningún inventario.");
        $grid->attach($lbl_error, 0, 0, 1, 1);
    }

    $btn_meds->signal_connect(clicked => sub {
        print "Abriendo medicamentos...\n";
    });

    $btn_sumi->signal_connect(clicked => sub {
        print "Abriendo suministros...\n";
    });

    $btn_equip->signal_connect(clicked => sub {
        print "Abriendo equipos...\n";
    });

    $ventana->show_all();
}

1;