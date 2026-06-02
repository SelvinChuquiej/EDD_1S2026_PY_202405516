package nodos::NodoLista;

use strict;
use warnings;

sub new {
    my ($class, $data) = @_;
    my $self = {
        data => $data,
        siguiente => undef,
    };
    bless $self, $class;
    return $self;
}

sub get_data {
    return $_[0]->{data};
}

sub set_data {
    my ($self, $nuevo_data) = @_;
    $self->{data} = $nuevo_data;
}

sub get_siguiente {
    return $_[0]->{siguiente};
}

sub set_siguiente {
    my ($self, $nodo_lista) = @_;
    $self->{siguiente} = $nodo_lista;
}

1;