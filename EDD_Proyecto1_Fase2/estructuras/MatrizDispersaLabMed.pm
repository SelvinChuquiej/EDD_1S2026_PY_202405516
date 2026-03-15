package estructuras::MatrizDispersaLabMed;
use strict;
use warnings;

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

1;