package solicitudes::NodoSolicitud;

use strict;
use warnings;

sub new {
    my ($class, $data) = @_;
    my $self = {
        codigo_depto => $data->{codigo_depto},
        codigo_med => $data->{codigo_med},
        cantidad => $data->{cantidad},
        prioridad => $data->{prioridad},
        justificacion => $data->{justificacion},
        fecha_solicitud => $data->{fecha_solicitud},
        estado => $data->{estado},
        next => undef,
        prev => undef,
    };
    bless $self, $class;
    return $self;
}

1;