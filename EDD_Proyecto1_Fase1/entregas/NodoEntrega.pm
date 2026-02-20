package entregas::NodoEntrega;

use strict;
use warnings;

sub new {
    my ($class, $data) = @_;
    my $self = {
        fecha => $data->{fecha},
        factura => $data->{factura},
        codigo_med => $data->{codigo_med},
        cantidad => $data->{cantidad},
        next => undef,
    };
    bless $self, $class;
    return $self;
}

1;