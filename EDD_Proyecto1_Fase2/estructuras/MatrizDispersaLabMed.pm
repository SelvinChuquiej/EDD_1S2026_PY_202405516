package estructuras::MatrizDispersaLabMed;
use strict;
use warnings;

use nodos::NodoCabecera;
use nodos::NodoValor;

sub new {
    my ($class) = @_;
    my $self = {
        filas => undef,
        columnas => undef,
    };
    bless $self, $class;
    return $self;
}

sub _find_or_create_row {
    my ($self, $proveedor) = @_; 

    if(!defined $self->{filas}) {
        $self->{filas} = nodos::NodoCabecera->new($proveedor);
        return $self->{filas};
    }

    my $current = $self->{filas};
    my $prev;
    while ($current) {
        return $current if $current->{id} eq $proveedor;
        last if $proveedor lt $current->{id};
        $prev = $current;
        $current = $current->{next};
    }

    my $nuevo = nodos::NodoCabecera->new($proveedor);
    if(!defined $prev){
        $nuevo->{next} = $self->{filas}; 
        $self->{filas} = $nuevo;
    } else {
        $nuevo->{next} = $prev->{next};
        $prev->{next} = $nuevo;
    }
    return $nuevo;
}

sub _find_or_create_column {
    my ($self, $fabricante) = @_;

    if(!defined $self->{columnas}) {
        $self->{columnas} = nodos::NodoCabecera->new($fabricante);
        return $self->{columnas};
    }

    my $current = $self->{columnas};
    my $prev;
    while ($current) {
        return $current if $current->{id} eq $fabricante;
        last if $fabricante lt $current->{id};
        $prev = $current;
        $current = $current->{next};
    }

    my $nuevo = nodos::NodoCabecera->new($fabricante);
    if(!defined $prev){
        $nuevo->{next} = $self->{columnas}; 
        $self->{columnas} = $nuevo;
    } else {
        $nuevo->{next} = $prev->{next};
        $prev->{next} = $nuevo;
    }
    return $nuevo;
}

sub _find_cell {
    my ($self, $fila, $fabricante) = @_;
    my $current = $fila->{access};
    while($current) {
        return $current if $current->{fabricante} eq $fabricante;
        $current = $current->{right};
    }
    
    return undef;
}

sub add {
    my ($self, $proveedor, $fabricante, $cantidad) = @_;

    my $fila = $self->_find_or_create_row($proveedor);
    my $col  = $self->_find_or_create_column($fabricante);

    my $existente = $self->_find_cell($fila, $fabricante);
    if ($existente) {
        $existente->{cantidad_total} += $cantidad;
        return;
    }

    my $nuevo = nodos::NodoValor->new({
        proveedor => $proveedor,
        fabricante => $fabricante,
        cantidad_total => $cantidad,
    });

    $self->_add_to_row($fila, $nuevo); 
    $self->_add_to_column($col, $nuevo);
}

sub _add_to_row {
    my ($self, $fila, $nuevo) = @_;
    if (!defined $fila->{access}) {
        $fila->{access} = $nuevo;
        return;
    }

    my $current = $fila->{access};
    my $prev;
    while ($current) {
        last if $nuevo->{fabricante} lt $current->{fabricante};
        $prev = $current;
        $current = $current->{right};
    }

    if (!defined $prev) {
        $nuevo->{right} = $fila->{access};
        $fila->{access}->{left} = $nuevo;
        $fila->{access} = $nuevo;
    } else {
        $nuevo->{right} = $current;
        $nuevo->{left} = $prev;
        $prev->{right} = $nuevo;
        $current->{left} = $nuevo if $current;
    }
}

sub _add_to_column {
    my ($self, $col, $nuevo) = @_;

    if (!defined $col->{access}) {
        $col->{access} = $nuevo;
        return;
    }

    my $current = $col->{access};
    my $prev;

    while ($current) {
        last if $nuevo->{proveedor} lt $current->{proveedor};
        $prev = $current;
        $current = $current->{down};
    }

    if (!defined $prev) {
        $nuevo->{down} = $col->{access};
        $col->{access}->{up} = $nuevo;
        $col->{access} = $nuevo;
    } else {
        $nuevo->{down} = $current;
        $nuevo->{up} = $prev;
        $prev->{down} = $nuevo;
        $current->{up} = $nuevo if $current;
    }
}

sub list {
        my ($self) = @_;
    my @datos;

    my $fila = $self->{filas};
    while ($fila) {
        my $current = $fila->{access};
        while ($current) {
            push @datos, {
                proveedor => $current->{proveedor},
                fabricante => $current->{fabricante},
                cantidad_total => $current->{cantidad_total},
            };
            $current = $current->{right};
        }
        $fila = $fila->{next};
    }

    return \@datos;
}

sub generar_graphviz {
    my ($self, $ruta_dot, $ruta_png) = @_;

    open(my $fh, '>:encoding(UTF-8)', $ruta_dot)
        or die "No se pudo crear $ruta_dot: $!";

    print $fh "digraph MatrizDispersa {\n";
    print $fh "    graph [charset=\"UTF-8\", rankdir=TB, nodesep=0.8, ranksep=1.0];\n";
    print $fh "    node [fontname=\"Arial\", fontsize=10];\n";
    print $fh "    edge [dir=none];\n";
    print $fh "    label=\"Relación Proveedores vs Fabricantes (Matriz Dispersa)\";\n";
    print $fh "    labelloc=\"t\";\n\n";

    print $fh "    Raiz [label=\"Inicio\", shape=box, style=filled, fillcolor=lightgray];\n";

    my $col = $self->{columnas};
    my $prev_col = "Raiz";

    print $fh "    { rank = same; Raiz; ";

    while ($col) {
        my $id_col = "col_" . $col->{id};
        $id_col =~ s/\W/_/g;

        my $label_col = $col->{id};
        $label_col =~ s/"/\\"/g;

        print $fh "        $id_col [label=\"$label_col\", shape=box, style=filled, fillcolor=lightblue];\n";
        print $fh "        $prev_col -> $id_col;\n";
        print $fh "        $id_col; ";

        $prev_col = $id_col;
        $col = $col->{next};
    }
    print $fh "    }\n\n";

    my $fila = $self->{filas};
    my $prev_fila = "Raiz";

    while ($fila) {
        my $id_fila = "fila_" . $fila->{id};
        $id_fila =~ s/\W/_/g;

        my $label_fila = $fila->{id};
        $label_fila =~ s/"/\\"/g;

        print $fh "    $id_fila [label=\"$label_fila\", shape=box, style=filled, fillcolor=lightyellow];\n";
        print $fh "    $prev_fila -> $id_fila;\n";

        my @nodos_fila;
        my $actual = $fila->{access};
        my $prev_nodo = $id_fila;

        while ($actual) {
            my $id_nodo = "nodo_" . $actual->{proveedor} . "_" . $actual->{fabricante};
            $id_nodo =~ s/\W/_/g;

            my $cantidad = $actual->{cantidad_total};
            print $fh "    $id_nodo [label=\"$cantidad\", shape=circle, style=filled, fillcolor=white];\n";
            print $fh "    $prev_nodo -> $id_nodo [constraint=false];\n";
            push @nodos_fila, $id_nodo;
            $prev_nodo = $id_nodo;
            $actual = $actual->{right};
        }

        print $fh "    { rank = same; $id_fila; " . join("; ", @nodos_fila) . "; }\n" if @nodos_fila;
        $prev_fila = $id_fila;
        $fila = $fila->{next};
        print $fh "\n";
    }

    $col = $self->{columnas};

    while ($col) {
        my $id_col = "col_" . $col->{id};
        $id_col =~ s/\W/_/g;

        my $actual = $col->{access};
        my $prev_vertical = $id_col;

        while ($actual) {
            my $id_nodo = "nodo_" . $actual->{proveedor} . "_" . $actual->{fabricante};
            $id_nodo =~ s/\W/_/g;

            print $fh "    $prev_vertical -> $id_nodo [constraint=true];\n";

            $prev_vertical = $id_nodo;
            $actual = $actual->{down};
        }

        $col = $col->{next};
    }

    print $fh "}\n";
    close($fh);

    system("dot", "-Gcharset=utf8", "-Tpng", $ruta_dot, "-o", $ruta_png);
}

1;