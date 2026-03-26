package estructuras::ArbolAVLUsuario;

use strict;
use warnings;
use nodos::NodoAVL;

# Constructor: crea un nuevo árbol AVL vacío
sub new {
    my ($class) = @_;
    my $self = {
        raiz => undef, # raíz del árbol
    };
    bless $self, $class;
    return $self;
}

# Devuelve la altura de un nodo (0 si es indefinido)
sub _altura {
    my ($self, $nodo) = @_;
    return defined $nodo ? $nodo->{altura} : 0;
}

# Devuelve el máximo entre dos valores
sub _max {
    my ($self, $a, $b) = @_;
    return $a > $b ? $a : $b;
}

# Calcula el factor de balance de un nodo
sub _factor_balance {
    my ($self, $nodo) = @_;
    return defined $nodo ? $self->_altura($nodo->{left}) - $self->_altura($nodo->{right}) : 0;
}

# Realiza una rotación simple a la derecha
sub _rotacion_derecha {
    my ($self, $y) = @_;
    my $x = $y->{left};
    my $T2 = $x->{right};

    $x->{right} = $y;
    $y->{left} = $T2;

    # Actualiza alturas
    $y->{altura} = $self->_max($self->_altura($y->{left}), $self->_altura($y->{right})) + 1;
    $x->{altura} = $self->_max($self->_altura($x->{left}), $self->_altura($x->{right})) + 1;

    return $x; 
}

# Realiza una rotación simple a la izquierda
sub _rotacion_izquierda {
    my ($self, $x) = @_;
    my $y = $x->{right};
    my $T2 = $y->{left};

    $y->{left} = $x;
    $x->{right} = $T2;

    # Actualiza alturas
    $x->{altura} = $self->_max($self->_altura($x->{left}), $self->_altura($x->{right})) + 1;
    $y->{altura} = $self->_max($self->_altura($y->{left}), $self->_altura($y->{right})) + 1;

    return $y;
}

# Inserta un nuevo usuario en el árbol AVL
sub insertar {
    my ($self, $datos) = @_;
    $self->{raiz} = $self->_insertar_recursivo($self->{raiz}, $datos);
}

# Inserción recursiva con balanceo AVL
sub _insertar_recursivo {
    my ($self, $nodo, $datos) = @_;

    # Caso base: insertar nuevo nodo
    if (!defined $nodo) {
        return nodos::NodoAVL->new($datos);
    }

    # Inserta a la izquierda o derecha según el número de colegio
    if ($datos->{numero_colegio} lt $nodo->{numero_colegio}) {
        $nodo->{left} = $self->_insertar_recursivo($nodo->{left}, $datos);
    } elsif ($datos->{numero_colegio} gt $nodo->{numero_colegio}) {
        $nodo->{right} = $self->_insertar_recursivo($nodo->{right}, $datos);
    } else {
        return $nodo; # No se permiten duplicados
    }

    # Actualiza la altura del nodo
    $nodo->{altura} = 1 + $self->_max($self->_altura($nodo->{left}), $self->_altura($nodo->{right}));

    # Calcula el factor de balance
    my $balance = $self->_factor_balance($nodo);

    # Rotaciones para mantener el balance AVL
    # Caso Izquierda-Izquierda
    if ($balance > 1 && $datos->{numero_colegio} lt $nodo->{left}->{numero_colegio}) {
        return $self->_rotacion_derecha($nodo);
    }
    # Caso Derecha-Derecha
    if ($balance < -1 && $datos->{numero_colegio} gt $nodo->{right}->{numero_colegio}) {
        return $self->_rotacion_izquierda($nodo);
    }
    # Caso Izquierda-Derecha
    if ($balance > 1 && $datos->{numero_colegio} gt $nodo->{left}->{numero_colegio}) {
        $nodo->{left} = $self->_rotacion_izquierda($nodo->{left});
        return $self->_rotacion_derecha($nodo);
    }
    # Caso Derecha-Izquierda
    if ($balance < -1 && $datos->{numero_colegio} lt $nodo->{right}->{numero_colegio}) {
        $nodo->{right} = $self->_rotacion_derecha($nodo->{right});
        return $self->_rotacion_izquierda($nodo);
    }

    return $nodo;
}

# Busca un usuario por su número de colegio
sub buscar {
    my ($self, $numero_colegio) = @_;
    return $self->_buscar_recursivo($self->{raiz}, $numero_colegio);
}

# Búsqueda recursiva de un usuario por número de colegio
sub _buscar_recursivo {
    my ($self, $nodo, $numero_colegio) = @_;
    return undef if !defined $nodo;
    
    if ($numero_colegio eq $nodo->{numero_colegio}) {
        return $nodo;
    } elsif ($numero_colegio lt $nodo->{numero_colegio}) {
        return $self->_buscar_recursivo($nodo->{left}, $numero_colegio);
    } else {
        return $self->_buscar_recursivo($nodo->{right}, $numero_colegio);
    }
}

sub eliminar {
    my ($self, $numero_colegio) = @_;
    $self->{raiz} = $self->_eliminar_recursivo($self->{raiz}, $numero_colegio);
}

sub _eliminar_recursivo {
    my ($self, $nodo, $numero_colegio) = @_;

    # 1. ELIMINACIÓN ESTÁNDAR TIPO BST
    # Si el árbol está vacío o no encontramos el nodo
    return undef if !defined $nodo;

    # Buscar el nodo por su número de colegio (alfabéticamente)
    if ($numero_colegio lt $nodo->{numero_colegio}) {
        $nodo->{izq} = $self->_eliminar_recursivo($nodo->{izq}, $numero_colegio);
    } 
    elsif ($numero_colegio gt $nodo->{numero_colegio}) {
        $nodo->{der} = $self->_eliminar_recursivo($nodo->{der}, $numero_colegio);
    } 
    else {
        # ¡Encontramos el nodo a eliminar!
        
        # Caso 1 o 2: Un hijo o ningún hijo
        if (!defined $nodo->{izq} || !defined $nodo->{der}) {
            my $temp = defined $nodo->{izq} ? $nodo->{izq} : $nodo->{der};

            # Sin hijos (Nodo Hoja)
            if (!defined $temp) {
                $nodo = undef;
            } 
            # Un hijo (el hijo sube a tomar el lugar del padre)
            else {
                $nodo = $temp;
            }
        } 
        # Caso 3: Dos hijos
        else {
            # Obtener el sucesor in-orden (el menor del subárbol derecho)
            my $temp = $self->_encontrar_minimo($nodo->{der});

            # Copiar TODOS los datos del sucesor al nodo actual [cite: 298]
            $nodo->{numero_colegio}  = $temp->{numero_colegio};
            $nodo->{nombre_completo} = $temp->{nombre_completo};
            $nodo->{tipo_usuario}    = $temp->{tipo_usuario};
            $nodo->{departamento}    = $temp->{departamento};
            $nodo->{especialidad}    = $temp->{especialidad};
            $nodo->{contrasena}      = $temp->{contrasena};

            # Eliminar el sucesor de su posición original
            $nodo->{der} = $self->_eliminar_recursivo($nodo->{der}, $temp->{numero_colegio});
        }
    }

    # Si el árbol tenía solo un nodo y lo borramos, retornamos undef
    return $nodo if !defined $nodo;

    # 2. ACTUALIZAR ALTURA DEL NODO ACTUAL
    $nodo->{altura} = 1 + $self->_max($self->_altura($nodo->{izq}), $self->_altura($nodo->{der}));

    # 3. OBTENER FACTOR DE BALANCE
    my $balance = $self->_factor_balance($nodo);

    # 4. BALANCEAR EL ÁRBOL (ROTACIONES)
    
    # Caso Izquierda Izquierda (LL)
    if ($balance > 1 && $self->_factor_balance($nodo->{izq}) >= 0) {
        return $self->_rotacion_derecha($nodo);
    }
    # Caso Izquierda Derecha (LR)
    if ($balance > 1 && $self->_factor_balance($nodo->{izq}) < 0) {
        $nodo->{izq} = $self->_rotacion_izquierda($nodo->{izq});
        return $self->_rotacion_derecha($nodo);
    }
    # Caso Derecha Derecha (RR)
    if ($balance < -1 && $self->_factor_balance($nodo->{der}) <= 0) {
        return $self->_rotacion_izquierda($nodo);
    }
    # Caso Derecha Izquierda (RL)
    if ($balance < -1 && $self->_factor_balance($nodo->{der}) > 0) {
        $nodo->{der} = $self->_rotacion_derecha($nodo->{der});
        return $self->_rotacion_izquierda($nodo);
    }
    return $nodo;
}

sub _encontrar_minimo {
    my ($self, $nodo) = @_;
    my $actual = $nodo;
    
    # Recorrer lo más a la izquierda posible
    while (defined $actual->{izq}) {
        $actual = $actual->{izq};
    }
    return $actual;
}

1;