package inventario::DLinkedList;

use strict;
use warnings;

use inventario::NodoInventario;
use constant Nodo => 'inventario::NodoInventario';

sub new {
    my ($class) = @_;
    my $self = {
        head => undef,
        tail => undef,
    };
    bless $self, $class;
    return $self;
}

sub is_empty {
    my ($self) = @_;
    return !defined $self->{head};
}

sub agregar {
    my ($self, $data) = @_;
    my $nuevo_nodo = Nodo->new($data);

    #Lista vacía
    if ($self->is_empty()) {
        $self->{head} = $nuevo_nodo;
        $self->{tail} = $nuevo_nodo;
        return;
    }

    my $code_new = $nuevo_nodo->{code};

    #Insertar antes del head
    if ($code_new lt $self->{head}->{code}) {
        $nuevo_nodo->{next} = $self->{head};
        $self->{head}->{prev} = $nuevo_nodo;
        $self->{head} = $nuevo_nodo;
        return;
    }

    #Insertar después del tail
    if ($code_new gt $self->{tail}->{code}) {
        $nuevo_nodo->{prev} = $self->{tail};
        $self->{tail}->{next} = $nuevo_nodo;
        $self->{tail} = $nuevo_nodo;
        return;
    }

    #Insertar en medio buscar el primer nodo con codigo mayor
    my $current = $self->{head}->{next};

    while ($current) {
        if ($code_new lt $current->{code}) {
            my $prev_node = $current->{prev};

            $nuevo_nodo->{prev} = $prev_node;
            $nuevo_nodo->{next} = $current;

            $prev_node->{next} = $nuevo_nodo;
            $current->{prev} = $nuevo_nodo;
            return;
        }

        if ($code_new eq $current->{code}) {
            print "Error: El codigo '$code_new' ya existe en el inventario.\n";
            return;
        }

        $current = $current->{next};
    }
}

sub imprimir {
    my ($self) = @_;
    my $current = $self->{head};
    while ($current) {
        print "Codigo: $current->{code}, Nombre: $current->{name}, Principio Activo: $current->{principle}, Laboratorio: $current->{laboratory}, Stock: $current->{stock}, Fecha de Vencimiento: $current->{expiration}, Precio: $current->{price}, Nivel Minimo: $current->{min_level}\n";
        if ($current->{stock} < $current->{min_level}) {
            print "Precaucion: Stock debajo por el minimo\n";
        }
        $current = $current->{next};
    }
}

sub buscar_codigo {
    my ($self, $code) = @_;
    my $current = $self->{head};
    while ($current) {
        return $current if $current->{code} eq $code;
        $current = $current->{next};
    }
    return undef;
}

sub eliminar_codigo {
    my ($self, $code) = @_;

    my $node = $self->buscar_codigo($code);
    return 0 if !$node; 

    # Si el nodo a eliminar es el único nodo en la lista
    if ($self->{head} == $node && $self->{tail} == $node) {  
        $self->{head} = undef;
        $self->{tail} = undef;
        return 1;
    }
    
    # Si el nodo a eliminar es el head
    if ($self->{head} == $node) { 
        $self->{head} = $node->{next};
        $self->{head}->{prev} = undef;
        return 1;
    }
    
    # Si el nodo a eliminar es el tail
    if ($self->{tail} == $node) { 
        $self->{tail} = $node->{prev};
        $self->{tail}->{next} = undef;
        return 1;
    }

    # Si el nodo a eliminar está en medio
    my $prev = $node->{prev};
    my $next = $node->{next};
    $prev->{next} = $next;
    $next->{prev} = $prev;

    return 1;
}

sub actualizar_stock {
    my ($self, $code, $delta) = @_;
    my $node = $self->buscar_codigo($code);
    return (0, "Medicamento no encontrado") if !$node;
    
    my $stock_actual = $node->{stock};
    # print "debug-> stock actual: $stock_actual | delta: $delta\n";

    if($delta < 0 && $stock_actual + $delta < 0) {
        return (0, "No hay suficiente stock para realizar la operación");
    }

    $node->{stock} = $stock_actual + $delta;
    return (1, "Stock actualizado correctamente");
}

1;

