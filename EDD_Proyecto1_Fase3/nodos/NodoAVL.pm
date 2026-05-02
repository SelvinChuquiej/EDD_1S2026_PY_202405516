package nodos::NodoAVL;
use strict;
use warnings;

sub new {
    my ($class, $datos) = @_;
    my $self = {
        numero_colegio  => $datos->{numero_colegio},
        nombre_completo => $datos->{nombre_completo},
        tipo_usuario => $datos->{tipo_usuario},
        departamento => $datos->{departamento},
        especialidad => $datos->{especialidad},
        contrasena => $datos->{contrasena},

        altura => 1,
        left => undef,
        right => undef,
    };
    bless $self, $class;
    return $self;
}

1;