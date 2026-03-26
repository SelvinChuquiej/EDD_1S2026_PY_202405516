package nodos::NodoBST;

use strict;
use warnings;

sub new {
    my ($class, $data) = @_;
    my $self = {
        codigo => $data->{codigo},
        nombre => $data->{nombre},
        fabricante => $data->{fabricante},
        precio_unitario => $data->{precio_unitario},
        cantidad => $data->{cantidad},
        fecha_ingreso => $data->{fecha_ingreso},
        nivel_min => $data->{nivel_min},
        left => undef,
        right => undef,
    };
    bless $self, $class;
    return $self;
}

1;