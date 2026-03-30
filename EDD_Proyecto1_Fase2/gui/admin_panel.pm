package gui::admin_panel;

use strict;
use warnings;
use Gtk3;

sub mostrar {
    my ($mi_avl, $mi_bst, $mi_lista_meds, $mi_arbol_b, $mi_lista_prov, $mi_matriz) = @_; 

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("EDD MedTrack - Panel de Administrador");
    $ventana->set_default_size(700, 450); 
    $ventana->set_position('center');
    
    $ventana->signal_connect(destroy => sub { Gtk3->main_quit() });

    my $caja_principal = Gtk3::Box->new('vertical', 20);
    $caja_principal->set_border_width(20);
    $ventana->add($caja_principal);

    # Encabezado
    my $lbl_bienvenida = Gtk3::Label->new();
    $lbl_bienvenida->set_markup("<span size='x-large' weight='bold'>Panel de Control Principal</span>\n<span color='gray'>Administrador General</span>");
    $lbl_bienvenida->set_justify('center');
    $caja_principal->pack_start($lbl_bienvenida, 0, 0, 10);

    # Contenedor columnas
    my $grid_modulos = Gtk3::Grid->new();
    $grid_modulos->set_column_spacing(20);
    $grid_modulos->set_row_spacing(20);
    $grid_modulos->set_column_homogeneous(1); 
    $caja_principal->pack_start($grid_modulos, 1, 1, 0);

    # Columna 1: Inventario
    my $frame_inv = Gtk3::Frame->new("Modulo de Inventario");
    my $caja_inv = Gtk3::Box->new('vertical', 10);
    $caja_inv->set_border_width(15);
    $frame_inv->add($caja_inv);
    $grid_modulos->attach($frame_inv, 0, 0, 1, 1);

    my $btn_cargaIn = Gtk3::Button->new_with_label("Carga Masiva Inventario (JSON)");
    my $btn_gestionarIn_Equipo = Gtk3::Button->new_with_label("Gestionar Equipos Medicos");
    my $btn_gestionarIn_Suministro = Gtk3::Button->new_with_label("Gestionar Suministros Medicos");
    my $btn_matriz = Gtk3::Button->new_with_label("Consultar y Comparar Inventario");

    $caja_inv->pack_start($btn_cargaIn, 0, 0, 0);
    $caja_inv->pack_start($btn_gestionarIn_Equipo, 0, 0, 0);
    $caja_inv->pack_start($btn_gestionarIn_Suministro, 0, 0, 0);
    $caja_inv->pack_start($btn_matriz, 0, 0, 0);

    # Columna 2: Personal
    my $frame_us = Gtk3::Frame->new("Modulo de Personal");
    my $caja_us = Gtk3::Box->new('vertical', 10);
    $caja_us->set_border_width(15);
    $frame_us->add($caja_us);
    $grid_modulos->attach($frame_us, 1, 0, 1, 1);

    my $btn_cargaUs = Gtk3::Button->new_with_label("Carga Masiva Usuarios (JSON)");
    my $btn_registrarUs = Gtk3::Button->new_with_label("Registrar Usuario Departamental");
    my $btn_panelUs = Gtk3::Button->new_with_label("Gestion de Personal");
    
    $caja_us->pack_start($btn_cargaUs, 0, 0, 0);
    $caja_us->pack_start($btn_registrarUs, 0, 0, 0);
    $caja_us->pack_start($btn_panelUs, 0, 0, 0);

    # Seccion inferior
    my $caja_inferior = Gtk3::Box->new('horizontal', 15);
    $caja_principal->pack_end($caja_inferior, 0, 0, 0);

    my $btn_reportes = Gtk3::Button->new_with_label("Generar Reportes (Graphviz)");
    my $btn_salir = Gtk3::Button->new_with_label("Cerrar Sesion");

    $btn_salir->signal_connect(clicked => sub {
        $ventana->hide();
        require gui::login;
        gui::login::mostrar($mi_avl, $mi_bst, $mi_lista_meds, $mi_arbol_b, $mi_lista_prov, $mi_matriz);
    });

    $btn_gestionarIn_Equipo->signal_connect(clicked => sub {
        $ventana->hide();
        require gui::admin_panelEq;
        gui::admin_panelEq::mostrar($mi_avl, $mi_bst, $mi_lista_meds, $mi_arbol_b, $mi_lista_prov, $mi_matriz);
    });

    $btn_gestionarIn_Suministro->signal_connect(clicked => sub {
        $ventana->hide();
        require gui::admin_panelSum;
        gui::admin_panelSum::mostrar($mi_avl, $mi_bst, $mi_lista_meds, $mi_arbol_b, $mi_lista_prov, $mi_matriz);
    });

    $btn_cargaIn->signal_connect(clicked => sub {
        my $dialogo = Gtk3::FileChooserDialog->new(
            "Seleccionar JSON de Inventario", $ventana, 'open',
            'Cancelar' => 'cancel', 'Abrir' => 'accept'
        );
        my $filtro = Gtk3::FileFilter->new();
        $filtro->set_name("Archivos JSON");
        $filtro->add_pattern("*.json");
        $dialogo->add_filter($filtro);

        if ($dialogo->run() eq 'accept') {
            my $path = $dialogo->get_filename();
            
            require json::CargaInventario;
            my $resultado = json::CargaInventario::cargar_desde_archivo($path, $mi_bst, $mi_lista_meds, $mi_arbol_b, $mi_lista_prov, $mi_matriz);
            
            my $msg = Gtk3::MessageDialog->new($ventana, 'destroy-with-parent', 'info', 'ok', "");
            $msg->set_markup($resultado);
            $msg->run();
            $msg->destroy();
        }
        $dialogo->destroy();
    });

    $btn_cargaUs->signal_connect(clicked => sub {
        my $dialogo = Gtk3::FileChooserDialog->new(
            "Seleccionar archivo JSON de Usuarios", $ventana, 'open',
            'Cancelar' => 'cancel', 'Abrir' => 'accept'
        );
        my $filtro = Gtk3::FileFilter->new();
        $filtro->set_name("Archivos JSON");
        $filtro->add_pattern("*.json");
        $dialogo->add_filter($filtro);

        if ($dialogo->run() eq 'accept') {
            my $path = $dialogo->get_filename();
            
            require json::CargaUsuario;
            my $resultado = json::CargaUsuario::cargar_desde_archivo($path, $mi_avl);

            my $msg = Gtk3::MessageDialog->new($ventana, 'destroy-with-parent', 'info', 'ok', "");
            $msg->set_markup($resultado);
            $msg->run();
            $msg->destroy();
        }
        $dialogo->destroy();
    });

    $btn_panelUs->signal_connect(clicked => sub {
        $ventana->hide();
        require gui::admin_panelUs;
        gui::admin_panelUs::mostrar($mi_avl, $mi_bst, $mi_lista_meds, $mi_arbol_b, $mi_lista_prov, $mi_matriz);
    });

    $btn_registrarUs->signal_connect(clicked => sub {
        $ventana->hide();
        require gui::admin_registrarUs;
        gui::admin_registrarUs::mostrar($mi_avl, $mi_bst, $mi_lista_meds, $mi_arbol_b, $mi_lista_prov, $mi_matriz);
    });

    $btn_matriz->signal_connect(clicked => sub {
        $ventana->hide();
        require gui::admin_panelMatriz;
        gui::admin_panelMatriz::mostrar($mi_avl, $mi_bst, $mi_lista_meds, $mi_arbol_b, $mi_lista_prov, $mi_matriz);
    });

    $btn_reportes->signal_connect(clicked => sub {
        $ventana->hide();
        require gui::admin_panelReportes;
        gui::admin_panelReportes::mostrar($mi_avl, $mi_bst, $mi_lista_meds, $mi_arbol_b, $mi_lista_prov, $mi_matriz);
    });

    $caja_inferior->pack_start($btn_reportes, 1, 1, 0);
    $caja_inferior->pack_start($btn_salir, 0, 0, 0);

    $ventana->show_all();
}

sub mostrar_mensaje { 
    my ($p, $tipo, $txt) = @_;
    my $d = Gtk3::MessageDialog->new($p, 'destroy-with-parent', $tipo, 'ok', $txt);
    $d->run(); $d->destroy();
}


1;