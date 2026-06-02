# Nodo contenedor para lista de vértices
package estructuras::_NodoCont;

sub new {
    my ($class, $data) = @_;
    bless { data => $data, siguiente => undef }, $class;
}

sub get_data { return $_[0]->{data}; }
sub get_siguiente { return $_[0]->{siguiente}; }
sub set_siguiente { $_[0]->{siguiente} = $_[1]; }

# Nodo para la cola de BFS
package estructuras::_NodoColaBFS;

sub new {
    my ($class, $vertice, $distancia) = @_;
    my $self = {
        vertice   => $vertice,
        distancia => $distancia,
        siguiente => undef
    };
    bless $self, $class;
    return $self;
}

sub get_vertice { return $_[0]->{vertice}; }
sub get_distancia { return $_[0]->{distancia}; }
sub get_siguiente { return $_[0]->{siguiente}; }
sub set_siguiente { $_[0]->{siguiente} = $_[1]; }

# Cola para recorrido BFS
package estructuras::_ColaBFS;

sub new {
    my ($class) = @_;
    my $self = {
        frente => undef,
        final  => undef,
        tamanio => 0
    };
    bless $self, $class;
    return $self;
}

sub esta_vacia {
    my ($self) = @_;
    return !defined($self->{frente});
}

sub encolar {
    my ($self, $vertice, $distancia) = @_;
    my $nuevo = estructuras::_NodoColaBFS->new($vertice, $distancia);
    if ($self->esta_vacia()) {
        $self->{frente} = $nuevo;
        $self->{final} = $nuevo;
    } else {
        $self->{final}->set_siguiente($nuevo);
        $self->{final} = $nuevo;
    }
    $self->{tamanio}++;
}

sub desencolar {
    my ($self) = @_;
    return undef if $self->esta_vacia();
    my $nodo = $self->{frente};
    $self->{frente} = $self->{frente}->get_siguiente();
    if (!defined $self->{frente}) {
        $self->{final} = undef;
    }
    $self->{tamanio}--;
    return $nodo;
}

# Clase principal Grafo
package estructuras::Grafo;

use strict;
use warnings;
use nodos::NodoGrafo;

sub new {
    my ($class) = @_;
    my $self = {
        vertices_cabeza => undef,
        tamanio => 0,
    };
    bless $self, $class;
    return $self;
}

# Buscar un vértice por ID
sub buscar_vertice {
    my ($self, $id) = @_;
    my $actual = $self->{vertices_cabeza};
    while (defined $actual) {
        if ($actual->get_data()->get_id() eq $id) {
            return $actual->get_data();
        }
        $actual = $actual->get_siguiente();
    }
    return undef;
}

# Insertar un nuevo vértice
sub insertar_vertice {
    my ($self, $id, $data) = @_;
    return if defined $self->buscar_vertice($id);
    my $nuevo_grafo = nodos::NodoGrafo->new($id, $data);
    my $nuevo_cont = estructuras::_NodoCont->new($nuevo_grafo);
    if (!defined $self->{vertices_cabeza}) {
        $self->{vertices_cabeza} = $nuevo_cont;
    } else {
        my $actual = $self->{vertices_cabeza};
        while (defined $actual->get_siguiente()) {
            $actual = $actual->get_siguiente();
        }
        $actual->set_siguiente($nuevo_cont);
    }
    $self->{tamanio}++;
}

# Insertar arista entre dos vértices
sub insertar_arista {
    my ($self, $id_origen, $id_destino) = @_;
    my $v_origen = $self->buscar_vertice($id_origen);
    my $v_destino = $self->buscar_vertice($id_destino);
    if (defined $v_origen && defined $v_destino) {
        $v_origen->agregar_vecino($v_destino);
        $v_destino->agregar_vecino($v_origen);
    }
}

# Obtener IDs de los vecinos de un vértice
sub obtener_adyacentes {
    my ($self, $id_usuario) = @_;
    my @adyacentes = ();
    my $vertice = $self->buscar_vertice($id_usuario);
    return @adyacentes unless defined $vertice;
    my $lista_ady = $vertice->get_lista_adyacencia();
    my $nodo_actual = $lista_ady->get_cabeza();
    while (defined $nodo_actual) {
        my $vecino_vertice = $nodo_actual->get_data();
        push @adyacentes, $vecino_vertice->get_id();
        $nodo_actual = $nodo_actual->get_siguiente();
    }
    return @adyacentes;
}

# Sugerir colaboradores a distancia 2 (amigos de amigos)
sub sugerir_colaboradores {
    my ($self, $id_origen) = @_;
    my @sugerencias = ();
    my $vertice_origen = $self->buscar_vertice($id_origen);
    return \@sugerencias unless defined $vertice_origen;
    my %visitados;
    $visitados{$id_origen} = 1;
    my $cola = estructuras::_ColaBFS->new();
    $cola->encolar($vertice_origen, 0);
    while (!$cola->esta_vacia()) {
        my $nodo_cola = $cola->desencolar();
        my $nodo_actual = $nodo_cola->get_vertice();
        my $distancia = $nodo_cola->get_distancia();
        if ($distancia == 2) {
            push @sugerencias, $nodo_actual->get_id();
        }
        if ($distancia < 2) {
            my $lista_ady = $nodo_actual->get_lista_adyacencia();
            my $vecino_nodo = $lista_ady->get_cabeza();
            while (defined $vecino_nodo) {
                my $vecino_v = $vecino_nodo->get_data();
                my $vecino_id = $vecino_v->get_id();
                if (!$visitados{$vecino_id}) {
                    $visitados{$vecino_id} = 1;
                    $cola->encolar($vecino_v, $distancia + 1);
                }
                $vecino_nodo = $vecino_nodo->get_siguiente();
            }
        }
    }
    return \@sugerencias;
}

# Sugerir colaboradores ordenados por amigos en común
sub sugerir_colaboradores_ordenados {
    my ($self, $id_origen) = @_;
    my $vertice_origen = $self->buscar_vertice($id_origen);
    return () unless defined $vertice_origen;
    my %amigos_directos;
    my $lista_ady = $vertice_origen->get_lista_adyacencia();
    my $nodo_actual = $lista_ady->get_cabeza();
    while (defined $nodo_actual) {
        my $id_amigo = $nodo_actual->get_data()->get_id();
        $amigos_directos{$id_amigo} = 1;
        $nodo_actual = $nodo_actual->get_siguiente();
    }
    my %conteo_mutuos;
    $nodo_actual = $lista_ady->get_cabeza();
    while (defined $nodo_actual) {
        my $amigo_v = $nodo_actual->get_data();
        my $amigos_de_amigo = $amigo_v->get_lista_adyacencia()->get_cabeza();
        while (defined $amigos_de_amigo) {
            my $id_candidato = $amigos_de_amigo->get_data()->get_id();
            if ($id_candidato ne $id_origen && !$amigos_directos{$id_candidato}) {
                $conteo_mutuos{$id_candidato}++;
            }
            $amigos_de_amigo = $amigos_de_amigo->get_siguiente();
        }
        $nodo_actual = $nodo_actual->get_siguiente();
    }
    my @sugerencias_ordenadas = sort { $conteo_mutuos{$b} <=> $conteo_mutuos{$a} } keys %conteo_mutuos;
    my @resultados;
    foreach my $id (@sugerencias_ordenadas) {
        push @resultados, {
            id => $id,
            comunes => $conteo_mutuos{$id}
        };
    }
    return @resultados;
}

sub _obtener_color_departamento {
    my ($depto) = @_;

    return "#00ff00" if defined $depto && $depto eq "DEP-MED"; 
    return "#ff0000" if defined $depto && $depto eq "DEP-FAR"; 
    return "#d9c2f0" if defined $depto && $depto eq "DEP-LAB"; 
    return "#0026ff" if defined $depto && $depto eq "DEP-CIR"; 
    return "#bcdffb" if defined $depto && $depto eq "DEP-ADM"; 
    return "#888888" if defined $depto && $depto eq "SIN-DEP"; 

    return "#4e4d4d";
}

sub generar_graphviz {
    my ($self, $ruta_dot, $ruta_png) = @_;

    my $dot = "graph G {\n";
    $dot .= "  layout=neato;\n";
    $dot .= "  overlap=false;\n";
    $dot .= "  splines=true;\n";
    $dot .= "  bgcolor=\"white\";\n";
    $dot .= "  label=\"REPORTE DE RED DE COLABORACIÓN\\n\\n\";\n";
    $dot .= "  labelloc=\"t\";\n";
    $dot .= "  fontsize=18;\n";
    $dot .= "  fontname=\"Arial\";\n";
    $dot .= "  node [shape=circle, style=filled, fontname=\"Arial\", fontsize=9, width=1.5, height=1.5, color=\"#555555\"];\n";
    $dot .= "  edge [color=\"#555555\", penwidth=1.2];\n\n";

    my %aristas_procesadas;
    my $actual_v = $self->{vertices_cabeza};

    while (defined $actual_v) {
        my $vertice = $actual_v->get_data();
        my $id = $vertice->get_id();
        my $datos = $vertice->get_data();

        my $colegiado = $datos->{numero_colegio} // $id;
        my $nombre    = $datos->{nombre_completo} // "N/A";
        my $depto     = $datos->{departamento} // "SIN-DEP";
        my $tipo      = $datos->{tipo_usuario} // "N/A";

        my $color = _obtener_color_departamento($depto);

        $nombre =~ s/"/\\"/g;
        $depto  =~ s/"/\\"/g;
        $tipo   =~ s/"/\\"/g;
        $colegiado =~ s/"/\\"/g;

        my $label = "No. colegio\\n$colegiado\\nnombre: $nombre\\n$depto\\n$tipo";
        $dot .= "  \"$id\" [fillcolor=\"$color\", label=\"$label\"];\n";
        $actual_v = $actual_v->get_siguiente();
    }

    $dot .= "\n";

    $actual_v = $self->{vertices_cabeza};
    while (defined $actual_v) {
        my $vertice = $actual_v->get_data();
        my $id_origen = $vertice->get_id();
        my $adyacentes = $vertice->get_lista_adyacencia();
        my $actual_ady = $adyacentes->get_cabeza();

        while (defined $actual_ady) {
            my $id_destino = $actual_ady->get_data()->get_id();

            my $llave = join('-', sort($id_origen, $id_destino));
            if (!$aristas_procesadas{$llave}) {
                $dot .= "  \"$id_origen\" -- \"$id_destino\";\n";
                $aristas_procesadas{$llave} = 1;
            }
            $actual_ady = $actual_ady->get_siguiente();
        }
        $actual_v = $actual_v->get_siguiente();
    }

    $dot .= "}\n";

    open(my $fh, '>', $ruta_dot) or die "No se pudo crear $ruta_dot: $!";
    print $fh $dot;
    close($fh);

    # Usar neato para que se vea como red
    system("neato -Tpng \"$ruta_dot\" -o \"$ruta_png\"");
}

sub generar_graphviz_lista_adyacencia {
    my ($self, $ruta_dot, $ruta_png) = @_;

    my $dot = "digraph G {\n"; 
    $dot .= "  rankdir=LR;\n"; 
    $dot .= "  node [shape=box, style=filled, fontname=\"Arial\"];\n";
    $dot .= "  edge [color=\"#2c3e50\"];\n";
    $dot .= "  label=\"REPORTE ESTRUCTURAL: LISTA DE ADYACENCIA\\n\\n\";\n";
    $dot .= "  labelloc=\"t\";\n\n";

    my $actual_v = $self->{vertices_cabeza};
    my $contador_filas = 0;

    while (defined $actual_v) {
        my $vertice = $actual_v->get_data();
        my $id_origen = $vertice->get_id();
        
        my $nombre_nodo_principal = "V_$id_origen";
        $dot .= "  \"$nombre_nodo_principal\" [label=\"Vértice:\\n$id_origen\", fillcolor=\"#3498db\", fontcolor=\"white\"];\n";

        my $adyacentes = $vertice->get_lista_adyacencia();
        my $actual_ady = $adyacentes->get_cabeza();
        
        my $nodo_anterior = $nombre_nodo_principal;
        my $contador_vecinos = 0;

        while (defined $actual_ady) {
            my $id_destino = $actual_ady->get_data()->get_id();
            
            my $nombre_nodo_vecino = "Vecino_${id_origen}_${id_destino}_${contador_vecinos}";
            
            # Dibujamos la cajita del vecino
            $dot .= "  \"$nombre_nodo_vecino\" [label=\"$id_destino\", fillcolor=\"#ecf0f1\"];\n";
            
            $dot .= "  \"$nodo_anterior\" -> \"$nombre_nodo_vecino\";\n";
            
            $nodo_anterior = $nombre_nodo_vecino;
            $actual_ady = $actual_ady->get_siguiente();
            $contador_vecinos++;
        }

        if ($contador_filas > 0) {
            my $v_previo = $actual_v->get_siguiente();
        }

        $actual_v = $actual_v->get_siguiente();
        $contador_filas++;
    }

    $dot .= "}\n";

    open(my $fh, '>', $ruta_dot) or die "No se pudo crear $ruta_dot: $!";
    print $fh $dot;
    close($fh);

    # Generar imagen PNG
    system("dot -Tpng \"$ruta_dot\" -o \"$ruta_png\"");
}
1;