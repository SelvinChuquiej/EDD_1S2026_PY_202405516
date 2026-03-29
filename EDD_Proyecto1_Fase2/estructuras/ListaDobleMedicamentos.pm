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

sub add {
    my ($self, $data) = @_;
    my $nuevo_nodo = Nodo->new($data);
    my $codigo_nuevo = $nuevo_nodo->{codigo};

    if ($self->find($codigo_nuevo)) {
        print "Error: El medicamento con código '$codigo_nuevo' ya existe en la lista.\n";
        return;
    }

    # Verificar si la lista está vacía
    if ($self->is_empty()) {
        $self->{head} = $nuevo_nodo;
        $self->{tail} = $nuevo_nodo;
        return;
    }

    # Insertar antes del head
        if ($codigo_nuevo lt $self->{head}->{codigo}) {
        $nuevo_nodo->{next} = $self->{head};
        $self->{head}->{prev} = $nuevo_nodo;
        $self->{head} = $nuevo_nodo;
        return;
    }

    # Insertar después del tail
        if ($codigo_nuevo gt $self->{tail}->{codigo}) {
        $nuevo_nodo->{prev} = $self->{tail};
        $self->{tail}->{next} = $nuevo_nodo;
        $self->{tail} = $nuevo_nodo;
        return;
    }

    # Insertar en medio
    my $current = $self->{head}->{next};
    while ($current) {
            if ($codigo_nuevo lt $current->{codigo}) {
            my $prev_node = $current->{prev};
            $prev_node->{next} = $nuevo_nodo;
            $nuevo_nodo->{prev} = $prev_node;
            $nuevo_nodo->{next} = $current;
            $current->{prev} = $nuevo_nodo;
            return;
        }
        $current = $current->{next};
    }
}

sub find {
    my ($self, $code) = @_;
    my $current = $self->{head};
    while ($current) {
            if ($current->{codigo} eq $code) {
            return $current;
        }
        $current = $current->{next};
    }
    return undef;
}

sub list {
    my ($self) = @_;
    my @datos;
    my $current = $self->{head};
    while ($current) {
        push @datos, {
            codigo => $current->{codigo},
            nombre => $current->{nombre},
            principio_activo => $current->{principio_activo},
            fabricante => $current->{fabricante},
            precio_unitario => $current->{precio_unitario},
            cantidad => $current->{cantidad},
            fecha_vencimiento => $current->{fecha_vencimiento},
            nivel_minimo => $current->{nivel_minimo},
        };
        $current = $current->{next};
    }
    return \@datos;
}

sub reporte {
    my ($self, $archivo) = @_;
    open(my $fh, '>', $archivo) or die "No se pudo crear el archivo DOT";

    print $fh "digraph G {\n";
    print $fh "rankdir=LR;\n";
    print $fh "node [shape=record, style=filled];\n";

    my $current = $self->{head};

    while ($current) {
        my $color = "lightgreen"; 
        if ($current->{stock} <= $current->{min_level}) {
            $color = "lightcoral";
        }
        elsif ($current->{expiration}) {
            my $today = time;
            my ($y,$m,$d) = split(/-/, $current->{expiration});
            my $exp_time = timelocal(0,0,0,$d,$m-1,$y);
            my $dias = int(($exp_time - $today) / (60*60*24));
            if ($dias >= 0 && $dias <= 5) {
                $color = "khaki";
            }
        }
        my $label = "{ Codigo: $current->{codigo} | ".
                        "Vence: $current->{fecha_vencimiento} | ".
                        "Nombre: $current->{nombre} | ".
                        "Stock: $current->{cantidad} }";
        print $fh "\"$current\" [label=\"$label\", fillcolor=\"$color\"];\n";
        if ($current->{next}) {
            print $fh "\"$current\" -> \"$current->{next}\";\n";
            print $fh "\"$current->{next}\" -> \"$current\";\n";
        }
        $current = $current->{next};
    }

    print $fh "}\n";
    close($fh);
}

1;