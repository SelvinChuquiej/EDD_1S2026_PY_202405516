package nodos::NodoB;

use strict;
use warnings;

sub new {
    my ($class, $hoja) = @_;

    my $self = {
        claves => [],  
        datos => [],   
        hijos => [],   
        hoja => $hoja ? 1 : 0,
    };

    bless $self, $class;
    return $self;
}

sub es_hoja{
    my ($self) = @_;
    return $self->{hoja};
}

1;