package json::CargaUsuario;

use strict;
use warnings;

use JSON::PP;

sub cargar_desde_archivo {
    my ($ruta_archivo, $context) = @_;
    
    my $arbol_avl = $context->{avl_usuarios};
    my $tabla_hash = $context->{tabla_hash};
    my $grafo = $context->{grafo};

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
            contrasena => $usuario->{contrasena},
            solicitudes_pendientes => []
        };

        $arbol_avl->insertar($datos_nodo);
        if (defined $grafo) {
            $grafo->insertar_vertice($datos_nodo->{numero_colegio}, $datos_nodo);
        }
        if (defined $tabla_hash) {
            $tabla_hash->insertar($usuario->{tipo_usuario}, $datos_nodo);
        }
        $contador++;
    } 
    my $resumen = "Carga de Usuarios Finalizada\n\nUsuarios cargados: $contador";
    return $resumen; 
}

1;