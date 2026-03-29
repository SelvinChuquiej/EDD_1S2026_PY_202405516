package estructuras::ListaCircularProveedores; 

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
        print "Aviso: El proveedor con NIT '$nit_new' ya existe. (Falta lógica para agregarle la nueva entrega al historial)\n";
        return;
    }
    
    if ($self->is_empty()) {
        $self->{head} = $nuevo_nodo;
        $self->{tail} = $nuevo_nodo;
        $nuevo_nodo->{next} = $self->{head}; 
    } else {
        $self->{tail}->{next} = $nuevo_nodo;
        $nuevo_nodo->{next} = $self->{head};
        $self->{tail} = $nuevo_nodo;
    }
}

sub delete {
    my ($self, $nit) = @_;
    return if $self->is_empty();
    
    my $current = $self->{head};
    my $previous = $self->{tail}; 
    
    do {
        if ($current->{nit} eq $nit) {
            # Caso 1: Es el único nodo en la lista
            if ($self->{head} == $self->{tail}) {
                $self->{head} = undef;
                $self->{tail} = undef;
                return;
            }
            # Caso 2: Es la cabeza
            if ($current == $self->{head}) {
                $self->{head} = $current->{next};
                $self->{tail}->{next} = $self->{head}; 
                return;
            }
            # Caso 3: Es la cola
            if ($current == $self->{tail}) {
                $self->{tail} = $previous;
                $self->{tail}->{next} = $self->{head};
                return;
            }
            # Caso 4: Está en medio
            $previous->{next} = $current->{next};
            return;
        }
        $previous = $current;
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
            fecha_entrega => $current->{fecha_entrega},
            numero_factura => $current->{numero_factura},
            entrega => $current->{entrega},
        };
        $current = $current->{next};
    } while ($current != $self->{head});
    
    return \@datos;
}

1;