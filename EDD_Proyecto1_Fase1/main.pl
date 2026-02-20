use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin; 
use Text::CSV;
use POSIX qw(strftime);

use inventario::DLinkedList;
use solicitudes::CircularDLinkedList;

my $INVENTARIO = inventario::DLinkedList->new();
my $SOLICITUDES = solicitudes::CircularDLinkedList->new();

sub read_option {
    my ($msg) = @_;
    print $msg;
    chomp(my $opt = <STDIN>);
    return $opt;
}

sub pause {
    print "\nPresiona ENTER para continuar...";
    <STDIN>;
}

sub menu_principal {
    while (1) {
        print "\n=== EDD MedTrack ===\n";
        print "1) Administrador\n";
        print "2) Usuario Departamental\n";
        print "0) Salir\n";

        my $op = read_option("Opcion: ");

        if ($op eq '1') { 
            menu_admin(); 
        } elsif ($op eq '2') { 
            menu_usuario();
        } elsif ($op eq '0') { 
            last; 
        } else { 
            print "Opcion invalida.\n"; pause();
        }
    }
}

sub menu_admin {
    while (1) {
        print "\n--- Menu Administrador ---\n";
        print "1) Registrar Medicamento\n";
        print "2) Carga Masiva (CSV)\n";
        print "3) Gestionar Proveedores\n";
        print "4) Registrar Entrega de Proveedor\n";
        print "5) Procesar Solicitudes de Reabastecimiento\n";
        print "6) Visualizar Inventario Completo\n";
        print "7) Consultar Inventario por Laboratorio/Medicina (Matriz dispersa)\n";
        print "8) Reportes Graphviz\n";
        print "0) Volver\n";

        my $op = read_option("Opcion: ");

        if ($op eq '1') { 
            admin_registrar_medicamento(); 
        }elsif ($op eq '2') { 
            carga_masiva_csv(); 
        }elsif ($op eq '6') { 
            $INVENTARIO->imprimir(); 
            pause();
        }elsif ($op eq '5') { 
            admin_procesar_solicitudes();
        } elsif($op eq '0') { 
            last; 
        } else { print "Opcion invalida.\n"; pause(); }
    }
}

sub menu_usuario {
    while (1) {
        print "\n--- Menu Usuario Departamental ---\n";
        print "1) Consultar Disponibilidad de Medicamentos\n";
        print "2) Solicitar Reabastecimiento\n";
        print "3) Ver Historial de Solicitudes\n";
        print "0) Cerrar sesion\n";
        my $op = read_option("Opcion: ");

        if($op eq '1') { 
            usuario_consultar_disponibilidad();
        } elsif($op eq '2') { 
            usuario_solicitar_reabastecimiento();
        } elsif($op eq '3') { 
            print "Funcionalidad no implementada aun.\n";
        } elsif($op eq '0') { 
            last; 
        } else { 
            print "Opcion invalida.\n"; pause(); 
        }
    }
}

#---------------------------------------- Admin ----------------------------------------
sub admin_registrar_medicamento { 
    print "Registrar medicamento\n"; 
    print "Codigo (MED000): "; chomp(my $code = <STDIN>);
    if ($INVENTARIO->buscar_codigo($code)) {
        print "Error: Codigo ya existe.\n"; pause();
        return;
    }
    print "Nombre: "; chomp(my $name = <STDIN>);
    print "Principio Activo: "; chomp(my $principle = <STDIN>);
    print "Laboratorio: "; chomp(my $laboratory = <STDIN>);
    print "Stock: "; chomp(my $stock = <STDIN>);
    print "Fecha de Vencimiento (YYYY-MM-DD): "; chomp(my $expiration = <STDIN>);
    print "Precio: "; chomp(my $price = <STDIN>);
    print "Nivel Minimo: "; chomp(my $min_level = <STDIN>);

    $INVENTARIO->agregar({
        code => $code,
        name => $name,
        principle => $principle,
        laboratory => $laboratory,
        stock => $stock,
        expiration => $expiration,
        price => $price,
        min_level => $min_level
    });
    print "Medicamento registrado.\n";
    pause();
}

sub carga_masiva_csv {
    print "Ingrese nombre del archivo CSV: ";
    chomp(my $file = <STDIN>);
    open(my $fh, "<", $file) or die "No se pudo abrir el archivo.\n";
    my $csv = Text::CSV->new({ binary => 1 });
    $csv->getline($fh);
    while (my $row = $csv->getline($fh)) {
        my ($code, $name, $principle, $laboratory, $price, $stock, $expiration, $min_level) = @$row;
        next if $INVENTARIO->buscar_codigo($code);
        $INVENTARIO->agregar({
            code => $code,
            name => $name,
            principle => $principle,
            laboratory => $laboratory,
            price => $price,
            stock => $stock,
            expiration => $expiration,
            min_level => $min_level
        });

        print "Medicamento $code cargado.\n";
    }

    close($fh);
    print "Carga masiva finalizada.\n";
    pause();
}

sub admin_procesar_solicitudes {
    my $sol = $SOLICITUDES->mirar_head();

    if (!$sol) {
        print "No hay solicitudes pendientes.\n";
        pause();
        return;
    }

    print "\n=== Solicitud Pendiente ===\n";
    print "Depto: " . ($sol->{codigo_depto} // "N/A") . "\n";
    print "Medicamento: " . ($sol->{codigo_med} // "N/A") . "\n";
    print "Cantidad: " . ($sol->{cantidad} // 0) . "\n";
    print "Prioridad: " . ($sol->{prioridad} // "N/A") . "\n";
    print "Fecha: " . ($sol->{fecha_solicitud} // "N/A") . "\n";
    print "Justificacion: " . ($sol->{justificacion} // "") . "\n";

    print "\n1) Aprobar\n";
    print "2) Rechazar\n";
    print "0) Volver\n";

    my $op = read_option("Opcion: ");

    if ($op eq '1') {
        my $code = $sol->{codigo_med};
        my $qty  = $sol->{cantidad};

        my ($ok, $msg) = $INVENTARIO->actualizar_stock($code, -$qty);

        if ($ok) {
            $sol->{estado} = "aprobada";  
            $SOLICITUDES->remove_head();
            print "Solicitud aprobada. $msg\n";
        } else {
            print "No se pudo aprobar: $msg\n";
        }
        pause();
        return;
    }

    if ($op eq '2') {
        $sol->{estado} = "rechazada";
        $SOLICITUDES->remove_head();
        print "Solicitud rechazada.\n";
        pause();
        return;
    }
    return;
}

#---------------------------------------- Usuario ----------------------------------------
sub usuario_consultar_disponibilidad {
    print "\nIngrese codigo de medicamento: ";
    chomp(my $code = <STDIN>);
    my $node = $INVENTARIO->buscar_codigo($code);
    if ($node) {
        print "Medicamento: $node->{name}\n";
        print "Stock disponible: $node->{stock}\n";
        print "Fecha de vencimiento: $node->{expiration}\n";
    } else {
        print "Medicamento no encontrado.\n";
    }
    pause();
}

sub usuario_solicitar_reabastecimiento {

    print "Codigo de departamento: "; chomp(my $codigo_depto = <STDIN>);
    print "Codigo de medicamento: "; chomp(my $codigo_med = <STDIN>);
    print "Cantidad solicitada: "; chomp(my $cantidad = <STDIN>);
    print "Prioridad (urgente/alta/media/baja): "; chomp(my $prioridad = <STDIN>);
    print "Justificacion: "; chomp(my $justificacion = <STDIN>);
    my $fecha = strftime("%Y-%m-%d", localtime);

    $SOLICITUDES->agregar({
        codigo_depto => $codigo_depto,
        codigo_med => $codigo_med,
        cantidad => $cantidad,
        prioridad => $prioridad,
        justificacion => $justificacion,
        fecha_solicitud => $fecha,
        estado => "pendiente"
    });

    print "Solicitud creada correctamente.\n";
    pause();
}


menu_principal();
print "Saliendo...\n";
