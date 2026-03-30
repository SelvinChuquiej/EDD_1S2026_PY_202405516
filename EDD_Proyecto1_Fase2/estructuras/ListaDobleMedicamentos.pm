package estructuras::ListaDobleMedicamentos;

use strict;
use warnings;
use Time::Local;

use nodos::NodoMedicamento;
use constant Nodo => 'nodos::NodoMedicamento';

sub new {
    my ($class) = @_;
    my $self = {
        head => undef,
        tail => undef,
    };
    bless $self, $class;
    return $self;
}

sub is_empty {
    my ($self) = @_;
    return !defined $self->{head};
}

sub agregar {
    my ($self, $data) = @_;

    if (!defined $data->{codigo}) {
        print "Error: el medicamento no trae codigo.\n";
        return;
    }

    if ($self->buscar_codigo($data->{codigo})) {
        print "Error: El codigo '$data->{codigo}' ya existe en el inventario.\n";
        return;
    }

    my $nuevo_nodo = Nodo->new($data);

    if ($self->is_empty()) {
        $self->{head} = $nuevo_nodo;
        $self->{tail} = $nuevo_nodo;
        return;
    }

    my $codigo_nuevo = $nuevo_nodo->{codigo};

    if ($codigo_nuevo lt $self->{head}->{codigo}) {
        $nuevo_nodo->{next} = $self->{head};
        $self->{head}->{prev} = $nuevo_nodo;
        $self->{head} = $nuevo_nodo;
        return;
    }

    if ($codigo_nuevo gt $self->{tail}->{codigo}) {
        $nuevo_nodo->{prev} = $self->{tail};
        $self->{tail}->{next} = $nuevo_nodo;
        $self->{tail} = $nuevo_nodo;
        return;
    }

    my $current = $self->{head}->{next};

    while ($current) {
        if ($codigo_nuevo lt $current->{codigo}) {
            my $prev_node = $current->{prev};

            $nuevo_nodo->{prev} = $prev_node;
            $nuevo_nodo->{next} = $current;

            $prev_node->{next} = $nuevo_nodo;
            $current->{prev} = $nuevo_nodo;
            return;
        }

        $current = $current->{next};
    }
}

sub imprimir {
    my ($self) = @_;
    my $current = $self->{head};
    print "\n-----------Inventario-----------\n";
    while ($current) {
        print "Codigo: $current->{codigo}, ".
              "Nombre: $current->{nombre}, ".
              "Principio Activo: $current->{principio_activo}, ".
              "Fabricante: $current->{fabricante}, ".
              "Cantidad: $current->{cantidad}, ".
              "Fecha de Vencimiento: $current->{fecha_vencimiento}, ".
              "Precio Unitario: $current->{precio_unitario}, ".
              "Nivel Minimo: $current->{nivel_minimo}\n";

        if ($current->{cantidad} < $current->{nivel_minimo}) {
            print "Precaucion: Stock debajo del minimo\n";
        }

        $current = $current->{next};
    }
}

sub buscar_codigo {
    my ($self, $codigo) = @_;
    my $current = $self->{head};

    while ($current) {
        return $current if $current->{codigo} eq $codigo;
        $current = $current->{next};
    }

    return undef;
}

sub eliminar_codigo {
    my ($self, $codigo) = @_;

    my $node = $self->buscar_codigo($codigo);
    return 0 if !$node;

    if ($self->{head} == $node && $self->{tail} == $node) {
        $self->{head} = undef;
        $self->{tail} = undef;
        return 1;
    }

    if ($self->{head} == $node) {
        $self->{head} = $node->{next};
        $self->{head}->{prev} = undef;
        return 1;
    }

    if ($self->{tail} == $node) {
        $self->{tail} = $node->{prev};
        $self->{tail}->{next} = undef;
        return 1;
    }

    my $prev = $node->{prev};
    my $next = $node->{next};

    $prev->{next} = $next;
    $next->{prev} = $prev;

    return 1;
}

sub actualizar_stock {
    my ($self, $codigo, $delta) = @_;
    my $node = $self->buscar_codigo($codigo);

    return (0, "Medicamento no encontrado") if !$node;

    my $cantidad_actual = $node->{cantidad};

    if ($delta < 0 && $cantidad_actual + $delta < 0) {
        return (0, "No hay suficiente stock para realizar la operación");
    }

    $node->{cantidad} = $cantidad_actual + $delta;
    return (1, "Stock actualizado correctamente");
}

sub generar_graphviz {
    my ($self, $archivo_dot, $archivo_png) = @_;
    
    open(my $fh, '>:encoding(UTF-8)', $archivo_dot) or die "No se pudo crear el archivo DOT: $!";

    print $fh "digraph G {\n";
    print $fh "    rankdir=LR;\n";
    print $fh "    node [shape=record, style=filled, fontname=\"Arial\"];\n";
    print $fh "    label=\"Reporte de Medicamentos (Lista Doble Ordenada)\";\n";

    my $current = $self->{head};

    while ($current) {
        my $color = "lightgreen"; 
        if (defined $current->{cantidad} && defined $current->{nivel_minimo}) {
            if ($current->{cantidad} <= $current->{nivel_minimo}) {
                $color = "lightcoral";
            }
        }

        if ($current->{fecha_vencimiento} && $color eq "lightgreen") {
            my $today = time;
            if (my ($y, $m, $d) = $current->{fecha_vencimiento} =~ /^(\d{4})-(\d{2})-(\d{2})$/) {
                my $exp_time = timelocal(0, 0, 0, $d, $m - 1, $y);
                my $dias = int(($exp_time - $today) / (60 * 60 * 24));
                
                if ($dias >= 0 && $dias <= 5) {
                    $color = "khaki"; # Amarillo si vence en 5 días o menos
                }
            }
        }

        my $nom   = $current->{nombre} // "N/A";
        my $cod   = $current->{codigo} // "000";
        my $cant  = $current->{cantidad} // 0;
        my $vence = $current->{fecha_vencimiento} // "N/A";
        my $label = "{ Codigo: $cod | Vence: $vence | Nombre: $nom | Cantidad: $cant }";
        
        print $fh "    \"$current\" [label=\"$label\", fillcolor=\"$color\"];\n";
        
        if ($current->{next}) {
            print $fh "    \"$current\" -> \"$current->{next}\" [dir=both, color=blue];\n";
        }
        $current = $current->{next};
    }

    print $fh "}\n";
    close($fh);
    my $comando = "dot -Gcharset=utf8 -Tpng \"$archivo_dot\" -o \"$archivo_png\"";
    system($comando);
}

1;