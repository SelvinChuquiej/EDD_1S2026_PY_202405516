package proveedores::ProveedorCircularLinkedList;

use strict;
use warnings;

use proveedores::NodoProveedor;
use constant Nodo => 'proveedores::NodoProveedor';

sub new {
    my ($class) = @_;
    my $self = { head => undef, tail => undef };
    bless $self, $class;
    return $self;
}

sub is_empty {
    my ($self) = @_;
    return !defined $self->{head};
}

sub agregar {
    my ($self, $data) = @_;

    # evitar duplicados por NIT
    return (0, "Ya existe un proveedor con ese NIT") if $self->buscar_nit($data->{nit});

    my $nodo = Nodo->new($data);

    if ($self->is_empty()) {
        $self->{head} = $nodo;
        $self->{tail} = $nodo;
        $nodo->{next} = $nodo; # circular
        return (1, "Proveedor agregado");
    }

    $nodo->{next} = $self->{head};
    $self->{tail}->{next} = $nodo;
    $self->{tail} = $nodo;

    return (1, "Proveedor agregado");
}

sub buscar_nit {
    my ($self, $nit) = @_;
    return undef if $self->is_empty();

    my $cur = $self->{head};
    do {
        return $cur if $cur->{nit} eq $nit;
        $cur = $cur->{next};
    } while ($cur != $self->{head});

    return undef;
}

sub imprimir {
    my ($self) = @_;
    if ($self->is_empty()) {
        print "No hay proveedores.\n";
        return;
    }

    my $cur = $self->{head};
    do {
        print "NIT: $cur->{nit} | Empresa: $cur->{empresa} | Contacto: $cur->{contacto} | Tel: $cur->{telefono} | Dir: $cur->{direccion}\n";
        print "Entregas:\n";
        $cur->{entregas}->imprimir();
        print "----------------------------------\n";
        $cur = $cur->{next};
    } while ($cur != $self->{head});
}

1;