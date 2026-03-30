
package estructuras::ArbolBSTEquipos;

use strict;
use warnings;
use nodos::NodoBST;

sub new {
    my ($class) = @_;
    my $self = {
        raiz => undef, # raíz del árbol
    };
    bless $self, $class;
    return $self;
}

sub insertar {
    my ($self, $datos) = @_;
    $self->{raiz} = $self->_insertar_recursivo($self->{raiz}, $datos);
}

sub _insertar_recursivo {
    my ($self, $nodo, $datos) = @_;
    if (!defined $nodo) {
        return nodos::NodoBST->new($datos);
    }

    if ($datos->{codigo} lt $nodo->{codigo}) {
        $nodo->{left} = $self->_insertar_recursivo($nodo->{left}, $datos);
    } 
    elsif ($datos->{codigo} gt $nodo->{codigo}) {
        $nodo->{right} = $self->_insertar_recursivo($nodo->{right}, $datos);
    }
    return $nodo;
}

sub find {
    my ($self, $codigo) = @_;
    return $self->_find_recursivo($self->{raiz}, $codigo);
}

sub _find_recursivo {
    my ($self, $nodo, $codigo) = @_;
    return undef if !defined $nodo; 
    if ($codigo eq $nodo->{codigo}) {
        return $nodo;
    } elsif ($codigo lt $nodo->{codigo}) {
        return $self->_find_recursivo($nodo->{left}, $codigo);
    } else {
        return $self->_find_recursivo($nodo->{right}, $codigo);
    }
}

sub pre_orden {
    my ($self) = @_;
    my @resultado;
    $self->_pre_orden_recursivo($self->{raiz}, \@resultado);
    return \@resultado;
}

sub _pre_orden_recursivo {
    my ($self, $nodo, $resultado) = @_;
    if (defined $nodo) {
        push @$resultado, $nodo;
        $self->_pre_orden_recursivo($nodo->{left}, $resultado);
        $self->_pre_orden_recursivo($nodo->{right}, $resultado);
    }
}

sub in_orden {
    my ($self) = @_;
    my @resultado;
    $self->_in_orden_recursivo($self->{raiz}, \@resultado);
    return \@resultado;
}

sub _in_orden_recursivo {
    my ($self, $nodo, $resultado) = @_;
    if (defined $nodo) {
        $self->_in_orden_recursivo($nodo->{left}, $resultado);
        push @$resultado, $nodo;
        $self->_in_orden_recursivo($nodo->{right}, $resultado);
    }
}

sub post_orden {
    my ($self) = @_;
    my @resultado;
    $self->_post_orden_recursivo($self->{raiz}, \@resultado);
    return \@resultado;
}

sub _post_orden_recursivo {
    my ($self, $nodo, $resultado) = @_;
    if (defined $nodo) {
        $self->_post_orden_recursivo($nodo->{left}, $resultado);
        $self->_post_orden_recursivo($nodo->{right}, $resultado);
        push @$resultado, $nodo;
    }
}

sub eliminar {
    my ($self, $codigo) = @_;
    $self->{raiz} = $self->_eliminar_recursivo($self->{raiz}, $codigo);
}

sub _eliminar_recursivo {
    my ($self, $nodo, $codigo) = @_;
    return undef if !defined $nodo; 
    if ($codigo lt $nodo->{codigo}) {
        $nodo->{left} = $self->_eliminar_recursivo($nodo->{left}, $codigo);
    } 
    elsif ($codigo gt $nodo->{codigo}) {
        $nodo->{right} = $self->_eliminar_recursivo($nodo->{right}, $codigo);
    } 
    else {
        # Caso 1: sin hijos
        if (!defined $nodo->{left} && !defined $nodo->{right}) {
            return undef;
        }
        # Caso 2: un solo hijo derecho
        elsif (!defined $nodo->{left}) {
            return $nodo->{right};
        }
        # Caso 3: un solo hijo izquierdo
        elsif (!defined $nodo->{right}) {
            return $nodo->{left};
        }
        # Caso 4: dos hijos
        else {
            my $temp = $self->_encontrar_minimo($nodo->{right});
            $nodo->{codigo} = $temp->{codigo};
            $nodo->{nombre}  = $temp->{nombre};
            $nodo->{fabricante} = $temp->{fabricante};
            $nodo->{precio_unitario} = $temp->{precio_unitario};
            $nodo->{cantidad} = $temp->{cantidad};
            $nodo->{fecha_ingreso} = $temp->{fecha_ingreso};
            $nodo->{nivel_minimo} = $temp->{nivel_minimo};
            $nodo->{right} = $self->_eliminar_recursivo($nodo->{right}, $temp->{codigo});
        }
    }
    return $nodo;
}

sub _encontrar_minimo {
    my ($self, $nodo) = @_;
    my $actual = $nodo;
    while (defined $actual->{left}) {
        $actual = $actual->{left};
    }
    return $actual;
}

sub generar_graphviz {
    my ($self, $ruta_dot, $ruta_png) = @_;
    
    open(my $fh, '>', $ruta_dot) or die "No se pudo crear $ruta_dot: $!";
    
    print $fh "digraph BST_Equipos {\n";
    print $fh "    node [shape=record, style=filled, fontname=\"Arial\"];\n";
    print $fh "    edge [fontname=\"Arial\", fontsize=10];\n";
    print $fh "    label=\"Inventario de Equipos Médicos (Árbol BST)\";\n";
    print $fh "    labelloc=\"t\";\n";
    
    if (defined $self->{raiz}) {
        $self->_escribir_nodos_dot($self->{raiz}, $fh, 1);
    } else {
        print $fh "    \"Vacio\" [label=\"Árbol Vacío\"];\n";
    }
    
    print $fh "}\n";
    close($fh);
    
    system("dot -Tpng \"$ruta_dot\" -o \"$ruta_png\"");
}

sub _escribir_nodos_dot {
    my ($self, $nodo, $fh, $es_raiz) = @_;
    return unless defined $nodo;
    
    my $cod = $nodo->{codigo};
    my $nom = $nodo->{nombre};
    my $mar = $nodo->{fabricante} || "N/A";
    my $can = $nodo->{cantidad};
    my $vid = $nodo->{vida_util}  || "N/A"; # O usas fecha_ingreso si no tienes vida útil
    
    my $color = "white"; # Nodos internos normales
    if ($es_raiz) {
        $color = "lightblue"; # La Raíz
    } elsif (!defined $nodo->{left} && !defined $nodo->{right}) {
        $color = "lightgreen"; # Las Hojas (sin hijos)
    }
    
    my $label = "{ Código: $cod | Nombre: $nom | Marca: $mar | Cantidad: $can | Vida Útil: $vid }";
    
    print $fh "    \"$cod\" [label=\"$label\", fillcolor=\"$color\"];\n";
    
    if (defined $nodo->{left}) {
        my $cod_izq = $nodo->{left}->{codigo};
        print $fh "    \"$cod\" -> \"$cod_izq\" [label=\" Izq\", color=\"blue\", fontcolor=\"blue\"];\n";
        $self->_escribir_nodos_dot($nodo->{left}, $fh, 0);
    }
    
    if (defined $nodo->{right}) {
        my $cod_der = $nodo->{right}->{codigo};
        print $fh "    \"$cod\" -> \"$cod_der\" [label=\" Der\", color=\"red\", fontcolor=\"red\"];\n";
        $self->_escribir_nodos_dot($nodo->{right}, $fh, 0);
    }
}

1;