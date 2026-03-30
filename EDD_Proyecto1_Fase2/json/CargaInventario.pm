package json::CargaInventario;

use strict;
use warnings;
use JSON::PP;

sub cargar_desde_archivo {
    my ($ruta, $bst, $lista_meds, $arbol_b, $lista_prov, $mi_matriz) = @_;

    open(my $fh, '<', $ruta) or die "No se pudo abrir $ruta: $!";
    my $contenido = do { local $/; <$fh> };
    close($fh);

    my $datos;
    eval { $datos = decode_json($contenido); };
    if ($@) {
        return "Error fatal: El archivo no es un formato JSON válido.";
    }

    my $log_advertencias = "";
    my $cont_med = 0;
    my $cont_eq = 0;
    my $cont_sum = 0;
    my $cont_prov = 0;

    foreach my $prov (@{$datos->{proveedor}}) {
        
        my $nombre_proveedor = $prov->{nombre} || "Proveedor Desconocido";

        # --- GESTIÓN DEL PROVEEDOR (Lista Circular) ---
        my $nit = $prov->{nit};
        my $prov_existente = $lista_prov->find($nit);
        
        if ($prov_existente) {
            push @{$prov_existente->{entrega}}, @{$prov->{entrega}};
        } else {
            $lista_prov->add($prov);
            $cont_prov++;
        }

        # --- GESTIÓN DE PRODUCTOS (El Enrutador) ---
        foreach my $item (@{$prov->{entrega}}) {

            my $fabricante = $item->{fabricante} || 'Generico';
            my $cantidad = $item->{cantidad} || 0;
            if (defined $mi_matriz) {
                $mi_matriz->add($nombre_proveedor, $fabricante, $cantidad);
            }

            my $codigo = $item->{codigo} || 'SIN_CODIGO';
            if (!defined $item->{cantidad} || $item->{cantidad} <= 0) {
                $log_advertencias .= "Ignorado (Cantidad inválida): Ítem $codigo\n";
                next;
            }
            my $fecha_invalida = 0;
            foreach my $campo_fecha ('fecha_vencimiento', 'fecha_ingreso') {
                if (defined $item->{$campo_fecha} && $item->{$campo_fecha} !~ /^\d{4}-\d{2}-\d{2}$/) {
                    $fecha_invalida = 1;
                    last;
                }
            }
            if ($fecha_invalida) {
                $log_advertencias .= "Ignorado (Fecha inválida): Ítem $codigo\n";
                next;
            }

            my $tipo = $item->{tipo} || '';
            
            if ($tipo eq 'MEDICAMENTO') {
                $lista_meds->agregar($item);
                $cont_med++;
            } 
            elsif ($tipo eq 'EQUIPO') {
                $bst->insertar($item);
                $cont_eq++;
            } 
            elsif ($tipo eq 'SUMINISTRO') {
                $arbol_b->insertar($item);
                $cont_sum++;
            } 
            else {
                $log_advertencias .= "Ignorado (Tipo desconocido '$tipo'): Item $codigo\n";
            }
        }
    }

    my $resumen = "Carga de Inventario Finalizada:\n\n" .
                  "Proveedores nuevos: $cont_prov\n" .
                  "Medicamentos (Lista Doble): $cont_med\n" .
                  "Equipos (Arbol BST): $cont_eq\n" .
                  "Suministros (Arbol B): $cont_sum\n"; 
    
    if ($log_advertencias ne "") {
        $resumen .= "\n--- Advertencias de Validacion ---\n$log_advertencias";
    }
    
    return $resumen;
}

1;