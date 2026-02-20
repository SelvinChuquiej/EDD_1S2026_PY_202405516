package proveedores::ProveedorCircularLinkedList;

use strict;
use warnings;

use proveedores::NodoProveedor;
use constant Nodo => 'proveedores::NodoProveedor';

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

    # evitar duplicados por NIT
    return (0, "Ya existe un proveedor con ese NIT") if $self->buscar_nit($data->{nit});

    my $nodo = Nodo->new($data);

    if ($self->is_empty()) {
        $self->{head} = $nodo;
        $self->{tail} = $nodo;
        $nodo->{next} = $nodo; # circular
        return (1, "Proveedor agregado");
    }

    $nodo->{next} = $self->{head};
    $self->{tail}->{next} = $nodo;
    $self->{tail} = $nodo;

    return (1, "Proveedor agregado");
}

sub buscar_nit {
    my ($self, $nit) = @_;
    return undef if $self->is_empty();

    my $cur = $self->{head};
    do {
        return $cur if $cur->{nit} eq $nit;
        $cur = $cur->{next};
    } while ($cur != $self->{head});

    return undef;
}

sub imprimir {
    my ($self) = @_;
    if ($self->is_empty()) {
        print "No hay proveedores.\n";
        return;
    }

    my $cur = $self->{head};
    do {
        print "NIT: $cur->{nit} | Empresa: $cur->{empresa} | Contacto: $cur->{contacto} | Tel: $cur->{telefono} | Dir: $cur->{direccion}\n";
        print "Entregas:\n";
        $cur->{entregas}->imprimir();
        print "----------------------------------\n";
        $cur = $cur->{next};
    } while ($cur != $self->{head});
}

sub generar_reporte_dot {
    my ($self, $archivo) = @_;
    return if $self->is_empty();

    open(my $fh, '>', $archivo) or die "No se pudo crear DOT";

    print $fh "digraph G {\n";
    print $fh "rankdir=TB;\n";
    print $fh "splines=ortho;\n";
    print $fh "nodesep=0.6;\n";
    print $fh "ranksep=0.8;\n";
    print $fh "node [shape=box, style=rounded, fontname=\"Arial\"];\n";
    print $fh "edge [fontname=\"Arial\"];\n";
    print $fh "{ rank=same; \n";

    my $head = $self->{head};
    my $current = $head;

    do {
        print $fh "\"P_$current\" [label=\"Proveedor\\nNIT: $current->{nit}\\n$current->{empresa}\"];\n";
        $current = $current->{next};
    } while ($current != $head);
    print $fh "}\n"; # fin rank=same

    $current = $head;
    do {
        print $fh "\"P_$current\" -> \"P_$current->{next}\";\n";
        $current = $current->{next};
    } while ($current != $head);

    $current = $head;
    do {
        my $entregas = $current->{entregas};
        my $ehead = $entregas ? $entregas->{head} : undef;
        if ($ehead) {
            my $e = $ehead;
            my $prev = undef;
            while ($e) {
                my $elabel = "Entrega\\nMed: $e->{codigo_med}\\nCant: $e->{cantidad}";
                print $fh "\"E_$e\" [shape=box, style=\"rounded,filled\", fillcolor=\"#E9EEF5\", label=\"$elabel\"];\n";
                if ($prev) {
                    print $fh "\"E_$prev\" -> \"E_$e\" [dir=none];\n"; # línea limpia vertical
                }
                $prev = $e;
                $e = $e->{next};
            }
            print $fh "\"P_$current\" -> \"E_$ehead\" [color=\"#555555\"];\n";
            print $fh "{ rank=same; \"P_$current\"; }\n";
        }
        $current = $current->{next};
    } while ($current != $head);

    print $fh "}\n";
    close($fh);
}
1;