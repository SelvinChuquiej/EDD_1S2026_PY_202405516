package nodos::NodoMedicamento;

use strict;
use warnings;

sub new {
    my ($class, $data) = @_;
    my $self = {
        codigo => $data->{codigo},
        nombre => $data->{nombre},
        principio_activo => $data->{principio_activo},
        fabricante => $data->{fabricante},
        precio_unitario => $data->{precio_unitario},
        cantidad => $data->{cantidad},
        fecha_vencimiento => $data->{fecha_vencimiento},
        nivel_minimo => $data->{nivel_minimo},
        next => undef,
        prev => undef,
    };
    bless $self, $class;
    return $self;
}

1;