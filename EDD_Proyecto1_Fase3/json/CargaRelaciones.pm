package json::CargaRelaciones;

use strict;
use warnings;
use JSON::PP;

sub cargar_desde_archivo {
    my ($ruta_archivo, $context) = @_;
    
    my $mi_avl = $context->{avl_usuarios};
    my $mi_grafo = $context->{grafo};

    open(my $fh, '<', $ruta_archivo) or die "No se pudo abrir el archivo '$ruta_archivo': $!\n";
    local $/;
    my $contenido = <$fh>;
    close($fh);

    my $datos_json;
    eval { $datos_json = decode_json($contenido); };
    if ($@) { die "Error de sintaxis al procesar el archivo JSON: $@\n"; }

    my $relaciones;
    
    if (ref($datos_json) eq 'ARRAY') {
        $relaciones = $datos_json;
    }
    
    unless ($relaciones && ref($relaciones) eq 'ARRAY') {
        die "El formato del JSON es incorrecto. Falta el arreglo 'relaciones'.\n";
    }

    my $cont_activas = 0;
    my $cont_pendientes = 0;
    my $cont_rechazadas = 0;

    foreach my $relacion (@$relaciones) {
        my $origen = $relacion->{solicitante} || $relacion->{numero_colegio_1}; 
        my $destino = $relacion->{receptor} || $relacion->{numero_colegio_2};
        my $estado = uc($relacion->{estado});

        if ($estado eq 'ACTIVA') {
            my $nodo_origen = $mi_avl->buscar($origen);
            my $nodo_destino = $mi_avl->buscar($destino);

            my $nombre_orig = defined $nodo_origen ? $nodo_origen->{nombre_completo} : $origen;
            my $nombre_dest = defined $nodo_destino ? $nodo_destino->{nombre_completo} : $destino;

            my $depto_orig = (defined $nodo_origen && defined $nodo_origen->{departamento} && $nodo_origen->{departamento} ne "" && lc($nodo_origen->{departamento}) ne "null") ? $nodo_origen->{departamento} : "Pendiente";
            my $depto_dest = (defined $nodo_destino && defined $nodo_destino->{departamento} && $nodo_destino->{departamento} ne "" && lc($nodo_destino->{departamento}) ne "null") ? $nodo_destino->{departamento} : "Pendiente";

            my $datos_orig = { nombre => $nombre_orig, departamento => $depto_orig };
            my $datos_dest = { nombre => $nombre_dest, departamento => $depto_dest };

            $mi_grafo->insertar_vertice($origen, $datos_orig);
            $mi_grafo->insertar_vertice($destino, $datos_dest);

            $mi_grafo->insertar_arista($origen, $destino);
            $cont_activas++;
            
        } elsif ($estado eq 'PENDIENTE') {
            my $nodo_destino = $mi_avl->buscar($destino);
            
            if (defined $nodo_destino) {
                push @{$nodo_destino->{solicitudes_pendientes}}, $origen;
                $cont_pendientes++;
            } else {
                print "Advertencia: El usuario receptor $destino no existe en el sistema.\n";
            }
            
        } elsif ($estado eq 'RECHAZADA') {
            $cont_rechazadas++;
        }
    } 
    
    my $resumen = "Carga de Relaciones Finalizada\n\n" .
                  "Activas (Agregadas al Grafo): $cont_activas\n" .
                  "Pendientes (Encoladas): $cont_pendientes\n" .
                  "Rechazadas (Ignoradas): $cont_rechazadas";
                  
    return $resumen; 
}

1;