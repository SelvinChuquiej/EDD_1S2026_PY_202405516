package inventario::NodoInventario;

use strict;
use warnings;

sub new {
    my ($class, $data) = @_;
    my $self = {
        code => $data->{code},
        name => $data->{name},
        principle => $data->{principle},
        laboratory => $data->{laboratory},
        stock => $data->{stock},
        expiration => $data->{expiration},
        price => $data->{price},
        min_level => $data->{min_level},
        next => undef,
        prev => undef,
    };
    bless $self, $class;
    return $self;
}

1;