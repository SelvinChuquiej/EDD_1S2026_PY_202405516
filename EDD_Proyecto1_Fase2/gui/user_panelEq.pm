package gui::user_panelEq;

use strict;
use warnings;
use Gtk3;

sub mostrar {
    my ($usuario_logueado, $mi_avl, $mi_bst, $lista_meds, $arbol_b, $lista_prov, $mi_matriz) = @_;

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("Modulo de Equipos - Personal Medico");
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
    $lbl_titulo->set_markup("<span size='x-large' weight='bold'>Consultar Disponibilidad de Equipos Medicos</span>");
    $vbox->pack_start($lbl_titulo, 0, 0, 0);

    my $caja_busqueda = Gtk3::Box->new('horizontal', 10);
    $caja_busqueda->set_halign('center');
    $vbox->pack_start($caja_busqueda, 0, 0, 0);

    my $lbl_buscar = Gtk3::Label->new("Codigo del Equipo:");
    my $ent_codigo = Gtk3::Entry->new();
    $ent_codigo->set_placeholder_text("Ej. EQ-001");
    my $btn_buscar = Gtk3::Button->new_with_label("Buscar en Arbol BST");

    $caja_busqueda->pack_start($lbl_buscar, 0, 0, 0);
    $caja_busqueda->pack_start($ent_codigo, 0, 0, 0);
    $caja_busqueda->pack_start($btn_buscar, 0, 0, 0);

    $btn_buscar->signal_connect(clicked => sub {
        my $codigo = $ent_codigo->get_text();

        if ($codigo eq '') {
            mostrar_mensaje($ventana, "warning", "Por favor, ingrese un codigo para buscar.");
            return;
        }
 
        my $equipo = $mi_bst->find($codigo);

        if (defined $equipo) {
            my $nombre = $equipo->{nombre} || "Desconocido";
            my $fabricante = $equipo->{fabricante} || "N/A";
            my $precio = $equipo->{precio_unitario} || "0.00";
            my $cantidad = $equipo->{cantidad} || 0;
            my $minimo = $equipo->{nivel_minimo} || 0;
            my $fecha_ingreso = $equipo->{fecha_ingreso} || "N/A";

            my $info = "<span size='large' weight='bold'>Informacion del Equipo Quirurgico</span>\n\n" .
                       "<b>Codigo:</b> $codigo\n" .
                       "<b>Nombre:</b> $nombre\n" .
                       "<b>Tipo:</b> EQUIPO\n" .
                       "<b>Fabricante:</b> $fabricante\n" .
                       "<b>Precio Unitario:</b> Q $precio\n" .
                       "<b>Cantidad Disponible:</b> $cantidad unidades\n" .
                       "<b>Nivel Minimo:</b> $minimo\n" .
                       "<b>Fecha de Ingreso:</b> $fecha_ingreso\n\n";

            if ($cantidad > 0) {
                $info .= "<span foreground='green' weight='bold'>Equipo DISPONIBLE para procedimiento.</span>";
            } else {
                $info .= "<span foreground='red' weight='bold' size='large'>Equipo NO DISPONIBLE (Stock agotado).</span>";
            }

            my $msg = Gtk3::MessageDialog->new($ventana, 'destroy-with-parent', 'info', 'ok', "");
            $msg->set_markup($info);
            $msg->run();
            $msg->destroy();
            
            $ent_codigo->set_text(""); 
        } else {
            mostrar_mensaje($ventana, "error", "No se encontro ningun equipo con el codigo '$codigo'.\nVerifique el codigo en el catalogo.");
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