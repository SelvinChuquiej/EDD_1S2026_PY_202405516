package estructuras::ListaCircularDobleProveedores; 

use strict;
use warnings;   

use nodos::NodoProveedor;
use constant Nodo => 'nodos::NodoProveedor';

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
sub find {
    my ($self, $nit) = @_;
    return undef if $self->is_empty();
    my $current = $self->{head};
    do {
        return $current if $current->{nit} eq $nit;
        $current = $current->{next};
    } while ($current != $self->{head});
    return undef;
}

sub add {
    my ($self, $data) = @_;
    my $nuevo_nodo = Nodo->new($data);
    my $nit_new = $nuevo_nodo->{nit};
    if ($self->find($nit_new)) {
        print "Error: El proveedor con NIT '$nit_new' ya existe en la lista.\n";
        return;
    }
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

sub delete {
    my ($self, $nit) = @_;
    return if $self->is_empty();
    my $current = $self->{head};
    do {
        if ($current->{nit} eq $nit) {
            if ($self->{head} == $self->{tail}) {
                $self->{head} = undef;
                $self->{tail} = undef;
                return;
            }
            if ($current == $self->{head}) {
                $self->{head} = $current->{next};
                $self->{head}->{prev} = $self->{tail};
                $self->{tail}->{next} = $self->{head};
                return;
            }
            if ($current == $self->{tail}) {
                $self->{tail} = $current->{prev};
                $self->{tail}->{next} = $self->{head};
                $self->{head}->{prev} = $self->{tail};
                return;
            }
            $current->{prev}->{next} = $current->{next};
            $current->{next}->{prev} = $current->{prev};
            return;
        }
        $current = $current->{next};
    } while ($current != $self->{head});
}

sub list {
    my ($self) = @_;
    my @datos;
    return \@datos if $self->is_empty();
    my $current = $self->{head};
    do {
        push @datos, {
            nit => $current->{nit},
            nombre => $current->{nombre},
            telefono => $current->{telefono},
            direccion => $current->{direccion},
            telefono => $current->{telefono},
            fecha_entrega => $current->{fecha_entrega},
            numero_factura => $current->{numero_factura},
            entrega => $current->{entrega},
        };
        $current = $current->{next};
    } while ($current != $self->{head});
    return \@datos;
}

sub print_list {
    my ($self) = @_;
    if ($self->is_empty()) {
        print "Lista vacía\n";
        return;
    }
    my $current = $self->{head};
    do {
        print "NIT: $current->{nit} | Nombre: $current->{nombre} | Factura: $current->{numero_factura}\n";
        $current = $current->{next};
    } while ($current != $self->{head});
}

1;