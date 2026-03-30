package gui::admin_panelEq;

use strict;
use warnings;
use Gtk3;

sub mostrar {
    my ($mi_avl, $mi_bst, $lista_meds, $arbol_b, $lista_prov, $mi_matriz) = @_; 

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("Gestion de Inventario - Equipos Medicos (BST)");
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
        gui::admin_panel::mostrar($mi_avl, $mi_bst, $lista_meds, $arbol_b, $lista_prov, $mi_matriz); 
    });

    my $hbox_cuerpo = Gtk3::Box->new('horizontal', 15);
    $vbox->pack_start($hbox_cuerpo, 1, 1, 0);

    # Tabla
    my $modelo_tabla = Gtk3::ListStore->new('Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String');
    my $vista_tabla = Gtk3::TreeView->new_with_model($modelo_tabla);

    my @titulos = ("Codigo", "Nombre del Equipo", "Fabricante", "Cantidad", "Precio Unit.");
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
    $lbl_acciones->set_markup("<span weight='bold'>Acciones BST:</span>");
    $vbox_lateral->pack_start($lbl_acciones, 0, 0, 0);

    my $btn_registrar = Gtk3::Button->new_with_label("Registrar Equipo");
    my $btn_buscar = Gtk3::Button->new_with_label("Buscar Equipo");
    my $btn_eliminar = Gtk3::Button->new_with_label("Eliminar Equipo");
    my $btn_in = Gtk3::Button->new_with_label("In-Orden (Por Defecto)");
    my $btn_pre = Gtk3::Button->new_with_label("Pre-Orden");
    my $btn_post = Gtk3::Button->new_with_label("Post-Orden");

    $btn_registrar->set_size_request(180, 40);
    $btn_buscar->set_size_request(180, 40);
    $btn_eliminar->set_size_request(180, 40);
    $btn_in->set_size_request(180, 40);
    $btn_pre->set_size_request(180, 40);
    $btn_post->set_size_request(180, 40);

    $vbox_lateral->pack_start($btn_registrar, 0, 0, 0);
    $vbox_lateral->pack_start($btn_buscar, 0, 0, 0);
    $vbox_lateral->pack_start($btn_eliminar, 0, 0, 0);
    $vbox_lateral->pack_start($btn_in, 0, 0, 0);
    $vbox_lateral->pack_start($btn_pre, 0, 0, 0);
    $vbox_lateral->pack_start($btn_post, 0, 0, 0);

    $btn_registrar->signal_connect(clicked => sub {
        my $dialogo = Gtk3::Dialog->new(
            "Registrar Nuevo Equipo", $ventana, 'destroy-with-parent',
            'Cancelar' => 'cancel',
            'Guardar en BST' => 'accept'
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
        my $e_fec = Gtk3::Entry->new(); $e_fec->set_placeholder_text("YYYY-MM-DD"); 
        $grid->attach(Gtk3::Label->new("Fecha Ingreso:"), 0, 5, 1, 1); $grid->attach($e_fec, 1, 5, 1, 1);
        my $e_min = Gtk3::Entry->new(); $grid->attach(Gtk3::Label->new("Nivel Minimo:"), 0, 6, 1, 1); $grid->attach($e_min, 1, 6, 1, 1);

        $dialogo->show_all();

        if ($dialogo->run() eq 'accept') {
            my $nuevo_equipo = {
                codigo => $e_cod->get_text(),
                nombre => $e_nom->get_text(),
                fabricante => $e_fab->get_text(),
                precio_unitario => $e_pre->get_text(),
                cantidad => $e_can->get_text(), 
                fecha_ingreso => $e_fec->get_text(),
                nivel_minimo => $e_min->get_text()
            };

            if ($nuevo_equipo->{codigo} eq '' || $nuevo_equipo->{nombre} eq '') {
                mostrar_mensaje($ventana, "error", "El codigo y nombre son obligatorios.");
            } else {
                $mi_bst->insertar($nuevo_equipo);
                
                actualizar_tabla_eq($modelo_tabla, $mi_bst->in_orden());
                mostrar_mensaje($ventana, "info", "Equipo '$nuevo_equipo->{codigo}' registrado en el BST.");
            }
        }
        $dialogo->destroy();
    });

    $btn_buscar->signal_connect(clicked => sub {
        my $dialogo = Gtk3::Dialog->new(
            "Buscar Equipo Medico", $ventana, 'destroy-with-parent',
            'Cancelar' => 'cancel',
            'Buscar' => 'accept'
        );
        $dialogo->set_default_size(300, 150);
        $dialogo->set_position('center-on-parent');

        my $caja = $dialogo->get_content_area();
        $caja->set_spacing(10);
        $caja->set_border_width(15);

        my $lbl = Gtk3::Label->new("Ingrese el Codigo del Equipo a buscar:");
        my $ent_buscar = Gtk3::Entry->new();
        $ent_buscar->set_placeholder_text("Ej. EQ-001");
        
        $caja->pack_start($lbl, 0, 0, 0);
        $caja->pack_start($ent_buscar, 0, 0, 0);
        $dialogo->show_all();

        if ($dialogo->run() eq 'accept') {
            my $codigo = $ent_buscar->get_text();
            
            if ($codigo eq '') {
                mostrar_mensaje($ventana, "warning", "Debe ingresar un codigo para buscar.");
            } else {
                my $nodo_encontrado = $mi_bst->find($codigo);
                
                if (defined $nodo_encontrado) {
                    my $info = "<span size='large' weight='bold'>Equipo Encontrado</span>\n\n" .
                               "<b>Codigo:</b> " . $nodo_encontrado->{codigo} . "\n" .
                               "<b>Nombre:</b> " . $nodo_encontrado->{nombre} . "\n" .
                               "<b>Fabricante:</b> " . ($nodo_encontrado->{fabricante} || "N/A") . "\n" .
                               "<b>Precio Unitario:</b> Q " . ($nodo_encontrado->{precio_unitario} || "0.00") . "\n" .
                               "<b>Cantidad (Stock):</b> " . $nodo_encontrado->{cantidad} . "\n" .
                               "<b>Nivel Minimo:</b> " . ($nodo_encontrado->{nivel_minimo} || "N/A") . "\n" .
                               "<b>Fecha de Ingreso:</b> " . ($nodo_encontrado->{fecha_ingreso} || "N/A");
                               
                    my $msg = Gtk3::MessageDialog->new($ventana, 'destroy-with-parent', 'info', 'ok', "");
                    $msg->set_markup($info);
                    $msg->run();
                    $msg->destroy();
                } else {
                    mostrar_mensaje($ventana, "error", "Equipo no encontrado.\nNo existe ningún equipo con el codigo '$codigo' en el Árbol BST.");
                }
            }
        }
        $dialogo->destroy();
    });

    $btn_eliminar->signal_connect(clicked => sub {
        my $dialogo = Gtk3::Dialog->new(
            "Eliminar Equipo Medico", $ventana, 'destroy-with-parent',
            'Cancelar' => 'cancel',
            'Eliminar Definitivamente' => 'accept'
        );
        $dialogo->set_default_size(300, 150);
        $dialogo->set_position('center-on-parent');

        my $caja = $dialogo->get_content_area();
        $caja->set_spacing(10);
        $caja->set_border_width(15);

        my $lbl = Gtk3::Label->new("Ingrese el Codigo del Equipo a ELIMINAR:");
        my $ent_eliminar = Gtk3::Entry->new();
        $ent_eliminar->set_placeholder_text("Ej. EQ-001");
        
        $caja->pack_start($lbl, 0, 0, 0);
        $caja->pack_start($ent_eliminar, 0, 0, 0);
        $dialogo->show_all();

        if ($dialogo->run() eq 'accept') {
            my $codigo = $ent_eliminar->get_text();
            
            if ($codigo eq '') {
                mostrar_mensaje($ventana, "warning", "Debe ingresar un codigo.");
            } else {
                if (defined $mi_bst->find($codigo)) {    
                    $mi_bst->eliminar($codigo);
                    actualizar_tabla_eq($modelo_tabla, $mi_bst->in_orden());
                    mostrar_mensaje($ventana, "info", "El equipo '$codigo' ha sido eliminado correctamente.\nEl Arbol BST se ha reestructurado.");
                } else {
                    mostrar_mensaje($ventana, "error", "No se encontro ningun equipo con el codigo '$codigo' en el inventario.");
                }
            }
        }
        $dialogo->destroy();
    });

    $btn_pre->signal_connect(clicked => sub {
        my $nodos = $mi_bst->pre_orden();
        actualizar_tabla_eq($modelo_tabla, $nodos);
    });

    $btn_in->signal_connect(clicked => sub {
        my $nodos = $mi_bst->in_orden();
        actualizar_tabla_eq($modelo_tabla, $nodos);
    });

    $btn_post->signal_connect(clicked => sub {
        my $nodos = $mi_bst->post_orden();
        actualizar_tabla_eq($modelo_tabla, $nodos);
    });

    actualizar_tabla_eq($modelo_tabla, $mi_bst->in_orden());
    $ventana->show_all();
}

sub actualizar_tabla_eq {
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
            4 => "Q " . ($n->{precio_unitario} || "0.00")
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