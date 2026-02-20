package proveedores::NodoProveedor;

use strict;
use warnings;

use entregas::EntregaLinkedList;

sub new {
    my ($class, $data) = @_;
    my $self = {
        nit => $data->{nit},
        empresa => $data->{empresa},
        contacto => $data->{contacto},
        telefono => $data->{telefono},
        direccion=> $data->{direccion},
        entregas => entregas::EntregaLinkedList->new(),
        next => undef,
    };
    bless $self, $class;
    return $self;
}

1;