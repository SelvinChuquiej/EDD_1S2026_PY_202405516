package nodos::NodoGrafo;

use strict;
use warnings;

use estructuras::ListaAdyacencia;

sub new {
    my ($class, $id, $data) = @_;
    my $self = {
        id => $id,  
        data => $data,    
        lista_adyacencia => estructuras::ListaAdyacencia->new(),     
    };
    bless $self, $class;
    return $self;
}

sub get_id {
    return $_[0]->{id};
}

sub get_data {
    return $_[0]->{data};
}

sub set_data {
    my ($self, $nuevo_data) = @_;
    $self->{data} = $nuevo_data;
}

sub get_lista_adyacencia {
    return $_[0]->{lista_adyacencia};
}

sub agregar_vecino {
    my ($self, $nodo_grafo) = @_;
    $self->{lista_adyacencia}->agregar($nodo_grafo);
}

sub eliminar_vecino {
    my ($self, $id) = @_;
    return $self->{lista_adyacencia}->eliminar($id);
}

1;