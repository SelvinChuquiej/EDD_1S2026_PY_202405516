package estructuras::ArbolBInventario;

use strict;
use warnings;
use nodos::NodoB;

sub new {
    my ($class) = @_;

    my $self = {
        raiz => nodos::NodoB->new(1),
        t => 2, 
    };

    bless $self, $class;
    return $self;
}

sub buscar {
    my ($self, $codigo) = @_;
    return _buscar_en_nodo($self->{raiz}, $codigo);
}

sub _buscar_en_nodo {
    my ($nodo, $codigo) = @_;

    my $i = 0;
    while ($i < @{$nodo->{claves}} && $codigo gt $nodo->{claves}[$i]) {
        $i++;
    }

    if ($i < @{$nodo->{claves}} && $codigo eq $nodo->{claves}[$i]) {
        return $nodo->{datos}[$i];
    }

    return undef if $nodo->{hoja};

    return _buscar_en_nodo($nodo->{hijos}[$i], $codigo);
}

sub insertar {
    my ($self, $dato) = @_;

    my $codigo = $dato->{codigo};

    if ($self->buscar($codigo)) {
        warn "Ya existe un suministro con codigo $codigo\n";
        return 0;
    }

    my $raiz = $self->{raiz};

    if (@{$raiz->{claves}} == 3) {
        my $nueva_raiz = nodos::NodoB->new(0);
        push @{$nueva_raiz->{hijos}}, $raiz;

        _dividir_hijo($self, $nueva_raiz, 0);
        $self->{raiz} = $nueva_raiz;
    }

    _insertar_no_lleno($self, $self->{raiz}, $dato);
    return 1;
}

sub _insertar_no_lleno {
    my ($self, $nodo, $dato) = @_;
    my $codigo = $dato->{codigo};

    my $i = @{$nodo->{claves}} - 1;

    if ($nodo->{hoja}) {
        push @{$nodo->{claves}}, undef;
        push @{$nodo->{datos}},  undef;

        while ($i >= 0 && $codigo lt $nodo->{claves}[$i]) {
            $nodo->{claves}[$i + 1] = $nodo->{claves}[$i];
            $nodo->{datos}[$i + 1]  = $nodo->{datos}[$i];
            $i--;
        }

        $nodo->{claves}[$i + 1] = $codigo;
        $nodo->{datos}[$i + 1]  = $dato;
    } else {
        while ($i >= 0 && $codigo lt $nodo->{claves}[$i]) {
            $i--;
        }

        $i++;

        if (@{$nodo->{hijos}[$i]->{claves}} == 3) {
            _dividir_hijo($self, $nodo, $i);

            if ($codigo gt $nodo->{claves}[$i]) {
                $i++;
            }
        }

        _insertar_no_lleno($self, $nodo->{hijos}[$i], $dato);
    }
}

sub _dividir_hijo {
    my ($self, $padre, $indice_hijo) = @_;

    my $hijo_lleno = $padre->{hijos}[$indice_hijo];
    my $nuevo_derecho = nodos::NodoB->new($hijo_lleno->{hoja});

    my $clave_media = $hijo_lleno->{claves}[1];
    my $dato_medio  = $hijo_lleno->{datos}[1];

    push @{$nuevo_derecho->{claves}}, $hijo_lleno->{claves}[2];
    push @{$nuevo_derecho->{datos}},  $hijo_lleno->{datos}[2];

    $#{$hijo_lleno->{claves}} = 0;
    $#{$hijo_lleno->{datos}}  = 0;

    if (!$hijo_lleno->{hoja}) {
        push @{$nuevo_derecho->{hijos}}, $hijo_lleno->{hijos}[2], $hijo_lleno->{hijos}[3];
        $#{$hijo_lleno->{hijos}} = 1;
    }

    splice @{$padre->{hijos}},  $indice_hijo + 1, 0, $nuevo_derecho;
    splice @{$padre->{claves}}, $indice_hijo,     0, $clave_media;
    splice @{$padre->{datos}},  $indice_hijo,     0, $dato_medio;
}

sub inorden {
    my ($self) = @_;
    my @resultado;
    _inorden_nodo($self->{raiz}, \@resultado);
    return \@resultado;
}

sub _inorden_nodo {
    my ($nodo, $resultado) = @_;

    my $n = scalar @{$nodo->{claves}};

    for (my $i = 0; $i < $n; $i++) {
        if (!$nodo->{hoja}) {
            _inorden_nodo($nodo->{hijos}[$i], $resultado);
        }
        push @$resultado, $nodo->{datos}[$i];
    }

    if (!$nodo->{hoja}) {
        _inorden_nodo($nodo->{hijos}[$n], $resultado);
    }
}

sub obtener_todos {
    my ($self) = @_;
    return $self->inorden();
}

sub eliminar {
    my ($self, $codigo) = @_;

    return 0 unless defined $codigo;
    return 0 unless $self->{raiz};

    _eliminar_rec($self, $self->{raiz}, $codigo);

    if (@{$self->{raiz}->{claves}} == 0 && !$self->{raiz}->{hoja}) {
        $self->{raiz} = $self->{raiz}->{hijos}[0];
    }

    return 1;
}

sub _eliminar_rec {
    my ($self, $nodo, $codigo) = @_;

    my $idx = _encontrar_indice($nodo, $codigo);

    if ($idx < @{$nodo->{claves}} && $nodo->{claves}[$idx] eq $codigo) {
        if ($nodo->{hoja}) {
            _eliminar_de_hoja($nodo, $idx);
        } else {
            _eliminar_de_interno($self, $nodo, $idx);
        }
        return;
    }

    return if $nodo->{hoja};

    my $flag = ($idx == @{$nodo->{claves}}) ? 1 : 0;

    if (@{$nodo->{hijos}[$idx]->{claves}} < $self->{t}) {
        _llenar($self, $nodo, $idx);
    }

    if ($flag && $idx > @{$nodo->{claves}}) {
        _eliminar_rec($self, $nodo->{hijos}[$idx - 1], $codigo);
    } else {
        _eliminar_rec($self, $nodo->{hijos}[$idx], $codigo);
    }
}

sub _encontrar_indice {
    my ($nodo, $codigo) = @_;
    my $idx = 0;

    while ($idx < @{$nodo->{claves}} && $nodo->{claves}[$idx] lt $codigo) {
        $idx++;
    }

    return $idx;
}

sub _eliminar_de_hoja {
    my ($nodo, $idx) = @_;
    splice @{$nodo->{claves}}, $idx, 1;
    splice @{$nodo->{datos}},  $idx, 1;
}

sub _eliminar_de_interno {
    my ($self, $nodo, $idx) = @_;

    my $codigo = $nodo->{claves}[$idx];

    if (@{$nodo->{hijos}[$idx]->{claves}} >= $self->{t}) {
        my ($pred_clave, $pred_dato) = _obtener_predecesor($nodo->{hijos}[$idx]);
        $nodo->{claves}[$idx] = $pred_clave;
        $nodo->{datos}[$idx]  = $pred_dato;
        _eliminar_rec($self, $nodo->{hijos}[$idx], $pred_clave);
    }
    elsif (@{$nodo->{hijos}[$idx + 1]->{claves}} >= $self->{t}) {
        my ($succ_clave, $succ_dato) = _obtener_sucesor($nodo->{hijos}[$idx + 1]);
        $nodo->{claves}[$idx] = $succ_clave;
        $nodo->{datos}[$idx]  = $succ_dato;
        _eliminar_rec($self, $nodo->{hijos}[$idx + 1], $succ_clave);
    }
    else {
        _fusionar($self, $nodo, $idx);
        _eliminar_rec($self, $nodo->{hijos}[$idx], $codigo);
    }
}

sub _obtener_predecesor {
    my ($nodo) = @_;

    while (!$nodo->{hoja}) {
        $nodo = $nodo->{hijos}[-1];
    }

    my $ultimo = @{$nodo->{claves}} - 1;
    return ($nodo->{claves}[$ultimo], $nodo->{datos}[$ultimo]);
}

sub _obtener_sucesor {
    my ($nodo) = @_;

    while (!$nodo->{hoja}) {
        $nodo = $nodo->{hijos}[0];
    }

    return ($nodo->{claves}[0], $nodo->{datos}[0]);
}

sub _llenar {
    my ($self, $nodo, $idx) = @_;

    if ($idx != 0 && @{$nodo->{hijos}[$idx - 1]->{claves}} >= $self->{t}) {
        _pedir_prestado_izq($nodo, $idx);
    }
    elsif ($idx != @{$nodo->{claves}} && @{$nodo->{hijos}[$idx + 1]->{claves}} >= $self->{t}) {
        _pedir_prestado_der($nodo, $idx);
    }
    else {
        if ($idx != @{$nodo->{claves}}) {
            _fusionar($self, $nodo, $idx);
        } else {
            _fusionar($self, $nodo, $idx - 1);
        }
    }
}

sub _pedir_prestado_izq {
    my ($nodo, $idx) = @_;

    my $hijo    = $nodo->{hijos}[$idx];
    my $hermano = $nodo->{hijos}[$idx - 1];

    unshift @{$hijo->{claves}}, $nodo->{claves}[$idx - 1];
    unshift @{$hijo->{datos}},  $nodo->{datos}[$idx - 1];

    if (!$hijo->{hoja}) {
        unshift @{$hijo->{hijos}}, pop @{$hermano->{hijos}};
    }

    $nodo->{claves}[$idx - 1] = pop @{$hermano->{claves}};
    $nodo->{datos}[$idx - 1]  = pop @{$hermano->{datos}};
}

sub _pedir_prestado_der {
    my ($nodo, $idx) = @_;

    my $hijo    = $nodo->{hijos}[$idx];
    my $hermano = $nodo->{hijos}[$idx + 1];

    push @{$hijo->{claves}}, $nodo->{claves}[$idx];
    push @{$hijo->{datos}},  $nodo->{datos}[$idx];

    if (!$hijo->{hoja}) {
        push @{$hijo->{hijos}}, shift @{$hermano->{hijos}};
    }

    $nodo->{claves}[$idx] = shift @{$hermano->{claves}};
    $nodo->{datos}[$idx]  = shift @{$hermano->{datos}};
}

sub _fusionar {
    my ($self, $nodo, $idx) = @_;

    my $hijo    = $nodo->{hijos}[$idx];
    my $hermano = $nodo->{hijos}[$idx + 1];

    push @{$hijo->{claves}}, $nodo->{claves}[$idx];
    push @{$hijo->{datos}},  $nodo->{datos}[$idx];

    push @{$hijo->{claves}}, @{$hermano->{claves}};
    push @{$hijo->{datos}},  @{$hermano->{datos}};

    if (!$hijo->{hoja}) {
        push @{$hijo->{hijos}}, @{$hermano->{hijos}};
    }

    splice @{$nodo->{claves}}, $idx, 1;
    splice @{$nodo->{datos}},  $idx, 1;
    splice @{$nodo->{hijos}},  $idx + 1, 1;
}

sub generar_graphviz {
    my ($self, $ruta_dot, $ruta_png) = @_;

    open(my $fh, '>:encoding(UTF-8)', $ruta_dot)
        or die "No se pudo crear $ruta_dot: $!";

    print $fh "digraph ArbolB_Suministros {\n";
    print $fh "    graph [charset=\"UTF-8\"];\n";
    print $fh "    node [shape=record, style=filled, fontname=\"Arial\"];\n";
    print $fh "    edge [color=\"#333333\", fontname=\"Arial\", fontsize=10];\n";
    print $fh "    label=\"Inventario de Suministros (Árbol B - Orden 4)\";\n";
    print $fh "    labelloc=\"t\";\n";
    print $fh "    rankdir=TB;\n";

    if (defined $self->{raiz}) {
        $self->_escribir_nodos_dot($self->{raiz}, $fh);
    } else {
        print $fh "    vacio [label=\"Árbol B Vacío\", fillcolor=\"#EEEEEE\"];\n";
    }

    print $fh "}\n";
    close($fh);

    system("dot", "-Gcharset=utf8", "-Tpng", $ruta_dot, "-o", $ruta_png);
}

sub _escribir_nodos_dot {
    my ($self, $nodo, $fh) = @_;
    return unless defined $nodo;

    my @claves_nodo = @{ $nodo->{claves} // [] };
    my $cantidad_actual = scalar @claves_nodo;
    my $max_capacidad = 4;

    my $color = ($cantidad_actual == $max_capacidad) ? "#FFFF99" : "#CCFFCC";

    my @codigos = map {
        ref($_) eq 'HASH' ? $_->{codigo} : $_
    } @claves_nodo;

    my $lista_codigos = join(" | ", @codigos);

    my $label = "{ { $lista_codigos } | Capacidad: $cantidad_actual/$max_capacidad }";

    my $node_id = "$nodo";
    $node_id =~ s/\W/_/g;

    print $fh "    \"$node_id\" [label=\"$label\", fillcolor=\"$color\"];\n";

    if (defined $nodo->{hijos} && ref($nodo->{hijos}) eq 'ARRAY') {
        foreach my $hijo (@{ $nodo->{hijos} }) {
            next unless defined $hijo;

            my $hijo_id = "$hijo";
            $hijo_id =~ s/\W/_/g;

            $self->_escribir_nodos_dot($hijo, $fh);
            print $fh "    \"$node_id\" -> \"$hijo_id\";\n";
        }
    }
}

1;