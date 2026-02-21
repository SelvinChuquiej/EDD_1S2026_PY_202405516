package matriz::NodoValor;
use strict;
use warnings;

sub new {
    my ($class, $data) = @_;
    my $self = {
        laboratorio => $data->{laboratorio},
        medicamento => $data->{medicamento},   
        codigo_med => $data->{codigo_med},    
        precio => $data->{precio},
        principio_activo => $data->{principio_activo},

        up => undef,
        down => undef,
        left => undef,
        right => undef,
    };
    bless $self, $class;
    return $self;
}

1;