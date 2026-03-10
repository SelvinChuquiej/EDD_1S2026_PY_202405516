package matriz::MatrizDispersa;
use strict;
use warnings;

use matriz::NodoCabecera;
use matriz::NodoValor;

sub new {
    my ($class) = @_;
    my $self = {
        filas => undef,  
        columnas => undef,
    };
    bless $self, $class;
    return $self;
}

# Crear/obtener cabecera fila (laboratorio) 
sub _get_or_create_fila {
    my ($self, $lab) = @_;

    if (!$self->{filas}) {
        $self->{filas} = matriz::NodoCabecera->new($lab);
        return $self->{filas};
    }
    if ($lab lt $self->{filas}->{id}) {
        my $n = matriz::NodoCabecera->new($lab);
        $n->{next} = $self->{filas};
        $self->{filas} = $n;
        return $n;
    }
    my $cur = $self->{filas};
    while ($cur->{next} && $cur->{next}->{id} lt $lab) {
        $cur = $cur->{next};
    }

    return $cur if $cur->{id} eq $lab;
    return $cur->{next} if ($cur->{next} && $cur->{next}->{id} eq $lab);

    my $n = matriz::NodoCabecera->new($lab);
    $n->{next} = $cur->{next};
    $cur->{next} = $n;
    return $n;
}

# Crear/obtener cabecera columna (medicamento)
sub _get_or_create_columna {
    my ($self, $med) = @_;

    if (!$self->{columnas}) {
        $self->{columnas} = matriz::NodoCabecera->new($med);
        return $self->{columnas};
    }
    if ($med lt $self->{columnas}->{id}) {
        my $n = matriz::NodoCabecera->new($med);
        $n->{next} = $self->{columnas};
        $self->{columnas} = $n;
        return $n;
    }
    my $cur = $self->{columnas};
    while ($cur->{next} && $cur->{next}->{id} lt $med) {
        $cur = $cur->{next};
    }

    return $cur if $cur->{id} eq $med;
    return $cur->{next} if ($cur->{next} && $cur->{next}->{id} eq $med);

    my $n = matriz::NodoCabecera->new($med);
    $n->{next} = $cur->{next};
    $cur->{next} = $n;
    return $n;
}

sub insertar {
    my ($self, $data) = @_;

    my $lab = $data->{laboratorio};
    my $med = $data->{medicamento};

    my $fila = $self->_get_or_create_fila($lab);
    my $col  = $self->_get_or_create_columna($med);

    my $nuevo = matriz::NodoValor->new($data);

    _insertar_en_fila($fila, $nuevo);
    _insertar_en_columna($col, $nuevo);

    return 1;
}

# Ordenado por medicamento
sub _insertar_en_fila {
    my ($fila, $nodo) = @_;

    my $first = $fila->{access};
    if (!$first || $nodo->{medicamento} lt $first->{medicamento}) {
        $nodo->{right} = $first;
        $first->{left} = $nodo if $first;
        $fila->{access} = $nodo;
        return;
    }
    my $cur = $first;
    while ($cur->{right} && $cur->{right}->{medicamento} lt $nodo->{medicamento}) {
        $cur = $cur->{right};
    }

    if ($cur->{medicamento} eq $nodo->{medicamento}) {
        $cur->{precio} = $nodo->{precio};
        $cur->{principio_activo} = $nodo->{principio_activo};
        $cur->{codigo_med} = $nodo->{codigo_med};
        return;
    }
    if ($cur->{right} && $cur->{right}->{medicamento} eq $nodo->{medicamento}) {
        $cur->{right}->{precio} = $nodo->{precio};
        $cur->{right}->{principio_activo} = $nodo->{principio_activo};
        $cur->{right}->{codigo_med} = $nodo->{codigo_med};
        return;
    }
    $nodo->{right} = $cur->{right};
    $nodo->{left}  = $cur;
    $cur->{right}->{left} = $nodo if $cur->{right};
    $cur->{right} = $nodo;
}

# Ordenado por laboratorio
sub _insertar_en_columna {
    my ($col, $nodo) = @_;
    my $first = $col->{access};
    if (!$first || $nodo->{laboratorio} lt $first->{laboratorio}) {
        $nodo->{down} = $first;
        $first->{up}  = $nodo if $first;
        $col->{access} = $nodo;
        return;
    }
    my $cur = $first;
    while ($cur->{down} && $cur->{down}->{laboratorio} lt $nodo->{laboratorio}) {
        $cur = $cur->{down};
    }

    $nodo->{down} = $cur->{down};
    $nodo->{up}   = $cur;
    $cur->{down}->{up} = $nodo if $cur->{down};
    $cur->{down} = $nodo;
}

sub consultar_por_medicamento {
    my ($self, $medicamento, $inventario) = @_;

    my $col = $self->{columnas};
    while ($col && $col->{id} ne $medicamento) {
        $col = $col->{next};
    }
    if (!$col) {
        print "No hay registros del medicamento '$medicamento' en la matriz.\n";
        return;
    }
    my $n = $col->{access};
    if (!$n) {
        print "No hay laboratorios registrados para '$medicamento'.\n";
        return;
    }
    print "\nComparacion de '$medicamento' por laboratorio:\n";
    while ($n) {
        my $stock = "N/A";
        if ($inventario) {
            my $med_node = $inventario->buscar_codigo($n->{codigo_med}); # ✅ usa code
            $stock = $med_node ? $med_node->{stock} : "N/A";
        }

        print "- Lab: $n->{laboratorio} | Precio: Q$n->{precio} | Stock: $stock | Principio: $n->{principio_activo}\n";
        $n = $n->{down};
    }
}

sub generar_reporte_dot {
    my ($self, $archivo) = @_;
    open(my $fh, '>', $archivo) or die "No se pudo crear archivo DOT: $!";

    my $safe = sub {
        my ($t) = @_;
        $t = "" unless defined $t;
        $t =~ s/\\/\\\\/g;
        $t =~ s/"/\\"/g;
        return $t;
    };

    print $fh "digraph MatrizDispersa {\n";
    print $fh "  graph [rankdir=LR, nodesep=0.6, ranksep=0.7, splines=ortho];\n";
    print $fh "  node  [fontname=\"Verdana\", fontsize=10];\n";
    print $fh "  edge  [arrowsize=0.7];\n\n";
    print $fh "  MT [label=\"MATRIZ\\nINVENTARIO\", shape=box, style=filled, fillcolor=\"#b3b3b3\"];\n\n";

    my %col_group;
    my @cols_ids;

    my $col = $self->{columnas};
    my $g = 2;
    while ($col) {
        my $col_name = $col->{id};
        my $cid = "C_" . _limpiar_id($col_name);
        $col_group{$col_name} = $g++;
        push @cols_ids, $cid;
        my $lbl = $safe->($col_name);
        print $fh "  $cid [label=\"$lbl\", shape=box, style=filled, fillcolor=\"#E0E0E0\", group=$col_group{$col_name}];\n";
        $col = $col->{next};
    }

    if (@cols_ids) {
        print $fh "  MT -> $cols_ids[0] [constraint=true];\n";
        for (my $i = 0; $i < $#cols_ids; $i++) {
            print $fh "  $cols_ids[$i] -> $cols_ids[$i+1] [constraint=true];\n";
        }
        print $fh "  { rank=same; MT; " . join("; ", @cols_ids) . " }\n\n";
    }

    my @rows_ids;
    my $fila = $self->{filas};
    while ($fila) {
        my $row_name = $fila->{id};
        my $rid = "F_" . _limpiar_id($row_name);
        push @rows_ids, $rid;
        my $lbl = $safe->($row_name);
        print $fh "  $rid [label=\"$lbl\", shape=box, style=filled, fillcolor=\"#ADD8E6\", group=1];\n";
        $fila = $fila->{next};
    }

    if (@rows_ids) {
        print $fh "  MT -> $rows_ids[0] [constraint=true];\n";
        for (my $i = 0; $i < $#rows_ids; $i++) {
            print $fh "  $rows_ids[$i] -> $rows_ids[$i+1] [constraint=true];\n";
        }
        print $fh "\n";
    }

    $fila = $self->{filas};
    while ($fila) {
        my $row_name = $fila->{id};
        my $rid = "F_" . _limpiar_id($row_name);
        my @rank_same = ($rid);
        my $n = $fila->{access};
        while ($n) {
            my $med_name = $n->{medicamento};
            my $cid = "C_" . _limpiar_id($med_name);
            my $vid = "V_" . _limpiar_id($row_name) . "_" . _limpiar_id($med_name);
            my $codigo = defined $n->{codigo_med} ? $n->{codigo_med} : "";
            my $precio = defined $n->{precio} ? $n->{precio} : "";
            my $pa     = defined $n->{principio_activo} ? $n->{principio_activo} : "";
            my $cant   = defined $n->{cantidad} ? $n->{cantidad}
                       : defined $n->{stock}    ? $n->{stock}
                       : "";
            my $lbl = "COD:$codigo";
            $lbl .= "\\nCant:$cant" if $cant ne "";
            $lbl .= "\\nQ.$precio"  if $precio ne "";
            $lbl .= "\\n$pa"        if $pa ne "";
            $lbl = $safe->($lbl);
            my $grp = exists $col_group{$med_name} ? $col_group{$med_name} : 99;
            print $fh "  $vid [label=\"$lbl\", shape=ellipse, style=filled, fillcolor=\"#ffffe0\", group=$grp];\n";
            print $fh "  $rid -> $vid [constraint=true];\n";
            print $fh "  $cid -> $vid [constraint=true, style=dashed, color=\"#999999\"];\n";
            push @rank_same, $vid;
            $n = $n->{right};
        }
        print $fh "  { rank=same; " . join("; ", @rank_same) . " }\n\n";
        $fila = $fila->{next};
    }

    print $fh "}\n";
    close($fh);
}

sub _limpiar_id {
    my ($txt) = @_;
    $txt = "" unless defined $txt;
    $txt =~ s/^\s+|\s+$//g;
    $txt =~ s/\s+/_/g;
    $txt =~ s/[^A-Za-z0-9_]/_/g;
    $txt = "X" if $txt eq "";

    return $txt;
}

1;