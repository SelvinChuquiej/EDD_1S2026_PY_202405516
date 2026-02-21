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

1;