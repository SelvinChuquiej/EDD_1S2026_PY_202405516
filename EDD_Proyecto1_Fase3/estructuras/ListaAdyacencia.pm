package estructuras::ListaAdyacencia;

use strict;
use warnings;

use nodos::NodoLista;

sub new {
    my ($class) = @_;
    my $self = {
        cabeza   => undef, 
        tamanio  => 0,     
    };
    bless $self, $class;
    return $self;
}

sub esta_vacia {
    my ($self) = @_;
    return !defined($self->{cabeza}) ? 1 : 0;
}

sub get_tamanio {
    return $_[0]->{tamanio};
}

sub get_cabeza {
    return $_[0]->{cabeza};
}

sub agregar {
    my ($self, $nodo_grafo) = @_;
    my $nuevo_nodo = nodos::NodoLista->new($nodo_grafo);

    if ($self->esta_vacia()) {
        $self->{cabeza} = $nuevo_nodo;
    } else {
        my $actual = $self->{cabeza};
        while (defined($actual->get_siguiente())) {
            $actual = $actual->get_siguiente();
        }
        $actual->set_siguiente($nuevo_nodo);
    }
    $self->{tamanio}++;
}

sub eliminar {
    my ($self, $id) = @_;
    return 0 if $self->esta_vacia();

    if ($self->{cabeza}->get_data()->get_id() eq $id) {
        $self->{cabeza} = $self->{cabeza}->get_siguiente();
        $self->{tamanio}--;
        return 1;
    }

    my $previo = $self->{cabeza};
    my $actual = $self->{cabeza}->get_siguiente();

    while (defined($actual)) {
        if ($actual->get_data()->get_id() eq $id) {
            $previo->set_siguiente($actual->get_siguiente());
            $self->{tamanio}--;
            return 1;
        }
        $previo = $actual;
        $actual = $actual->get_siguiente();
    }
    return 0;
}

1;