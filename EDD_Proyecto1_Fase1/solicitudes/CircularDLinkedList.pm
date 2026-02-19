package solicitudes::CircularDLinkedList;

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
    my $nuevo_nodo = Nodo->new($data);

    #Lista vacía
    if ($self->is_empty()) { 
        $self->{head} = $nuevo_nodo;
        $self->{tail} = $nuevo_nodo;
        $nuevo_nodo->{next} = $nuevo_nodo; 
        $nuevo_nodo->{prev} = $nuevo_nodo;
        return;
    }

    $nuevo_nodo->{prev} = $self->{tail};
    $nuevo_nodo->{next} = $self->{head};

    $self->{tail}->{next} = $nuevo_nodo;
    $self->{head}->{prev} = $nuevo_nodo;

    $self->{tail} = $nuevo_nodo;
}

sub imprimir {
    my ($self) = @_;
    return if $self->is_empty();

    my $current = $self->{head};
    do {
        print "$current->{codigo_med}\n";
        $current = $current->{next};
    } while ($current != $self->{head});
}

sub remove_head {
    my ($self) = @_;
    return undef if $self->is_empty();

    my $removed = $self->{head};
    # Caso: solo 1 nodo
    if ($self->{head} == $self->{tail}) {
        $self->{head} = undef;
        $self->{tail} = undef;

        $removed->{next} = undef;
        $removed->{prev} = undef;

        return $removed;
    }

    # Caso: más de 1 nodo
    my $new_head = $removed->{next};
    $self->{tail}->{next} = $new_head;
    $new_head->{prev} = $self->{tail};
    $self->{head} = $new_head;

    $removed->{next} = undef;
    $removed->{prev} = undef;

    return $removed;
}

sub mirar_head {
    my ($self) = @_;
    return undef if $self->is_empty();
    return $self->{head};
}

1;