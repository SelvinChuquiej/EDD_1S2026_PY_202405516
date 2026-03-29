package nodos::NodoProveedor;

use strict;
use warnings;

sub new {
    my ($class, $data) = @_;
    my $self = {
        nit => $data->{nit},
        nombre => $data->{nombre},
        direccion => $data->{direccion},
        telefono => $data->{telefono},
        fecha_entrega => $data->{fecha_entrega},
        numero_factura => $data->{numero_factura},
        entrega => $data->{entrega},
        next => undef
    };
    bless $self, $class;
    return $self;
}

1;