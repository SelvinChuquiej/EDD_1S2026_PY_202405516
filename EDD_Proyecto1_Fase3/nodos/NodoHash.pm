package nodos::NodoHash;

use strict;
use warnings;

sub new {
    my ($class, $tipo_usuario, $datos) = @_;

    my $self = {
        tipo_usuario => $tipo_usuario,
        datos => $datos,
        next => undef
    };

    bless $self, $class;
    return $self;
}

sub get_tipo_usuario {
    return $_[0]->{tipo_usuario};
}

sub get_datos {
    return $_[0]->{datos};
}

sub get_next {
    return $_[0]->{next};
}

sub set_next {
    $_[0]->{next} = $_[1];
}

1;