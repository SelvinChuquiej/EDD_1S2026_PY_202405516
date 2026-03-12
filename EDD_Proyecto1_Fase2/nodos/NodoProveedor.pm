package nodos::NodoProveedor;

use strict;
use warnings;

sub new {
    my ($class, $data) = @_;
    my $self = {
        nit => $data->{nit},
        nombre => $data->{nombre},
        direccion => $data->{direccion},
        fecha_entrega => $data->{fecha_entrega},
        numero_factura => $data->{numero_factura},
        entregas => $data->{entregas} || [],
        next => undef,
        prev => undef,
    };
    bless $self, $class;
    return $self;
}

1;