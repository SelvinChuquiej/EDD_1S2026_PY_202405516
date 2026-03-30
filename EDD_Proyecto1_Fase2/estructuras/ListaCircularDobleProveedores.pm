package estructuras::ListaCircularDobleProveedores; 

use strict;
use warnings;   
use nodos::NodoProveedor;

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

sub find {
    my ($self, $nit) = @_;
    return undef if $self->is_empty();
    
    my $current = $self->{head};
    do {
        return $current if $current->{nit} eq $nit;
        $current = $current->{next};
    } while ($current != $self->{head});
    
    return undef;
}

sub add {
    my ($self, $data) = @_;
    
    if ($self->find($data->{nit})) {
        return; 
    }

    my $nuevo = nodos::NodoProveedor->new($data);
    
    if ($self->is_empty()) {
        $self->{head} = $nuevo;
        $self->{tail} = $nuevo;
        $nuevo->{next} = $nuevo;
        $nuevo->{prev} = $nuevo; 
    } else {
        $nuevo->{prev} = $self->{tail};
        $nuevo->{next} = $self->{head};
        
        $self->{tail}->{next} = $nuevo;
        
        $self->{head}->{prev} = $nuevo;
        
        $self->{tail} = $nuevo;
    }
}

sub delete {
    my ($self, $nit) = @_;
    my $nodo = $self->find($nit);
    return unless $nodo;

    if ($self->{head} == $self->{tail}) {
        $self->{head} = undef;
        $self->{tail} = undef;
    } else {
        $nodo->{prev}->{next} = $nodo->{next};
        $nodo->{next}->{prev} = $nodo->{prev};

        if ($nodo == $self->{head}) {
            $self->{head} = $nodo->{next};
        }
        if ($nodo == $self->{tail}) {
            $self->{tail} = $nodo->{prev};
        }
    }
}

sub list {
    my ($self) = @_;
    my @datos;
    return \@datos if $self->is_empty();
    
    my $current = $self->{head};
    do {
        push @datos, $current;
        $current = $current->{next};
    } while ($current != $self->{head});
    
    return \@datos;
}

sub generar_graphviz {
    my ($self, $ruta_dot, $ruta_png) = @_;
    
    open(my $fh, '>:encoding(UTF-8)', $ruta_dot) or die $!;
    print $fh "digraph ListaCircularDoble {\n";
    print $fh "    rankdir=LR;\n"; 
    print $fh "    node [shape=box, style=filled, fillcolor=lightpink, fontname=\"Arial\"];\n";
    print $fh "    edge [fontname=\"Arial\", fontsize=8];\n";
    print $fh "    label=\"Reporte de Proveedores (Lista Circular Doble)\";\n";

    if (!$self->is_empty()) {
        my $current = $self->{head};
        do {
            my $nit = $current->{nit};
            my $nom = $current->{nombre};
            
            print $fh "    \"$nit\" [label=\"NIT: $nit\\n$nom\"];\n";
            
            my $sig_nit = $current->{next}->{nit};
            print $fh "    \"$nit\" -> \"$sig_nit\" [label=\"next\", color=\"blue\", constraint=true];\n";

            my $prev_nit = $current->{prev}->{nit};
            print $fh "    \"$nit\" -> \"$prev_nit\" [label=\"prev\", color=\"red\", style=\"dashed\", constraint=false];\n";

            $current = $current->{next};
        } while ($current != $self->{head});
    }

    print $fh "}\n";
    close($fh);
    
    system("dot -Gcharset=utf8 -Tpng \"$ruta_dot\" -o \"$ruta_png\"");
}
1;