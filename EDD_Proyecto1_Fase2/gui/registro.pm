package gui::registro;

use strict;
use warnings;
use Gtk3;

sub mostrar {
    my ($parent, $mi_avl) = @_;

    my $win = Gtk3::Window->new('toplevel');
    $win->set_title("Registro de Personal Médico");
    $win->set_default_size(450, 500);
    $win->set_position('center_on_parent');
    $win->set_transient_for($parent);
    $win->set_modal(1);

    my $vbox = Gtk3::Box->new('vertical', 15);
    $vbox->set_border_width(25);
    $win->add($vbox);

    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(12);
    $grid->set_column_spacing(15);
    $vbox->pack_start($grid, 1, 1, 0);

    my $e_col = Gtk3::Entry->new();
    my $e_nom = Gtk3::Entry->new();
    my $e_esp = Gtk3::Entry->new();
    my $e_pas = Gtk3::Entry->new(); $e_pas->set_visibility(0);
    
    my $cb_t = Gtk3::ComboBoxText->new();
    foreach ("TIPO-01", "TIPO-02", "TIPO-03", "TIPO-04") { $cb_t->append_text($_) }
    $cb_t->set_active(0);

    my $cb_d = Gtk3::ComboBoxText->new();
    foreach ("DEP-MED", "DEP-CIR", "DEP-LAB", "DEP-FAR") { $cb_d->append_text($_) }
    $cb_d->set_active(0);

    my @labels = ("No. Colegio:", "Nombre Completo:", "Tipo Usuario:", "Departamento:", "Especialidad:", "Contraseña:");
    my @widgets = ($e_col, $e_nom, $cb_t, $cb_d, $e_esp, $e_pas);

    for my $i (0..$#labels) {
        my $l = Gtk3::Label->new($labels[$i]);
        $l->set_halign('start');
        $grid->attach($l, 0, $i, 1, 1);
        $grid->attach($widgets[$i], 1, $i, 1, 1);
    }

    my $btn = Gtk3::Button->new_with_label("Registrar en AVL");
    $btn->set_margin_top(10);
    $vbox->pack_end($btn, 0, 0, 0);

    $btn->signal_connect(clicked => sub {
        my $id = $e_col->get_text();
        if ($id eq '' || $e_nom->get_text() eq '' || $e_pas->get_text() eq '') {
            mostrar_msj($win, "error", "Faltan datos obligatorios");
            return;
        }

        if (defined $mi_avl->buscar($id)) {
            mostrar_msj($win, "error", "El colegiado $id ya existe en el AVL");
            return;
        }

        $mi_avl->insertar({
            numero_colegio  => $id,
            nombre_completo => $e_nom->get_text(),
            tipo_usuario => $cb_t->get_active_text(),
            departamento => $cb_d->get_active_text(),
            especialidad => $e_esp->get_text() || "N/A",
            contrasena => $e_pas->get_text()
        });

        mostrar_msj($win, "info", "Registrado exitosamente");
        $win->destroy();
    });

    $win->show_all();
}

sub mostrar_msj {
    my ($p, $t, $m) = @_;
    my $d = Gtk3::MessageDialog->new($p, 'destroy-with-parent', $t, 'ok', $m);
    $d->run(); $d->destroy();
}

1;