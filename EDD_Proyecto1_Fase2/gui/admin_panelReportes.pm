package gui::admin_panelReportes;

use strict;
use warnings;
use Gtk3;

sub mostrar {
    my ($mi_avl, $mi_bst, $lista_meds, $arbol_b, $lista_prov, $mi_matriz) = @_;

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("Centro de Reportes Visuales (Graphviz)");
    $ventana->set_default_size(500, 550);
    $ventana->set_position('center');

    my $vbox = Gtk3::Box->new('vertical', 20);
    $vbox->set_border_width(30);
    $ventana->add($vbox);

    my $caja_superior = Gtk3::Box->new('horizontal', 10);
    $vbox->pack_start($caja_superior, 0, 0, 0);

    my $btn_volver = Gtk3::Button->new_with_label("Volver al Panel de Administracion");
    $caja_superior->pack_start($btn_volver, 0, 0, 0);
    
    $btn_volver->signal_connect(clicked => sub {
        $ventana->hide();
        require gui::admin_panel; 
        gui::admin_panel::mostrar($mi_avl, $mi_bst, $lista_meds, $arbol_b, $lista_prov, $mi_matriz); 
    });

    my $lbl_titulo = Gtk3::Label->new();
    $lbl_titulo->set_markup("<span size='x-large' weight='bold'>Generacion de Reportes del Sistema</span>\n<span color='gray'>Seleccione la estructura que desea graficar</span>");
    $lbl_titulo->set_justify('center');
    $vbox->pack_start($lbl_titulo, 0, 0, 0);

    my $caja_botones = Gtk3::Box->new('vertical', 15);
    $caja_botones->set_halign('center');
    $vbox->pack_start($caja_botones, 1, 1, 0);

    my $btn_rep_avl = Gtk3::Button->new_with_label("1. Usuarios (Arbol AVL)");
    my $btn_rep_bst = Gtk3::Button->new_with_label("2. Equipos Medicos (Arbol BST)");
    my $btn_rep_arbolb = Gtk3::Button->new_with_label("3. Suministros (Arbol B)");
    my $btn_rep_listaD = Gtk3::Button->new_with_label("4. Medicamentos (Lista Doble)");
    my $btn_rep_listaC = Gtk3::Button->new_with_label("5. Proveedores (Lista Circular)");
    my $btn_rep_matriz = Gtk3::Button->new_with_label("6. Relacion Prov/Fab (Matriz Dispersa)");

    my @botones = ($btn_rep_avl, $btn_rep_bst, $btn_rep_arbolb, $btn_rep_listaD, $btn_rep_listaC, $btn_rep_matriz);
    foreach my $btn (@botones) {
        $btn->set_size_request(300, 45);
        $caja_botones->pack_start($btn, 0, 0, 0);
    }

    $btn_rep_avl->signal_connect(clicked => sub {
        ejecutar_reporte($ventana, $mi_avl, "avl_usuarios", "Reporte del Arbol AVL de Usuarios");
    });

    $btn_rep_bst->signal_connect(clicked => sub {
        ejecutar_reporte($ventana, $mi_bst, "bst_equipos", "Reporte del Arbol BST de Equipos Medicos");
    });

    $btn_rep_arbolb->signal_connect(clicked => sub {
        ejecutar_reporte($ventana, $arbol_b, "arbol_b_suministros", "Reporte del Arbol B de Suministros");
    });

    $btn_rep_listaD->signal_connect(clicked => sub {
        ejecutar_reporte($ventana, $lista_meds, "lista_doble_medicamentos", "Reporte de la Lista Doble de Medicamentos");
    });

    $btn_rep_listaC->signal_connect(clicked => sub {
        ejecutar_reporte($ventana, $lista_prov, "lista_circular_proveedores", "Reporte de la Lista Circular de Proveedores");
    });

    $btn_rep_matriz->signal_connect(clicked => sub {
        ejecutar_reporte($ventana, $mi_matriz, "matriz_dispersa", "Reporte de la Matriz Dispersa (Relacion Proveedor/Fabricante)");
    });

    $ventana->show_all();
}

sub mostrar_mensaje {
    my ($parent, $tipo, $texto) = @_;
    my $dialogo = Gtk3::MessageDialog->new($parent, 'destroy-with-parent', $tipo, 'ok', $texto);
    $dialogo->run();
    $dialogo->destroy();
}

sub mostrar_imagen_reporte {
    my ($ruta_png, $titulo) = @_;

    if (!-e $ruta_png) {
        print "Error: No se encontro la imagen en $ruta_png\n";
        return;
    }

    my $ventana_img = Gtk3::Window->new('toplevel');
    $ventana_img->set_title($titulo || "Visor de Reportes");
    $ventana_img->set_default_size(800, 600); # Un tamaño decente por defecto
    $ventana_img->set_position('center');

    my $scroll = Gtk3::ScrolledWindow->new();
    $scroll->set_policy('automatic', 'automatic');
    $ventana_img->add($scroll);
    my $imagen = Gtk3::Image->new_from_file($ruta_png);
    $scroll->add($imagen);
    $ventana_img->show_all();
}

sub ejecutar_reporte {
    my ($ventana, $estructura, $nombre_archivo, $titulo) = @_;

    mkdir "reportes" unless -d "reportes";

    my $ruta_dot = "reportes/${nombre_archivo}.dot";
    my $ruta_png = "reportes/${nombre_archivo}.png";

    $estructura->generar_graphviz($ruta_dot, $ruta_png);

    mostrar_mensaje($ventana, "info", "$titulo generado con éxito.\n\nImagen guardada en:\n$ruta_png");
    mostrar_imagen_reporte($ruta_png, $titulo);
}

1;