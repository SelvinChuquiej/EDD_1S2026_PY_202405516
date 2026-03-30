package gui::admin_panelUs;

use strict;
use warnings;
use Gtk3;

sub mostrar {
    my ($mi_avl, $mi_bst, $mi_lista_meds, $mi_arbol_b, $mi_lista_prov, $mi_matriz) = @_; 

    # Ventana principal
    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("Panel de Control de Personal Medico");
    $ventana->set_default_size(900, 500);
    $ventana->set_position('center');

    my $vbox = Gtk3::Box->new('vertical', 15);
    $vbox->set_border_width(20);
    $ventana->add($vbox);

    # Barra superior con botones
    my $caja_superior = Gtk3::Box->new('horizontal', 15);
    $vbox->pack_start($caja_superior, 0, 0, 0);

    my $btn_volver = Gtk3::Button->new_with_label("Volver al Panel Principal");
    $caja_superior->pack_start($btn_volver, 0, 0, 0);
    
    $btn_volver->signal_connect(clicked => sub {
        $ventana->hide();
        require gui::admin_panel; 
        gui::admin_panel::mostrar($mi_avl, $mi_bst, $mi_lista_meds, $mi_arbol_b, $mi_lista_prov, $mi_matriz);
    });

    my $hbox_cuerpo = Gtk3::Box->new('horizontal', 15);
    $vbox->pack_start($hbox_cuerpo, 1, 1, 0);

    # Tabla
    my $modelo_tabla = Gtk3::ListStore->new('Glib::String', 'Glib::String', 'Glib::String', 'Glib::String');
    my $vista_tabla = Gtk3::TreeView->new_with_model($modelo_tabla);

    my @titulos = ("Numero de Colegio", "Nombre Completo", "Especialidad", "Departamento");
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
    $lbl_acciones->set_markup("<span weight='bold'>Acciones:</span>");
    $vbox_lateral->pack_start($lbl_acciones, 0, 0, 0);

    my $btn_buscar = Gtk3::Button->new_with_label("Buscar Usuario");
    my $btn_eliminar = Gtk3::Button->new_with_label("Eliminar Usuario");
    my $btn_in = Gtk3::Button->new_with_label("In-Orden (Por Defecto)");
    my $btn_pre = Gtk3::Button->new_with_label("Pre-Orden");
    my $btn_post = Gtk3::Button->new_with_label("Post-Orden");

    $btn_buscar->set_size_request(180, 40);
    $btn_eliminar->set_size_request(180, 40);
    $btn_in->set_size_request(180, 40);
    $btn_pre->set_size_request(180, 40);
    $btn_post->set_size_request(180, 40);

    $vbox_lateral->pack_start($btn_buscar, 0, 0, 0);
    $vbox_lateral->pack_start($btn_eliminar, 0, 0, 0);
    $vbox_lateral->pack_start($btn_in, 0, 0, 0);
    $vbox_lateral->pack_start($btn_pre, 0, 0, 0);
    $vbox_lateral->pack_start($btn_post, 0, 0, 0);

    # Logica botones
    $btn_buscar->signal_connect(clicked => sub {
        my $dialogo = Gtk3::Dialog->new(
            "Buscar en AVL", $ventana, 'destroy-with-parent',
            'Cancelar' => 'cancel',
            'Buscar' => 'accept'
        );
        $dialogo->set_default_size(300, 150);
        $dialogo->set_position('center-on-parent');

        my $caja = $dialogo->get_content_area();
        $caja->set_spacing(10);
        $caja->set_border_width(15);

        my $lbl = Gtk3::Label->new("Ingrese el numero de colegio a buscar:");
        my $ent_buscar = Gtk3::Entry->new();
        
        $caja->pack_start($lbl, 0, 0, 0);
        $caja->pack_start($ent_buscar, 0, 0, 0);
        $dialogo->show_all();

        if ($dialogo->run() eq 'accept') {
            my $codigo = $ent_buscar->get_text();
            
            if ($codigo eq '') {
                mostrar_mensaje($ventana, "warning", "Debe ingresar un codigo para buscar.");
            } else {
                my $nodo_encontrado = $mi_avl->buscar($codigo);
                
                if (defined $nodo_encontrado) {
                    my $info = "<span size='large' weight='bold'>Usuario Encontrado</span>\n\n" .
                               "<b>Colegio:</b> " . $nodo_encontrado->{numero_colegio} . "\n" .
                               "<b>Nombre:</b> " . $nodo_encontrado->{nombre_completo} . "\n" .
                               "<b>Tipo:</b> " . $nodo_encontrado->{tipo_usuario} . "\n" .
                               "<b>Departamento:</b> " . $nodo_encontrado->{departamento} . "\n" .
                               "<b>Especialidad:</b> " . ($nodo_encontrado->{especialidad} || "N/A");
                               
                    my $msg = Gtk3::MessageDialog->new($ventana, 'destroy-with-parent', 'info', 'ok', "");
                    $msg->set_markup($info);
                    $msg->run();
                    $msg->destroy();
                } else {
                    mostrar_mensaje($ventana, "error", "No se encontro ningun usuario con el codigo:\n'$codigo'");
                }
            }
        }
        $dialogo->destroy();
    });

    $btn_eliminar->signal_connect(clicked => sub {
        my $dialogo = Gtk3::Dialog->new(
            "Eliminar en AVL", $ventana, 'destroy-with-parent',
            'Cancelar' => 'cancel',
            'Eliminar Definitivamente' => 'accept'
        );
        $dialogo->set_default_size(300, 150);
        $dialogo->set_position('center-on-parent');

        my $caja = $dialogo->get_content_area();
        $caja->set_spacing(10);
        $caja->set_border_width(15);

        my $lbl = Gtk3::Label->new("Ingrese el Numero de Colegio a ELIMINAR:");
        my $ent_eliminar = Gtk3::Entry->new();
        
        $caja->pack_start($lbl, 0, 0, 0);
        $caja->pack_start($ent_eliminar, 0, 0, 0);
        $dialogo->show_all();

        if ($dialogo->run() eq 'accept') {
            my $codigo = $ent_eliminar->get_text();
            
            if ($codigo eq '') {
                mostrar_mensaje($ventana, "warning", "Debe ingresar un codigo.");
            } else {
                if (defined $mi_avl->buscar($codigo)) {
                    $mi_avl->eliminar($codigo);
                    actualizar_tabla($modelo_tabla, $mi_avl->in_orden());
                    mostrar_mensaje($ventana, "info", "El usuario '$codigo' ha sido eliminado.\nEl Arbol AVL ejecuto las rotaciones necesarias para mantener el balance.");
                } else {
                    mostrar_mensaje($ventana, "error", "No se encontro ningún usuario con el código '$codigo' para eliminar.");
                }
            }
        }
        $dialogo->destroy();
    });

    $btn_pre->signal_connect(clicked => sub {
        my $nodos = $mi_avl->pre_orden();
        actualizar_tabla($modelo_tabla, $nodos);
    });

    $btn_in->signal_connect(clicked => sub {
        my $nodos = $mi_avl->in_orden();
        actualizar_tabla($modelo_tabla, $nodos);
    });

    $btn_post->signal_connect(clicked => sub {
        my $nodos = $mi_avl->post_orden();
        actualizar_tabla($modelo_tabla, $nodos);
    });

    actualizar_tabla($modelo_tabla, $mi_avl->in_orden());
    $ventana->show_all();
}

sub actualizar_tabla {
    my ($modelo, $nodos) = @_;
    
    $modelo->clear();
    return unless defined $nodos;

    foreach my $n (@$nodos) {
        my $iter = $modelo->append();
        $modelo->set($iter, 
            0 => $n->{numero_colegio},
            1 => $n->{nombre_completo},
            2 => $n->{especialidad} || "N/A",
            3 => $n->{departamento}
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