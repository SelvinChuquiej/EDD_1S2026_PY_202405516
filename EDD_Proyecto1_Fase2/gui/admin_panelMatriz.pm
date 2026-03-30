package gui::admin_panelMatriz;

use strict;
use warnings;
use Gtk3;

sub mostrar {
    my ($mi_avl, $mi_bst, $lista_meds, $arbol_b, $lista_prov, $mi_matriz) = @_; 

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("Consulta de Inventario - Matriz Dispersa");
    $ventana->set_default_size(800, 500);
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

    my $lbl_titulo = Gtk3::Label->new();
    $lbl_titulo->set_markup("<span size='x-large' weight='bold'>Relacion Proveedor / Fabricante</span>");
    $vbox->pack_start($lbl_titulo, 0, 0, 0);

    my $modelo_tabla = Gtk3::ListStore->new('Glib::String', 'Glib::String', 'Glib::Int');
    my $vista_tabla = Gtk3::TreeView->new_with_model($modelo_tabla);

    my @titulos = ("Nombre del Proveedor (Fila)", "Fabricante (Columna)", "Cantidad Total Entregada");
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
    $vbox->pack_start($scroll, 1, 1, 0);

    actualizar_tabla_matriz($modelo_tabla, $mi_matriz);

    $ventana->show_all();
}

sub actualizar_tabla_matriz {
    my ($modelo, $matriz) = @_;
    $modelo->clear();
    
    return unless defined $matriz;

    my $datos = $matriz->list();
    
    if (scalar @$datos == 0) {
        print "ADVERTENCIA: La matriz no tiene datos para mostrar.\n";
    }

    foreach my $fila (@$datos) {
        my $iter = $modelo->append();
        $modelo->set($iter, 
            0 => $fila->{proveedor},
            1 => $fila->{fabricante},
            2 => $fila->{cantidad_total}
        );
    }
}

1;