package json::CargaUsuario;

use strict;
use warnings;

use JSON::PP;

sub cargar_desde_archivo {
    my ($ruta_archivo, $arbol_avl) = @_;
    open(my $fh, '<', $ruta_archivo) or die "No se pudo abrir el archivo '$ruta_archivo': $!\n";
    local $/;
    my $contenido = <$fh>;
    close($fh);

    my $datos_json;
    eval {
        $datos_json = decode_json($contenido);
    };

    if ($@) {
        die "Error de sintaxis al procesar el archivo JSON: $@\n";
    }

    my $usuarios = $datos_json->{usuarios};
    unless ($usuarios && ref($usuarios) eq 'ARRAY') {
        die "El formato del JSON es incorrecto. Falta el arreglo 'usuarios'.\n";
    }

    my $contador = 0;
    foreach my $usuario (@$usuarios) {
        my $especialidad = defined $usuario->{especialidad} ? $usuario->{especialidad} : "";

        my $datos_nodo = {
            numero_colegio  => $usuario->{numero_colegio},
            nombre_completo => $usuario->{nombre_completo},
            tipo_usuario => $usuario->{tipo_usuario},
            departamento => $usuario->{departamento},
            especialidad => $especialidad,
            contrasena => $usuario->{contrasena}
        };

        $arbol_avl->insertar($datos_nodo);
        $contador++;
    }
    return $contador; 
}

1;