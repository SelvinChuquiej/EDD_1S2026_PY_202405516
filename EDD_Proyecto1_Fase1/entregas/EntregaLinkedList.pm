package entregas::EntregaLinkedList;

use strict;
use warnings;

use entregas::NodoEntrega;
use constant Nodo => 'entregas::NodoEntrega';

sub new {
    my ($class) = @_;
    my $self = { head => undef, tail => undef };
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

    if ($self->is_empty()) {
        $self->{head} = $nodo;
        $self->{tail} = $nodo;
        return;
    }
    $self->{tail}->{next} = $nodo;
    $self->{tail} = $nodo;
}

sub imprimir {
    my ($self) = @_;
    if ($self->is_empty()) {
        print "  (sin entregas)\n";
        return;
    }

    my $cur = $self->{head};
    while ($cur) {
        print "  Fecha: $cur->{fecha} | Factura: $cur->{factura} | Med: $cur->{codigo_med} | Cant: $cur->{cantidad}\n";
        $cur = $cur->{next};
    }
}

1;