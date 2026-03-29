package gui::admin_registrarUs;

use strict;
use warnings;
use Gtk3;
use util::Permisos; 

sub mostrar {
    my ($mi_avl, $mi_bst) = @_;

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("Registrar Nuevo Usuario Departamental");
    $ventana->set_default_size(500, 450);
    $ventana->set_position('center');

    my $vbox = Gtk3::Box->new('vertical', 15);
    $vbox->set_border_width(20);
    $ventana->add($vbox);

    my $lbl_titulo = Gtk3::Label->new();
    $lbl_titulo->set_markup("<span size='large' weight='bold'>Formulario de Registro</span>");
    $vbox->pack_start($lbl_titulo, 0, 0, 10);

    # CUADRÍCULA (GRID) PARA EL FORMULARIO
    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(10);
    $grid->set_column_spacing(15);
    $grid->set_halign('center');
    $vbox->pack_start($grid, 1, 1, 0);

    # 1. Número de Colegio
    my $lbl_col = Gtk3::Label->new("No. Colegio:");
    $lbl_col->set_halign('end');
    my $ent_col = Gtk3::Entry->new();
    $grid->attach($lbl_col, 0, 0, 1, 1);
    $grid->attach($ent_col, 1, 0, 1, 1);

    # 2. Nombre Completo
    my $lbl_nom = Gtk3::Label->new("Nombre Completo:");
    $lbl_nom->set_halign('end');
    my $ent_nom = Gtk3::Entry->new();
    $grid->attach($lbl_nom, 0, 1, 1, 1);
    $grid->attach($ent_nom, 1, 1, 1, 1);

    # 3. Tipo de Usuario 
    my $lbl_tipo = Gtk3::Label->new("Tipo de Usuario:");
    $lbl_tipo->set_halign('end');
    my $cb_tipo = Gtk3::ComboBoxText->new();
    foreach ("TIPO-01", "TIPO-02", "TIPO-03", "TIPO-04") { $cb_tipo->append_text($_) }
    $grid->attach($lbl_tipo, 0, 2, 1, 1);
    $grid->attach($cb_tipo, 1, 2, 1, 1);

    # 4. Departamento
    my $lbl_dep = Gtk3::Label->new("Departamento:");
    $lbl_dep->set_halign('end');
    my $cb_dep = Gtk3::ComboBoxText->new();
    foreach ("DEP-ADM", "DEP-MED", "DEP-CIR", "DEP-LAB", "DEP-FAR") { $cb_dep->append_text($_) }
    $grid->attach($lbl_dep, 0, 3, 1, 1);
    $grid->attach($cb_dep, 1, 3, 1, 1);

    # 5. Especialidad
    my $lbl_esp = Gtk3::Label->new("Especialidad:");
    $lbl_esp->set_halign('end');
    my $ent_esp = Gtk3::Entry->new();
    $ent_esp->set_placeholder_text("Solo para TIPO-01 y TIPO-02");
    $grid->attach($lbl_esp, 0, 4, 1, 1);
    $grid->attach($ent_esp, 1, 4, 1, 1);

    # 6. Contraseña
    my $lbl_pass = Gtk3::Label->new("Contraseña:");
    $lbl_pass->set_halign('end');
    my $ent_pass = Gtk3::Entry->new();
    $ent_pass->set_visibility(0); 
    $grid->attach($lbl_pass, 0, 5, 1, 1);
    $grid->attach($ent_pass, 1, 5, 1, 1);

    # BOTÓN DE REGISTRO Y LÓGICA
    my $btn_cancelar = Gtk3::Button->new_with_label("Cancelar");
    my $btn_registrar = Gtk3::Button->new_with_label("Registrar en AVL");

    $vbox->pack_start($btn_cancelar, 0, 0, 0);
    $vbox->pack_start($btn_registrar, 0, 0, 0);

    $btn_cancelar->signal_connect(clicked => sub {
        $ventana->hide();
        require gui::admin_panel;
        gui::admin_panel::mostrar($mi_avl, $mi_bst); 
    });

    $btn_registrar->signal_connect(clicked => sub {
        my $col = $ent_col->get_text();
        my $nom = $ent_nom->get_text();
        my $tipo = $cb_tipo->get_active_text();
        my $dep = $cb_dep->get_active_text();
        my $esp = $ent_esp->get_text();
        my $pass = $ent_pass->get_text();

        if ($col eq '' || $nom eq '' || !defined $tipo || !defined $dep || $pass eq '') {
            mostrar_mensaje($ventana, "error", "Faltan campos obligatorios por llenar.");
            return;
        }

        if (($tipo eq 'TIPO-01' || $tipo eq 'TIPO-02') && $esp eq '') {
            mostrar_mensaje($ventana, "warning", "La especialidad es obligatoria para medicos de $tipo.");
            return;
        }

        if (!util::permisos::validar_registro($dep, $tipo)) {
            mostrar_mensaje($ventana, "error", "Violacion de permisos: Un usuario $tipo no puede pertenecer al departamento $dep.");
            return;
        }

        if (defined $mi_avl->buscar($col)) {
            mostrar_mensaje($ventana, "error", "El numero de colegio '$col' ya existe en el sistema. Registro cancelado.");
            return;
        }

        my $nuevo_usuario = {
            numero_colegio => $col,
            nombre_completo => $nom,
            tipo_usuario => $tipo,
            departamento => $dep,
            especialidad => $esp,
            contrasena => $pass
        };

        $mi_avl->insertar($nuevo_usuario);
        mostrar_mensaje($ventana, "info", "Usuario registrado exitosamente\nEl Arbol AVL se ha actualizado y balanceado.");
        
        $ventana->hide();   
        require gui::admin_panel;
        gui::admin_panel::mostrar($mi_avl, $mi_bst);
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