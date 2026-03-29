package util::permisos;

use strict;
use warnings;

my %tabla_permisos = (
    'DEP-ADM' => {
        tipos  => ['TIPO-05'],
        acceso => 'TOTAL'
    },
    'DEP-MED' => {
        tipos  => ['TIPO-01', 'TIPO-03'],
        acceso => 'MEDICAMENTOS + SUMINISTROS'
    },
    'DEP-CIR' => {
        tipos  => ['TIPO-02', 'TIPO-03'],
        acceso => 'EQUIPO + SUMINISTROS'
    },
    'DEP-LAB' => {
        tipos  => ['TIPO-04'],
        acceso => 'EQUIPO'
    },
    'DEP-FAR' => {
        tipos  => ['TIPO-03'],
        acceso => 'MEDICAMENTOS'
    }
);

sub validar_registro {
    my ($depto, $tipo) = @_;
    return 0 unless exists $tabla_permisos{$depto};
    foreach my $tipo_permitido (@{$tabla_permisos{$depto}{tipos}}) {
        return 1 if $tipo_permitido eq $tipo; 
    }
    return 0; 
}

sub obtener_acceso {
    my ($depto) = @_;
    return exists $tabla_permisos{$depto} ? $tabla_permisos{$depto}{acceso} : 'NINGUNO';
}

1;