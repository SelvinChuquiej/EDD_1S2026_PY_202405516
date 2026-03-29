package gui::admin_recorridos;

use strict;
use warnings;
use Gtk3;

sub mostrar {
    my ($mi_avl, $mi_bst) = @_;

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("EDD MedTrack - Comparativa de Recorridos");
    $ventana->set_default_size(900, 500);
    $ventana->set_position('center');

    my $caja_principal = Gtk3::Box->new('horizontal', 15);
    $caja_principal->set_border_width(20);
    $ventana->add($caja_principal);

    my $caja_izq = Gtk3::Box->new('vertical', 10);
    $caja_principal->pack_start($caja_izq, 1, 1, 0);

    my $lbl_titulo = Gtk3::Label->new();
    $lbl_titulo->set_markup("<span size='large' weight='bold'>Resultados del Recorrido</span>");
    $caja_izq->pack_start($lbl_titulo, 0, 0, 0);

    my $modelo_tabla = Gtk3::ListStore->new('Glib::String', 'Glib::String', 'Glib::String');
    my $vista_tabla = Gtk3::TreeView->new_with_model($modelo_tabla);

    my @titulos = ("Pre-Orden", "In-Orden", "Post-Orden");
    for my $i (0 .. $#titulos) {
        my $render = Gtk3::CellRendererText->new();
        my $col = Gtk3::TreeViewColumn->new_with_attributes($titulos[$i], $render, text => $i);
        $col->set_expand(1); 
        $vista_tabla->append_column($col);
    }

    my $scroll = Gtk3::ScrolledWindow->new();
    $scroll->set_policy('automatic', 'automatic');
    $scroll->add($vista_tabla);
    $caja_izq->pack_start($scroll, 1, 1, 0);

    my $caja_der = Gtk3::Box->new('vertical', 15);
    $caja_principal->pack_start($caja_der, 0, 0, 0);

    my $lbl_btn = Gtk3::Label->new();
    $lbl_btn->set_markup("<span weight='bold'>Seleccionar\nEstructura:</span>");
    $lbl_btn->set_justify('center');
    $caja_der->pack_start($lbl_btn, 0, 0, 10);

    my $btn_avl = Gtk3::Button->new_with_label("Arbol AVL (Usuarios)");
    my $btn_bst = Gtk3::Button->new_with_label("Arbol BST (Equipos)");

    $btn_avl->set_size_request(150, 40);
    $btn_bst->set_size_request(150, 40);

    $caja_der->pack_start($btn_avl, 0, 0, 0);
    $caja_der->pack_start($btn_bst, 0, 0, 0);

    $btn_avl->signal_connect(clicked => sub {
        llenar_tabla($modelo_tabla, $mi_avl, 'avl');
    });

    $btn_bst->signal_connect(clicked => sub {
        llenar_tabla($modelo_tabla, $mi_bst, 'bst');
    });

    $ventana->show_all();
}

sub llenar_tabla {
    my ($modelo, $arbol, $tipo) = @_;
    $modelo->clear();

    if (!defined $arbol || !defined $arbol->{raiz}) {
        my $iter = $modelo->append();
        $modelo->set($iter, 0 => "Arbol Vacio", 1 => "Arbol Vacio", 2 => "Arbol Vacio");
        return;
    }

    my $arr_pre = $arbol->pre_orden();
    my $arr_in = $arbol->in_orden();
    my $arr_post = $arbol->post_orden();

    my $total = scalar(@$arr_in);

    for my $i (0 .. $total - 1) {
        my $str_pre  = formatear_nodo($arr_pre->[$i], $tipo);
        my $str_in   = formatear_nodo($arr_in->[$i], $tipo);
        my $str_post = formatear_nodo($arr_post->[$i], $tipo);

        my $iter = $modelo->append();
        $modelo->set($iter,
            0 => $str_pre,
            1 => $str_in,
            2 => $str_post
        );
    }
}

sub formatear_nodo {
    my ($nodo, $tipo) = @_;
    return "" unless defined $nodo;
    
    if ($tipo eq 'avl') {
        return "[$nodo->{numero_colegio}] $nodo->{nombre_completo}";
    } else {
        return "[$nodo->{codigo}] $nodo->{nombre}";
    }
}

1;