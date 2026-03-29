package gui::admin_panelSum;

use strict;
use warnings;
use Gtk3;

sub mostrar {
    my ($mi_avl, $mi_bst, $lista_meds, $arbol_b, $lista_prov) = @_; 

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("Gestion de Inventario - Suministros (Arbol B Orden 4)");
    $ventana->set_default_size(950, 500);
    $ventana->set_position('center');

    my $vbox = Gtk3::Box->new('vertical', 15);
    $vbox->set_border_width(20);
    $ventana->add($vbox);

    my $caja_superior = Gtk3::Box->new('horizontal', 15);
    $vbox->pack_start($caja_superior, 0, 0, 0);

    my $btn_volver = Gtk3::Button->new_with_label("Volver al Panel Principal");
    $caja_superior->pack_start($btn_volver, 0, 0, 0);
    
    $btn_volver->signal_connect(clicked => sub {
        $ventana->hide();
        require gui::admin_panel; 
        gui::admin_panel::mostrar($mi_avl, $mi_bst, $lista_meds, $arbol_b, $lista_prov); 
    });

    my $hbox_cuerpo = Gtk3::Box->new('horizontal', 15);
    $vbox->pack_start($hbox_cuerpo, 1, 1, 0);

    # Tabla-
    my $modelo_tabla = Gtk3::ListStore->new('Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String');
    my $vista_tabla = Gtk3::TreeView->new_with_model($modelo_tabla);

    my @titulos = ("Codigo", "Nombre del Suministro", "Fabricante", "Cantidad", "Precio Unit.", "Vencimiento");
    for my $i (0 .. $#titulos) {
        my $render = Gtk3::CellRendererText->new();
        my $col = Gtk3::TreeViewColumn->new_with_attributes($titulos[$i], $render, text => $i);
        $col->set_sort_column_id($i); 
        $col->set_expand(1); 
        $vista_tabla->append_column($col);
    }

    my $scroll = Gtk3::ScrolledWindow->new();
    $scroll->set_policy('automatic', 'automatic');
    $scroll->add($vista_tabla);
    $hbox_cuerpo->pack_start($scroll, 1, 1, 0);

    # Botones
    my $vbox_lateral = Gtk3::Box->new('vertical', 15);
    $hbox_cuerpo->pack_start($vbox_lateral, 0, 0, 0);

    my $lbl_acciones = Gtk3::Label->new();
    $lbl_acciones->set_markup("<span weight='bold'>Acciones Arbol B:</span>");
    $vbox_lateral->pack_start($lbl_acciones, 0, 0, 0);

    my $btn_registrar = Gtk3::Button->new_with_label("Registrar Suministro");
    my $btn_buscar = Gtk3::Button->new_with_label("Buscar Suministro");
    my $btn_eliminar = Gtk3::Button->new_with_label("Eliminar Suministro");

    $btn_registrar->set_size_request(180, 40);
    $btn_buscar->set_size_request(180, 40);
    $btn_eliminar->set_size_request(180, 40);

    $vbox_lateral->pack_start($btn_registrar, 0, 0, 0);
    $vbox_lateral->pack_start($btn_buscar, 0, 0, 0);
    $vbox_lateral->pack_start($btn_eliminar, 0, 0, 0);

    $btn_registrar->signal_connect(clicked => sub {
        my $dialogo = Gtk3::Dialog->new(
            "Registrar Nuevo Suministro", $ventana, 'destroy-with-parent',
            'Cancelar' => 'cancel',
            'Guardar en Arbol B' => 'accept'
        );
        $dialogo->set_default_size(350, 400);
        $dialogo->set_position('center-on-parent');

        my $caja = $dialogo->get_content_area();
        $caja->set_spacing(10);
        $caja->set_border_width(15);

        my $grid = Gtk3::Grid->new();
        $grid->set_row_spacing(10);
        $grid->set_column_spacing(15);
        $caja->pack_start($grid, 1, 1, 0);

        my $e_cod = Gtk3::Entry->new(); $grid->attach(Gtk3::Label->new("Codigo:"), 0, 0, 1, 1); $grid->attach($e_cod, 1, 0, 1, 1);
        my $e_nom = Gtk3::Entry->new(); $grid->attach(Gtk3::Label->new("Nombre:"), 0, 1, 1, 1); $grid->attach($e_nom, 1, 1, 1, 1);
        my $e_fab = Gtk3::Entry->new(); $grid->attach(Gtk3::Label->new("Fabricante:"), 0, 2, 1, 1); $grid->attach($e_fab, 1, 2, 1, 1);
        my $e_pre = Gtk3::Entry->new(); $grid->attach(Gtk3::Label->new("Precio Unit:"), 0, 3, 1, 1); $grid->attach($e_pre, 1, 3, 1, 1);
        my $e_can = Gtk3::Entry->new(); $grid->attach(Gtk3::Label->new("Cantidad:"), 0, 4, 1, 1); $grid->attach($e_can, 1, 4, 1, 1);
        my $e_fec = Gtk3::Entry->new(); $e_fec->set_placeholder_text("YYYY-MM-DD o vacio"); 
        $grid->attach(Gtk3::Label->new("Vencimiento:"), 0, 5, 1, 1); $grid->attach($e_fec, 1, 5, 1, 1);
        my $e_min = Gtk3::Entry->new(); $grid->attach(Gtk3::Label->new("Nivel Minimo:"), 0, 6, 1, 1); $grid->attach($e_min, 1, 6, 1, 1);

        $dialogo->show_all();

        if ($dialogo->run() eq 'accept') {
            my $nuevo_suministro = {
                codigo => $e_cod->get_text(),
                nombre => $e_nom->get_text(),
                fabricante => $e_fab->get_text(),
                precio_unitario => $e_pre->get_text(),
                cantidad => $e_can->get_text(),
                fecha_vencimiento => $e_fec->get_text(),
                nivel_minimo => $e_min->get_text()
            };

            if ($nuevo_suministro->{codigo} eq '' || $nuevo_suministro->{nombre} eq '') {
                mostrar_mensaje($ventana, "error", "El codigo y nombre son obligatorios.");
            } else {
                if ($arbol_b->insertar($nuevo_suministro)) {
                    actualizar_tabla_sum($modelo_tabla, $arbol_b->inorden());
                    mostrar_mensaje($ventana, "info", "Suministro '$nuevo_suministro->{codigo}' registrado en el Arbol B.\nSe ajustaron las páginas si fue necesario.");
                } else {
                    mostrar_mensaje($ventana, "error", "El codigo '$nuevo_suministro->{codigo}' ya existe en el sistema.");
                }
            }
        }
        $dialogo->destroy();
    });

    $btn_buscar->signal_connect(clicked => sub {
        my $dialogo = Gtk3::Dialog->new(
            "Buscar Suministro", $ventana, 'destroy-with-parent',
            'Cancelar' => 'cancel',
            'Buscar' => 'accept'
        );
        $dialogo->set_default_size(300, 150);
        $dialogo->set_position('center-on-parent');

        my $caja = $dialogo->get_content_area();
        $caja->set_spacing(10);
        $caja->set_border_width(15);

        my $lbl = Gtk3::Label->new("Ingrese el Codigo del Suministro a buscar:");
        my $ent_buscar = Gtk3::Entry->new();
        $ent_buscar->set_placeholder_text("Ej. SUM-001");
        
        $caja->pack_start($lbl, 0, 0, 0);
        $caja->pack_start($ent_buscar, 0, 0, 0);
        $dialogo->show_all();

        if ($dialogo->run() eq 'accept') {
            my $codigo = $ent_buscar->get_text();
            
            if ($codigo eq '') {
                mostrar_mensaje($ventana, "warning", "Debe ingresar un codigo para buscar.");
            } else {
                my $suministro_encontrado = $arbol_b->buscar($codigo);
                
                if (defined $suministro_encontrado) {
                    my $info = "<span size='large' weight='bold'>Suministro Encontrado</span>\n\n" .
                               "<b>Codigo:</b> " . $suministro_encontrado->{codigo} . "\n" .
                               "<b>Nombre:</b> " . $suministro_encontrado->{nombre} . "\n" .
                               "<b>Fabricante:</b> " . ($suministro_encontrado->{fabricante} || "N/A") . "\n" .
                               "<b>Precio Unitario:</b> Q " . ($suministro_encontrado->{precio_unitario} || "0.00") . "\n" .
                               "<b>Cantidad (Stock):</b> " . $suministro_encontrado->{cantidad} . "\n" .
                               "<b>Vencimiento:</b> " . ($suministro_encontrado->{fecha_vencimiento} || "N/A") . "\n" .
                               "<b>Nivel Minimo:</b> " . ($suministro_encontrado->{nivel_minimo} || "N/A");
                               
                    my $msg = Gtk3::MessageDialog->new($ventana, 'destroy-with-parent', 'info', 'ok', "");
                    $msg->set_markup($info);
                    $msg->run();
                    $msg->destroy();
                } else {
                    mostrar_mensaje($ventana, "error", "Suministro no encontrado.\nNo existe ningun elemento con el codigo '$codigo' en el Arbol B.");
                }
            }
        }
        $dialogo->destroy();
    });

    $btn_eliminar->signal_connect(clicked => sub {
        my $dialogo = Gtk3::Dialog->new(
            "Eliminar Suministro Medico", $ventana, 'destroy-with-parent',
            'Cancelar' => 'cancel',
            'Eliminar Definitivamente' => 'accept'
        );
        $dialogo->set_default_size(300, 150);
        $dialogo->set_position('center-on-parent');

        my $caja = $dialogo->get_content_area();
        $caja->set_spacing(10);
        $caja->set_border_width(15);

        my $lbl = Gtk3::Label->new("Ingrese el Codigo del Suministro a ELIMINAR:");
        my $ent_eliminar = Gtk3::Entry->new();
        $ent_eliminar->set_placeholder_text("Ej. SUM-001");
        
        $caja->pack_start($lbl, 0, 0, 0);
        $caja->pack_start($ent_eliminar, 0, 0, 0);
        $dialogo->show_all();

        if ($dialogo->run() eq 'accept') {
            my $codigo = $ent_eliminar->get_text();
            
            if ($codigo eq '') {
                mostrar_mensaje($ventana, "warning", "Debe ingresar un codigo.");
            } else {
                if (defined $arbol_b->buscar($codigo)) {
                    $arbol_b->eliminar($codigo);
                    actualizar_tabla_sum($modelo_tabla, $arbol_b->inorden());               
                    mostrar_mensaje($ventana, "info", "El suministro '$codigo' ha sido eliminado correctamente.\nEl Arbol B aplico la fusion/redistribucion de paginas necesaria.");
                } else {
                    mostrar_mensaje($ventana, "error", "No se encontro ningún suministro con el codigo '$codigo' para eliminar.");
                }
            }
        }
        $dialogo->destroy();
    });

    actualizar_tabla_sum($modelo_tabla, $arbol_b->inorden());

    $ventana->show_all();
}

sub actualizar_tabla_sum {
    my ($modelo, $nodos) = @_;
    $modelo->clear();
    return unless defined $nodos;

    foreach my $n (@$nodos) {
        my $iter = $modelo->append();
        $modelo->set($iter, 
            0 => $n->{codigo},
            1 => $n->{nombre},
            2 => $n->{fabricante} || "N/A",
            3 => $n->{cantidad},
            4 => "Q " . ($n->{precio_unitario} || "0.00"),
            5 => $n->{fecha_vencimiento} || "N/A"
        );
    }
}

sub mostrar_mensaje {
    my ($parent, $tipo, $texto) = @_;
    my $dialogo = Gtk3::MessageDialog->new($parent, 'destroy-with-parent', $tipo, 'ok', $texto);
    $dialogo->run();
    $dialogo->destroy();
}

1;