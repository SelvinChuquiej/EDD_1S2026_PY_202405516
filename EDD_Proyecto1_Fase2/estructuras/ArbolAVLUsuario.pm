package estructuras::ArbolAVLUsuario;

use strict;
use warnings;
use nodos::NodoAVL;

sub new {
    my ($class) = @_;
    my $self = {
        raiz => undef,
    };
    bless $self, $class;
    return $self;
}

sub _altura {
    my ($self, $nodo) = @_;
    return defined $nodo ? $nodo->{altura} : 0;
}

sub _max {
    my ($self, $a, $b) = @_;
    return $a > $b ? $a : $b;
}

sub _factor_balance {
    my ($self, $nodo) = @_;
    return defined $nodo ? $self->_altura($nodo->{left}) - $self->_altura($nodo->{right}) : 0;
}

sub _rotacion_derecha {
    my ($self, $y) = @_;
    my $x = $y->{left};
    my $T2 = $x->{right};

    $x->{right} = $y;
    $y->{left} = $T2;

    $y->{altura} = $self->_max($self->_altura($y->{left}), $self->_altura($y->{right})) + 1;
    $x->{altura} = $self->_max($self->_altura($x->{left}), $self->_altura($x->{right})) + 1;

    return $x; 
}

sub _rotacion_izquierda {
    my ($self, $x) = @_;
    my $y = $x->{right};
    my $T2 = $y->{left};

    $y->{left} = $x;
    $x->{right} = $T2;

    $x->{altura} = $self->_max($self->_altura($x->{left}), $self->_altura($x->{right})) + 1;
    $y->{altura} = $self->_max($self->_altura($y->{left}), $self->_altura($y->{right})) + 1;

    return $y;
}

sub insertar {
    my ($self, $datos) = @_;
    $self->{raiz} = $self->_insertar_recursivo($self->{raiz}, $datos);
}

sub _insertar_recursivo {
    my ($self, $nodo, $datos) = @_;

    if (!defined $nodo) {
        return nodos::NodoAVL->new($datos);
    }

    if ($datos->{numero_colegio} lt $nodo->{numero_colegio}) {
        $nodo->{left} = $self->_insertar_recursivo($nodo->{left}, $datos);
    } elsif ($datos->{numero_colegio} gt $nodo->{numero_colegio}) {
        $nodo->{right} = $self->_insertar_recursivo($nodo->{right}, $datos);
    } else {
        return $nodo;
    }

    $nodo->{altura} = 1 + $self->_max($self->_altura($nodo->{left}), $self->_altura($nodo->{right}));
    
    my $balance = $self->_factor_balance($nodo);

    # Casos de Rotación
    # 1. Izquierda-Izquierda
    if ($balance > 1 && $datos->{numero_colegio} lt $nodo->{left}->{numero_colegio}) {
        return $self->_rotacion_derecha($nodo);
    }
    # 2. Derecha-Derecha
    if ($balance < -1 && $datos->{numero_colegio} gt $nodo->{right}->{numero_colegio}) {
        return $self->_rotacion_izquierda($nodo);
    }
    # 3. Izquierda-Derecha
    if ($balance > 1 && $datos->{numero_colegio} gt $nodo->{left}->{numero_colegio}) {
        $nodo->{left} = $self->_rotacion_izquierda($nodo->{left});
        return $self->_rotacion_derecha($nodo);
    }
    # 4. Derecha-Izquierda
    if ($balance < -1 && $datos->{numero_colegio} lt $nodo->{right}->{numero_colegio}) {
        $nodo->{right} = $self->_rotacion_derecha($nodo->{right});
        return $self->_rotacion_izquierda($nodo);
    }

    return $nodo;
}

sub buscar {
    my ($self, $numero_colegio) = @_;
    return $self->_buscar_recursivo($self->{raiz}, $numero_colegio);
}

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

sub pre_orden {
    my ($self) = @_;
    my @resultado;
    $self->_pre_orden_recursivo($self->{raiz}, \@resultado);
    return \@resultado;
}

sub _pre_orden_recursivo {
    my ($self, $nodo, $resultado) = @_;
    if (defined $nodo) {
        push @$resultado, $nodo; # Raíz
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
    my ($self, $numero_colegio) = @_;
    $self->{raiz} = $self->_eliminar_recursivo($self->{raiz}, $numero_colegio);
}

sub _eliminar_recursivo {
    my ($self, $nodo, $numero_colegio) = @_;

    return undef if !defined $nodo;

    if ($numero_colegio lt $nodo->{numero_colegio}) {
        $nodo->{left} = $self->_eliminar_recursivo($nodo->{left}, $numero_colegio);
    } 
    elsif ($numero_colegio gt $nodo->{numero_colegio}) {
        $nodo->{right} = $self->_eliminar_recursivo($nodo->{right}, $numero_colegio);
    } 
    else {
        if (!defined $nodo->{left} || !defined $nodo->{right}) {
            my $temp = defined $nodo->{left} ? $nodo->{left} : $nodo->{right};
            if (!defined $temp) {
                $nodo = undef;
            } else {
                $nodo = $temp;
            }
        } else {
            my $temp = $self->_encontrar_minimo($nodo->{right});
            $nodo->{numero_colegio}  = $temp->{numero_colegio};
            $nodo->{nombre_completo} = $temp->{nombre_completo};
            $nodo->{tipo_usuario}    = $temp->{tipo_usuario};
            $nodo->{departamento}    = $temp->{departamento};
            $nodo->{especialidad}    = $temp->{especialidad};
            $nodo->{contrasena}      = $temp->{contrasena};
            $nodo->{right} = $self->_eliminar_recursivo($nodo->{right}, $temp->{numero_colegio});
        }
    }

    return $nodo if !defined $nodo;

    $nodo->{altura} = 1 + $self->_max($self->_altura($nodo->{left}), $self->_altura($nodo->{right}));
    my $balance = $self->_factor_balance($nodo);

    if ($balance > 1 && $self->_factor_balance($nodo->{left}) >= 0) {
        return $self->_rotacion_derecha($nodo);
    }
    if ($balance > 1 && $self->_factor_balance($nodo->{left}) < 0) {
        $nodo->{left} = $self->_rotacion_izquierda($nodo->{left});
        return $self->_rotacion_derecha($nodo);
    }
    if ($balance < -1 && $self->_factor_balance($nodo->{right}) <= 0) {
        return $self->_rotacion_izquierda($nodo);
    }
    if ($balance < -1 && $self->_factor_balance($nodo->{right}) > 0) {
        $nodo->{right} = $self->_rotacion_derecha($nodo->{right});
        return $self->_rotacion_izquierda($nodo);
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
    
    open(my $fh, '>:encoding(UTF-8)', $ruta_dot) or die "No se pudo crear $ruta_dot: $!";
    
    print $fh "digraph AVL_Usuarios {\n";
    print $fh "    node [shape=circle, style=filled, fillcolor=lightyellow, fontname=\"Arial\"];\n";
    print $fh "    edge [fontname=\"Arial\", fontsize=10];\n";
    print $fh "    label=\"Usuarios Registrados (Árbol AVL)\";\n";
    print $fh "    labelloc=\"t\";\n";
    
    # Llamamos a la función recursiva
    if (defined $self->{raiz}) {
        $self->_escribir_nodos_dot($self->{raiz}, $fh);
    } else {
        print $fh "    \"Vacio\" [label=\"Árbol Vacío\"];\n";
    }
    
    print $fh "}\n";
    close($fh);
    
    system("dot -Gcharset=utf8 -Tpng \"$ruta_dot\" -o \"$ruta_png\"");
}

sub _escribir_nodos_dot {
    my ($self, $nodo, $fh) = @_;
    return unless defined $nodo;
    
    my $col = $nodo->{numero_colegio}  || "N/A";
    my $nom = $nodo->{nombre_completo} || "N/A";
    my $tip = $nodo->{tipo_usuario}    || "N/A";
    my $dep = $nodo->{departamento}    || "N/A";
    
    my $label = "$col\\n$nom\\n$tip\\n$dep";
    
    print $fh "    \"$col\" [label=\"$label\"];\n";
    
    if (defined $nodo->{left}) {
        my $col_izq = $nodo->{left}->{numero_colegio};
        print $fh "    \"$col\" -> \"$col_izq\" [label=\" Izq\", color=\"blue\", fontcolor=\"blue\"];\n";
        $self->_escribir_nodos_dot($nodo->{left}, $fh);
    }
    
    if (defined $nodo->{right}) {
        my $col_der = $nodo->{right}->{numero_colegio};
        print $fh "    \"$col\" -> \"$col_der\" [label=\" Der\", color=\"red\", fontcolor=\"red\"];\n";
        $self->_escribir_nodos_dot($nodo->{right}, $fh);
    }
}

1;