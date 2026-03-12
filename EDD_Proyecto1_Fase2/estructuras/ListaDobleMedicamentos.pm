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
    my $code_new = $nuevo_nodo->{code};

    if ($self->find($code_new)) {
        print "Error: El medicamento con código '$code_new' ya existe en la lista.\n";
        return;
    }

    # Verificar si la lista está vacía
    if ($self->is_empty()) {
        $self->{head} = $nuevo_nodo;
        $self->{tail} = $nuevo_nodo;
        return;
    }

    # Insertar antes del head
    if ($code_new lt $self->{head}->{code}) {
        $nuevo_nodo->{next} = $self->{head};
        $self->{head}->{prev} = $nuevo_nodo;
        $self->{head} = $nuevo_nodo;
        return;
    }

    # Insertar después del tail
    if ($code_new gt $self->{tail}->{code}) {
        $nuevo_nodo->{prev} = $self->{tail};
        $self->{tail}->{next} = $nuevo_nodo;
        $self->{tail} = $nuevo_nodo;
        return;
    }

    # Insertar en medio
    my $current = $self->{head}->{next};
    while ($current) {
        if ($code_new lt $current->{code}) {
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
        if ($current->{code} eq $code) {
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
            code       => $current->{code},
            name       => $current->{name},
            principle  => $current->{principle},
            laboratory => $current->{laboratory},
            price      => $current->{price},
            stock      => $current->{stock},
            expiration => $current->{expiration},
            min_level  => $current->{min_level},
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
        my $label = "{ Codigo: $current->{code} | ".
                    "Vence: $current->{expiration} | ".
                    "Nombre: $current->{name} | ".
                    "Stock: $current->{stock} }";
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