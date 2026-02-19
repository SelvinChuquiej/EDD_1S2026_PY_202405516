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
        price => $data->{price},
        stock => $data->{stock},
        expiration => $data->{expiration},
        min_level => $data->{min_level},
        next => undef,
        prev => undef,
    };
    bless $self, $class;
    return $self;
}

1;