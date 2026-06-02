package estructuras::TablaHash;

use strict;
use warnings;
use utf8;

use nodos::NodoHash;
use nodos::SlotHash;

sub new {
    my ($class) = @_;

    my $self = {
        capacidad => 4,
        tamanio => 0,
        cabeza_slots => undef
    };

    bless $self, $class;

    my $indice = 0;
    my $slot_anterior = undef;

    while ($indice < $self->{capacidad}) {
        my $nuevo_slot = nodos::SlotHash->new($indice);

        if (!defined $self->{cabeza_slots}) {
            $self->{cabeza_slots} = $nuevo_slot;
        } else {
            $slot_anterior->{next_slot} = $nuevo_slot;
        }

        $slot_anterior = $nuevo_slot;
        $indice++;
    }

    return $self;
}

# Limpiar texto
sub limpiar_texto {
    my ($self, $valor) = @_;

    $valor = "" unless defined $valor;
    $valor =~ s/^\s+|\s+$//g;

    return uc($valor);
}

# Escapar texto para Graphviz
sub escapar_html {
    my ($self, $valor) = @_;

    $valor = "" unless defined $valor;
    $valor =~ s/&/&amp;/g;
    $valor =~ s/</&lt;/g;
    $valor =~ s/>/&gt;/g;
    $valor =~ s/"/&quot;/g;

    return $valor;
}

sub funcion_hash {
    my ($self, $tipo_usuario) = @_;

    $tipo_usuario = $self->limpiar_texto($tipo_usuario);

    return 0 if ($tipo_usuario eq "TIPO-01");
    return 1 if ($tipo_usuario eq "TIPO-02");
    return 2 if ($tipo_usuario eq "TIPO-03");
    return 3 if ($tipo_usuario eq "TIPO-04");

    return -1;
}

# Obtener nombre del tipo segun el indice del slot
sub obtener_tipo_por_indice {
    my ($self, $indice) = @_;

    return "TIPO-01" if ($indice == 0);
    return "TIPO-02" if ($indice == 1);
    return "TIPO-03" if ($indice == 2);
    return "TIPO-04" if ($indice == 3);

    return "DESCONOCIDO";
}

# Obtener un slot por indice recorriendo la lista enlazada de slots
sub obtener_slot {
    my ($self, $indice) = @_;

    my $slot_actual = $self->{cabeza_slots};

    while (defined $slot_actual) {
        return $slot_actual if ($slot_actual->{indice} == $indice);
        $slot_actual = $slot_actual->{next_slot};
    }

    return undef;
}

# Obtener numero de colegio del usuario
sub obtener_numero_colegio {
    my ($self, $datos_usuario) = @_;

    return "" unless defined $datos_usuario;

    if (eval { exists $datos_usuario->{numero_colegio} }) {
        return $datos_usuario->{numero_colegio};
    }
    if (eval { $datos_usuario->can('get_numero_colegio') }) {
        return $datos_usuario->get_numero_colegio();
    }
    if (eval { $datos_usuario->can('getNumeroColegio') }) {
        return $datos_usuario->getNumeroColegio();
    }

    return "";
}

# Verificar si ya existe un usuario por numero de colegio
sub existe_numero_colegio {
    my ($self, $numero_colegio) = @_;

    $numero_colegio = $self->limpiar_texto($numero_colegio);
    return 0 if ($numero_colegio eq "");

    my $slot_actual = $self->{cabeza_slots};

    while (defined $slot_actual) {
        my $nodo_actual = $slot_actual->{cabeza_lista};
        while (defined $nodo_actual) {
            my $numero_actual = $self->limpiar_texto(
                $self->obtener_numero_colegio($nodo_actual->{datos})
            );
            return 1 if ($numero_actual eq $numero_colegio);
            $nodo_actual = $nodo_actual->{next};
        }
        $slot_actual = $slot_actual->{next_slot};
    }

    return 0;
}

# Eliminar un usuario de cualquier slot por numero de colegio
sub eliminar_por_numero_colegio {
    my ($self, $numero_colegio) = @_;

    $numero_colegio = $self->limpiar_texto($numero_colegio);
    return 0 if ($numero_colegio eq "");

    my $slot_actual = $self->{cabeza_slots};

    while (defined $slot_actual) {
        my $anterior = undef;
        my $actual = $slot_actual->{cabeza_lista};

        while (defined $actual) {
            my $numero_actual = $self->limpiar_texto(
                $self->obtener_numero_colegio($actual->{datos})
            );
            if ($numero_actual eq $numero_colegio) {
                if (defined $anterior) {
                    $anterior->{next} = $actual->{next};
                } else {
                    $slot_actual->{cabeza_lista} = $actual->{next};
                }

                $self->{tamanio}-- if ($self->{tamanio} > 0);
                return 1;
            }
            $anterior = $actual;
            $actual = $actual->{next};
        }
        $slot_actual = $slot_actual->{next_slot};
    }

    return 0;
}

# Insertar usuario en la tabla hash
sub insertar {
    my ($self, $tipo_usuario, $datos_usuario) = @_;

    $tipo_usuario = $self->limpiar_texto($tipo_usuario);

    return 0 if ($tipo_usuario eq "");
    return 0 unless defined $datos_usuario;

    my $indice = $self->funcion_hash($tipo_usuario);
    return 0 if ($indice < 0);

    my $numero_colegio = $self->limpiar_texto(
        $self->obtener_numero_colegio($datos_usuario)
    );

    if ($numero_colegio ne "") {
        $self->eliminar_por_numero_colegio($numero_colegio);
    }

    my $slot_actual = $self->obtener_slot($indice);
    return 0 unless defined $slot_actual;

    my $nuevo_nodo = nodos::NodoHash->new($tipo_usuario, $datos_usuario);

    if (!defined $slot_actual->{cabeza_lista}) {
        $slot_actual->{cabeza_lista} = $nuevo_nodo;
    } else {
        my $nodo_actual = $slot_actual->{cabeza_lista};

        while (defined $nodo_actual->{next}) {
            $nodo_actual = $nodo_actual->{next};
        }

        $nodo_actual->{next} = $nuevo_nodo;
    }

    $self->{tamanio}++;

    return 1;
}

# Buscar por tipo
sub buscar_por_tipo {
    my ($self, $tipo_usuario) = @_;

    $tipo_usuario = $self->limpiar_texto($tipo_usuario);
    return undef if ($tipo_usuario eq "");

    my $indice = $self->funcion_hash($tipo_usuario);
    return undef if ($indice < 0);

    my $slot_actual = $self->obtener_slot($indice);
    return undef unless defined $slot_actual;

    return $slot_actual->{cabeza_lista};
}

# Contar nodos dentro de un slot
sub contar_nodos_slot {
    my ($self, $slot) = @_;

    my $contador = 0;
    my $nodo_actual = $slot->{cabeza_lista};

    while (defined $nodo_actual) {
        $contador++;
        $nodo_actual = $nodo_actual->{next};
    }

    return $contador;
}

# Contar cuantos usuarios hay por tipo
sub contar_por_tipo {
    my ($self, $tipo_usuario) = @_;

    my $nodo_actual = $self->buscar_por_tipo($tipo_usuario);
    my $contador = 0;

    while (defined $nodo_actual) {
        $contador++;
        $nodo_actual = $nodo_actual->{next};
    }

    return $contador;
}

# Generar reporte Graphviz de la tabla hash
sub generar_graphviz {
    my ($self, $ruta_dot, $ruta_png) = @_;

    open(my $fh, '>:encoding(UTF-8)', $ruta_dot) or die "No se pudo crear el archivo DOT: $!";

    print $fh "digraph TablaHash {\n";
    print $fh "rankdir=LR;\n";
    print $fh "node [shape=plaintext];\n";
    print $fh "graph [fontname=\"Arial\"];\n";

    my $total_usuarios = $self->{tamanio};
    my $slots_ocupados = 0;
    my $slots_vacios = 0;
    my $slots_colision = 0;
    my $total_colisiones = 0;
    my $mayor_carga = 0;

    my $slot_resumen = $self->{cabeza_slots};

    while (defined $slot_resumen) {
        my $cantidad = $self->contar_nodos_slot($slot_resumen);

        if ($cantidad == 0) {
            $slots_vacios++;
        } else {
            $slots_ocupados++;
        }

        if ($cantidad > 1) {
            $slots_colision++;
            $total_colisiones += ($cantidad - 1);
        }

        if ($cantidad > $mayor_carga) {
            $mayor_carga = $cantidad;
        }

        $slot_resumen = $slot_resumen->{next_slot};
    }

    my $ocupacion = 0;
    if ($self->{capacidad} > 0) {
        $ocupacion = ($slots_ocupados / $self->{capacidad}) * 100;
    }

    my $factor_carga = 0;
    if ($self->{capacidad} > 0) {
        $factor_carga = $total_usuarios / $self->{capacidad};
    }

    $ocupacion = sprintf("%.2f", $ocupacion);
    $factor_carga = sprintf("%.2f", $factor_carga);



    print $fh "tabla [label=<\n";
    print $fh "<TABLE BORDER='1' CELLBORDER='1' CELLSPACING='0' CELLPADDING='8'>\n";
    print $fh "<TR><TD COLSPAN='5'><B>ESTADO ACTUAL DE SLOTS</B></TD></TR>\n";
    print $fh "<TR><TD><B>Slot</B></TD><TD><B>Tipo</B></TD><TD><B>Carga</B></TD><TD><B>Usuarios</B></TD></TR>\n";

    my $slot_actual = $self->{cabeza_slots};

    while (defined $slot_actual) {
        my $indice = $slot_actual->{indice};
        my $tipo = $self->obtener_tipo_por_indice($indice);
        my $cantidad = $self->contar_nodos_slot($slot_actual);

        my $usuarios_texto = "";

        if ($cantidad == 0) {
            $usuarios_texto = "Sin usuarios";
        } else {
            my $nodo_actual = $slot_actual->{cabeza_lista};

            while (defined $nodo_actual) {
                my $usuario = $nodo_actual->{datos};
                my $numero = $self->escapar_html($usuario->{numero_colegio});
                my $nombre = $self->escapar_html($usuario->{nombre_completo});
                $usuarios_texto .= "$numero - $nombre<BR/>";
                $nodo_actual = $nodo_actual->{next};
            }
        }

        print $fh "<TR>";
        print $fh "<TD>$indice</TD>";
        print $fh "<TD>$tipo</TD>";
        print $fh "<TD>$cantidad</TD>";
        print $fh "<TD ALIGN='LEFT'>$usuarios_texto</TD>";
        print $fh "</TR>\n";

        $slot_actual = $slot_actual->{next_slot};
    }


    print $fh "</TABLE>\n";
    print $fh ">];\n";
    print $fh "}\n";

    close($fh);

    system("dot -Tpng \"$ruta_dot\" -o \"$ruta_png\"");
}

sub get_tamanio {
    return $_[0]->{tamanio};
}

sub get_capacidad {
    return $_[0]->{capacidad};
}

1;