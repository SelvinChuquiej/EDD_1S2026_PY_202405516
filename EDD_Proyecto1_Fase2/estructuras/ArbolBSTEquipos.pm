
package estructuras::ArbolBSTEquipos;

use strict;
use warnings;
use nodos::NodoBST;

# Constructor: crea un nuevo árbol BST vacío
sub new {
    my ($class) = @_;
    my $self = {
        raiz => undef, # raíz del árbol
    };
    bless $self, $class;
    return $self;
}

# Inserta un nuevo nodo con los datos proporcionados en el árbol
sub insertar {
    my ($self, $datos) = @_;
    $self->{raiz} = $self->_insertar_recursivo($self->{raiz}, $datos);
}

# Inserción recursiva en el árbol BST
sub _insertar_recursivo {
    my ($self, $nodo, $datos) = @_;
    if (!defined $nodo) {
        return nodos::NodoBST->new($datos); # crea un nuevo nodo si está vacío
    }

    if ($datos->{codigo} lt $nodo->{codigo}) {
        $nodo->{left} = $self->_insertar_recursivo($nodo->{left}, $datos);
    } 
    elsif ($datos->{codigo} gt $nodo->{codigo}) {
        $nodo->{right} = $self->_insertar_recursivo($nodo->{right}, $datos);
    }
    return $nodo;
}

# Busca un nodo por su código
sub find {
    my ($self, $codigo) = @_;
    return $self->_find_recursivo($self->{raiz}, $codigo);
}

# Búsqueda recursiva de un nodo por código
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

# Retorna una lista de nodos en recorrido pre-orden
sub pre_orden {
    my ($self) = @_;
    my @resultado;
    $self->_pre_orden_recursivo($self->{raiz}, \@resultado);
    return \@resultado;
}

# Recorrido pre-orden recursivo
sub _pre_orden_recursivo {
    my ($self, $nodo, $resultado) = @_;
    if (defined $nodo) {
        push @$resultado, $nodo;
        $self->_pre_orden_recursivo($nodo->{left}, $resultado);
        $self->_pre_orden_recursivo($nodo->{right}, $resultado);
    }
}

# Retorna una lista de nodos en recorrido in-orden
sub in_orden {
    my ($self) = @_;
    my @resultado;
    $self->_in_orden_recursivo($self->{raiz}, \@resultado);
    return \@resultado;
}

# Recorrido in-orden recursivo
sub _in_orden_recursivo {
    my ($self, $nodo, $resultado) = @_;
    if (defined $nodo) {
        $self->_in_orden_recursivo($nodo->{left}, $resultado);
        push @$resultado, $nodo;
        $self->_in_orden_recursivo($nodo->{right}, $resultado);
    }
}

# Retorna una lista de nodos en recorrido post-orden
sub post_orden {
    my ($self) = @_;
    my @resultado;
    $self->_post_orden_recursivo($self->{raiz}, \@resultado);
    return \@resultado;
}

# Recorrido post-orden recursivo
sub _post_orden_recursivo {
    my ($self, $nodo, $resultado) = @_;
    if (defined $nodo) {
        $self->_post_orden_recursivo($nodo->{left}, $resultado);
        $self->_post_orden_recursivo($nodo->{right}, $resultado);
        push @$resultado, $nodo;
    }
}

# Elimina un nodo por su código
sub eliminar {
    my ($self, $codigo) = @_;
    $self->{raiz} = $self->_eliminar_recursivo($self->{raiz}, $codigo);
}

# Eliminación recursiva de un nodo por código
# Maneja los tres casos: hoja, un hijo, dos hijos
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
            # Copia los datos del sucesor al nodo actual
            $nodo->{codigo} = $temp->{codigo};
            $nodo->{nombre}  = $temp->{nombre};
            $nodo->{fabricante} = $temp->{fabricante};
            $nodo->{precio_unitario} = $temp->{precio_unitario};
            $nodo->{cantidad} = $temp->{cantidad};
            $nodo->{fecha_ingreso} = $temp->{fecha_ingreso};
            $nodo->{nivel_minimo} = $temp->{nivel_minimo};
            # Elimina el sucesor
            $nodo->{right} = $self->_eliminar_recursivo($nodo->{right}, $temp->{codigo});
        }
    }
    return $nodo;
}

# Encuentra el nodo con el valor mínimo (más a la izquierda)
sub _encontrar_minimo {
    my ($self, $nodo) = @_;
    my $actual = $nodo;
    while (defined $actual->{left}) {
        $actual = $actual->{left};
    }
    return $actual;
}

1;