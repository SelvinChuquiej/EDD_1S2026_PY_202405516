package gui::user_panel;

use strict;
use warnings;
use Gtk3;

sub mostrar {
    my ($medico, $mi_bst) = @_;
    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("Panel Médico - " . $medico->{nombre_completo});
    $ventana->set_default_size(600, 400);
    $ventana->set_position('center');
    $ventana->signal_connect(destroy => sub { Gtk3->main_quit() });

    my $vbox = Gtk3::Box->new('vertical', 20);
    $vbox->set_border_width(20);
    $ventana->add($vbox);

    my $lbl = Gtk3::Label->new();
    $lbl->set_markup("<span size='x-large'>Bienvenido, <b>" . $medico->{nombre_completo} . "</b></span>\n" .
                     "<span color='gray'>" . $medico->{especialidad} . "</span>");
    $vbox->pack_start($lbl, 0, 0, 10);

    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(10);
    $grid->set_column_spacing(10);
    $grid->set_halign('center');
    $vbox->pack_start($grid, 1, 1, 0);

    my $btn_agenda = Gtk3::Button->new_with_label("Agendar Nueva Cita");
    my $btn_reporte = Gtk3::Button->new_with_label("Ver Mis Citas (BST)");
    my $btn_logout = Gtk3::Button->new_with_label("Cerrar Sesión");

    $grid->attach($btn_agenda, 0, 0, 1, 1);
    $grid->attach($btn_reporte, 1, 0, 1, 1);
    $grid->attach($btn_logout, 0, 1, 2, 1);

    $btn_agenda->signal_connect(clicked => sub {
        print "Abriendo formulario de citas...\n";
    });

    $btn_reporte->signal_connect(clicked => sub {
        my $dot = $mi_bst->generar_dot();
        open(my $fh, '>', "reporte_citas.dot");
        print $fh $dot;
        close($fh);
        system("dot -Tpng reporte_citas.dot -o reporte_citas.png");
        system("xdg-open reporte_citas.png &");
    });

    $btn_logout->signal_connect(clicked => sub {
        $ventana->destroy();
    });

    $ventana->show_all();
}

1;