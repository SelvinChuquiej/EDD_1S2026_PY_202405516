package solicitudes::SolicitudCircularDLinkedList;

use strict;
use warnings;

use solicitudes::NodoSolicitud;
use constant Nodo => 'solicitudes::NodoSolicitud';

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
    my $nuevo_nodo = Nodo->new($data);

    #Lista vacía
    if ($self->is_empty()) { 
        $self->{head} = $nuevo_nodo;
        $self->{tail} = $nuevo_nodo;
        $nuevo_nodo->{next} = $nuevo_nodo; 
        $nuevo_nodo->{prev} = $nuevo_nodo;
        return;
    }

    $nuevo_nodo->{prev} = $self->{tail};
    $nuevo_nodo->{next} = $self->{head};

    $self->{tail}->{next} = $nuevo_nodo;
    $self->{head}->{prev} = $nuevo_nodo;

    $self->{tail} = $nuevo_nodo;
}

sub imprimir {
    my ($self) = @_;
    return if $self->is_empty();

    my $current = $self->{head};
    do {
        print "$current->{codigo_med}\n";
        $current = $current->{next};
    } while ($current != $self->{head});
}

sub remove_head {
    my ($self) = @_;
    return undef if $self->is_empty();

    my $removed = $self->{head};
    # Caso: solo 1 nodo
    if ($self->{head} == $self->{tail}) {
        $self->{head} = undef;
        $self->{tail} = undef;

        $removed->{next} = undef;
        $removed->{prev} = undef;

        return $removed;
    }

    # Caso: más de 1 nodo
    my $new_head = $removed->{next};
    $self->{tail}->{next} = $new_head;
    $new_head->{prev} = $self->{tail};
    $self->{head} = $new_head;

    $removed->{next} = undef;
    $removed->{prev} = undef;

    return $removed;
}

sub mirar_head {
    my ($self) = @_;
    return undef if $self->is_empty();
    return $self->{head};
}

sub contar {
    my ($self) = @_;
    return 0 if $self->is_empty();

    my $count = 0;
    my $current = $self->{head};

    do {
        $count++;
        $current = $current->{next};
    } while ($current != $self->{head});

    return $count;
}

sub generar_reporte_dot {
    my ($self, $archivo) = @_;
    return if $self->is_empty();

    open(my $fh, '>', $archivo) or die "No se pudo crear DOT";

    print $fh "digraph G {\n";
    print $fh "rankdir=LR;\n";
    print $fh "splines=true;\n";
    print $fh "node [shape=circle, style=filled, fillcolor=white, fontname=\"Arial\"];\n";

    my $head = $self->{head};
    my $current = $head;

    my $pend_count = 0;
    my $pend_head  = undef;  
    my $pend_prev  = undef;  

    do {
        if (defined $current->{estado} && lc($current->{estado}) eq "pendiente") {
            $pend_count++;
            $pend_head = $current if !defined $pend_head;
            if (defined $pend_prev) {
                print $fh "\"$pend_prev\" -> \"$current\" [color=red, penwidth=2];\n";
                print $fh "\"$current\" -> \"$pend_prev\" [color=black, penwidth=2];\n";
            }

            $pend_prev = $current;
        }
        $current = $current->{next};
    } while ($current != $head);

    print $fh "contador [shape=note, style=filled, fillcolor=lightgrey, label=\"Pendientes: $pend_count\"];\n";

    if ($pend_count == 0) {
        print $fh "}\n";
        close($fh);
        return;
    }
    $current = $head;
    do {
        if (defined $current->{estado} && lc($current->{estado}) eq "pendiente") {

            my $label =
                "Solicitud de\\nReabastecimiento\\n\\n" .
                "No: $current->{id}\\n" .
                "Medicamento: $current->{codigo_med}\\n" .
                "Cantidad: $current->{cantidad}\\n" .
                "Prioridad: $current->{prioridad}";

            print $fh "\"$current\" [label=\"$label\"];\n";
        }
        $current = $current->{next};
    } while ($current != $head);

    print $fh "\"$pend_prev\" -> \"$pend_head\" [color=red, penwidth=2];\n";
    print $fh "\"$pend_head\" -> \"$pend_prev\" [color=black, penwidth=2];\n";

    print $fh "}\n";
    close($fh);
}

1;