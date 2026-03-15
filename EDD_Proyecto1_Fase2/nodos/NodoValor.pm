package nodos::NodoValor;
use strict;
use warnings;

sub new {
    my($class, $value) = @_;
    my $self = {
        proveedor => $value->{proveedor},
        fabricante => $value->{fabricante},
        cantidad_total => $value->{cantidad_total},
        up => undef,
        down => undef,
        left => undef,
        right => undef,   
    };
    bless $self, $class;
    return $self;
}

1;