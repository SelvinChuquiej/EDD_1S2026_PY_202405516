package gui::admin_panel;

use strict;
use warnings;
use Gtk3;
use json::CargaUsuario;

sub mostrar {
    my ($mi_avl, $mi_bst) = @_; 

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("EDD MedTrack - Panel de Administrador");
    $ventana->set_default_size(1000, 500);
    $ventana->set_position('center');
    
    $ventana->signal_connect(destroy => sub { Gtk3->main_quit() });

    my $caja_principal = Gtk3::Box->new('horizontal', 10);
    $caja_principal->set_border_width(15);
    $ventana->add($caja_principal);

    my $caja_izq = Gtk3::Box->new('vertical', 10);
    $caja_principal->pack_start($caja_izq, 1, 1, 0);

    my $lbl_titulo_tabla = Gtk3::Label->new();
    $lbl_titulo_tabla->set_markup("<span size='large' weight='bold'>Personal Medico Autorizado</span>");
    $lbl_titulo_tabla->set_halign('start');
    $caja_izq->pack_start($lbl_titulo_tabla, 0, 0, 0);

    #Tabla de usuarios
    my $modelo_tabla = Gtk3::ListStore->new('Glib::String', 'Glib::String', 'Glib::String', 'Glib::String');
    my $vista_tabla = Gtk3::TreeView->new_with_model($modelo_tabla);

    my @titulos = ("Numero de Colegio", "Nombre Completo", "Especialidad", "Departamento");
    for my $i (0 .. $#titulos) {
        my $render = Gtk3::CellRendererText->new();
        my $col = Gtk3::TreeViewColumn->new_with_attributes($titulos[$i], $render, text => $i);
        $col->set_sort_column_id($i); 
        $vista_tabla->append_column($col);
    }

    my $scroll = Gtk3::ScrolledWindow->new();
    $scroll->set_policy('automatic', 'automatic');
    $scroll->add($vista_tabla);
    $caja_izq->pack_start($scroll, 1, 1, 0);

    #Botones y acciones
    my $caja_der = Gtk3::Box->new('vertical', 15);
    $caja_principal->pack_start($caja_der, 0, 0, 0);

    my $lbl_bienvenida = Gtk3::Label->new();
    $lbl_bienvenida->set_markup("<span size='large' weight='bold'>Bienvenido Administrador</span>");
    $caja_der->pack_start($lbl_bienvenida, 0, 0, 20);

    my $btn_carga = Gtk3::Button->new_with_label("Carga Masiva (JSON)");
    my $btn_orden = Gtk3::Button->new_with_label("Recorridos");
    my $btn_reportes = Gtk3::Button->new_with_label("Reportes");
    
    $caja_der->pack_start($btn_carga, 0, 0, 0);
    $caja_der->pack_start($btn_orden, 0, 0, 0);
    $caja_der->pack_start($btn_reportes, 0, 0, 0);

    $btn_carga->signal_connect(clicked => sub {
        my $dialogo = Gtk3::FileChooserDialog->new(
            "Seleccionar archivo JSON", $ventana, 'open',
            'Cancelar' => 'cancel', 'Abrir' => 'accept'
        );
        my $filtro = Gtk3::FileFilter->new();
        $filtro->set_name("Archivos JSON");
        $filtro->add_pattern("*.json");
        $dialogo->add_filter($filtro);

        if ($dialogo->run() eq 'accept') {
            my $path = $dialogo->get_filename();
            print "Archivo seleccionado: $path\n";
            json::CargaUsuario::cargar_desde_archivo($path, $mi_avl);
            actualizar_tabla($mi_avl, $modelo_tabla);
            mostrar_mensaje($ventana, "info", "Datos cargados al AVL correctamente.");
        }
        $dialogo->destroy();
    });

    $btn_orden->signal_connect(clicked => sub {
        require gui::admin_recorridos;
        gui::admin_recorridos::mostrar($mi_avl, $mi_bst);
    });

    $btn_reportes->signal_connect(clicked => sub {
        my $codigo_dot = $mi_avl->generar_dot();
        my $nombre_dot = "reporte_avl.dot";
        open(my $fh, '>', $nombre_dot) or die "No se pudo crear el archivo dot: $!";
        print $fh $codigo_dot;
        close($fh);
        
        system("dot -Tpng $nombre_dot -o reporte_avl.png");
        
        system("xdg-open reporte_avl.png &");
        
        mostrar_mensaje($ventana, "info", "Reporte generado como 'reporte_avl.png'");
    });

    $ventana->show_all();
}

sub actualizar_tabla {
    my ($arbol, $modelo) = @_;
    $modelo->clear(); 
    my $nodos = $arbol->in_orden(); 
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
    my ($p, $tipo, $txt) = @_;
    my $d = Gtk3::MessageDialog->new($p, 'destroy-with-parent', $tipo, 'ok', $txt);
    $d->run(); $d->destroy();
}

1;