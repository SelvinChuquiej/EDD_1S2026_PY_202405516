package solicitudes::HistorialLinkedList;

use strict;
use warnings;

use solicitudes::NodoSolicitud;
use constant Nodo => 'solicitudes::NodoSolicitud';

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
    my $nodo = Nodo->new($data);

    $nodo->{next} = undef;
    $nodo->{prev} = undef;

    if ($self->is_empty()) {
        $self->{head} = $nodo;
        $self->{tail} = $nodo;
        return $nodo;
    }

    $self->{tail}->{next} = $nodo;
    $self->{tail} = $nodo;
    return $nodo;
}

sub buscar_por_id {
    my ($self, $id) = @_;
    my $cur = $self->{head};
    while ($cur) {
        return $cur if defined($cur->{id}) && $cur->{id} == $id;
        $cur = $cur->{next};
    }
    return undef;
}

sub actualizar_estado {
    my ($self, $id, $estado) = @_;
    my $nodo = $self->buscar_por_id($id);
    return (0, "No existe solicitud con id=$id") if !$nodo;

    $nodo->{estado} = $estado;
    return (1, "Estado actualizado a $estado");
}

sub imprimir_todo {
    my ($self) = @_;
    return if $self->is_empty();

    my $cur = $self->{head};
    while ($cur) {
        print "ID: $cur->{id} | Med: $cur->{codigo_med} | Cant: $cur->{cantidad} | Estado: $cur->{estado} | Fecha: $cur->{fecha_solicitud}\n";
        $cur = $cur->{next};
    }
}

1;