package gui::user_panelSum;

use strict;
use warnings;
use Gtk3;

sub mostrar {
    my ($usuario_logueado, $mi_avl, $mi_bst, $lista_meds, $arbol_b, $lista_prov, $mi_matriz) = @_;

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("Modulo de Suministros - Personal Medico");
    $ventana->set_default_size(500, 300);
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
    $lbl_titulo->set_markup("<span size='x-large' weight='bold'>Consultar Disponibilidad de Suministros</span>");
    $vbox->pack_start($lbl_titulo, 0, 0, 0);

    my $caja_busqueda = Gtk3::Box->new('horizontal', 10);
    $caja_busqueda->set_halign('center');
    $vbox->pack_start($caja_busqueda, 0, 0, 0);

    my $lbl_buscar = Gtk3::Label->new("Codigo del Suministro:");
    my $ent_codigo = Gtk3::Entry->new();
    $ent_codigo->set_placeholder_text("Ej. 017");
    my $btn_buscar = Gtk3::Button->new_with_label("Buscar en Arbol B");

    $caja_busqueda->pack_start($lbl_buscar, 0, 0, 0);
    $caja_busqueda->pack_start($ent_codigo, 0, 0, 0);
    $caja_busqueda->pack_start($btn_buscar, 0, 0, 0);

    $btn_buscar->signal_connect(clicked => sub {
        my $codigo = $ent_codigo->get_text();

        if ($codigo eq '') {
            mostrar_mensaje($ventana, "warning", "Por favor, ingrese un codigo para buscar.");
            return;
        }

        my $suministro = $arbol_b->buscar($codigo);

        if (defined $suministro) {
            my $nombre = $suministro->{nombre} || "Desconocido";
            my $fabricante = $suministro->{fabricante} || "N/A";
            my $precio = $suministro->{precio_unitario} || "0.00";
            my $cantidad = $suministro->{cantidad} || 0;
            my $vencimiento = $suministro->{fecha_vencimiento} || "N/A";
            my $minimo = $suministro->{nivel_minimo} || 0;

            my $info = "<span size='large' weight='bold'>Informacion del Suministro</span>\n\n" .
                       "<b>Codigo:</b> $codigo\n" .
                       "<b>Nombre:</b> $nombre\n" .
                       "<b>Fabricante:</b> $fabricante\n" .
                       "<b>Precio:</b> Q $precio\n" .
                       "<b>Cantidad Disponible:</b> $cantidad unidades\n" .
                       "<b>Fecha Vencimiento:</b> $vencimiento\n" .
                       "<b>Nivel Minimo (Medico):</b> $minimo\n\n";

            if ($cantidad < $minimo) {
                $info .= "<span foreground='red' weight='bold' size='large'>ALERTA: Nivel de stock critico.</span>\n";
                $info .= "<span foreground='red'>La cantidad actual esta por debajo del minimo requerido.</span>";
            } else {
                $info .= "<span foreground='green' weight='bold'>Stock en niveles optimos.</span>";
            }

            my $msg = Gtk3::MessageDialog->new($ventana, 'destroy-with-parent', 'info', 'ok', "");
            $msg->set_markup($info);
            $msg->run();
            $msg->destroy();
            
            $ent_codigo->set_text(""); # Limpiamos el buscador
        } else {
            mostrar_mensaje($ventana, "error", "No se encontro ningun suministro con el codigo '$codigo'.");
        }
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