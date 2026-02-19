use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin; 
use Text::CSV;

use inventario::DLinkedList;

my $INVENTARIO = inventario::DLinkedList->new();

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
            print "Opción inválida.\n"; pause();
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
        }elsif ($op eq '3') { 
            $INVENTARIO->imprimir(); 
        }
        else { print "Opcion invalida.\n"; pause(); }
    }
}

sub menu_usuario {

    while (1) {
        print "\n--- Menu Usuario Departamental ---\n";
        print "1) Consultar Disponibilidad de Medicamentos\n";
        print "2) Solicitar Reabastecimiento\n";
        print "3) Ver Historial de Solicitudes\n";
        print "0) Cerrar sesión\n";
        my $op = read_option("Opcion: : ");

        if($op eq '1') { 
            print "Funcionalidad no implementada aun.\n";
        } else { 
            print "Opcion invalida.\n"; pause(); 
        }
    }
}

sub admin_registrar_medicamento { 
    print "Registrar medicamento\n"; 
    print "Código: (MED000)"; chomp(my $code = <STDIN>);
    if ($INVENTARIO->bucar_codigo($code)) {
        print "Error: Código ya existe.\n"; pause();
        return;
    }
    print "Nombre: "; chomp(my $name = <STDIN>);
    print "Principio Activo: "; chomp(my $principle = <STDIN>);
    print "Laboratorio: "; chomp(my $laboratory = <STDIN>);
    print "Stock: "; chomp(my $stock = <STDIN>);
    print "Fecha de Vencimiento (YYYY-MM-DD): "; chomp(my $expiration = <STDIN>);
    print "Precio: "; chomp(my $price = <STDIN>);
    print "Nivel Mínimo: "; chomp(my $min_level = <STDIN>);

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
}

sub carga_masiva_csv {
    print "Ingrese nombre del archivo CSV: ";
    chomp(my $file = <STDIN>);
    open(my $fh, "<", $file) or die "No se pudo abrir el archivo.\n";
    my $csv = Text::CSV->new({ binary => 1 });
    $csv->getline($fh);
    while (my $row = $csv->getline($fh)) {
        my ($code, $name, $principle, $laboratory, $stock, $expiration, $price, $min_level) = @$row;
        next if $INVENTARIO->bucar_codigo($code);
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

        print "Medicamento $code cargado.\n";
    }

    close($fh);
    print "Carga masiva finalizada.\n";
    pause();
}


menu_principal();
print "Saliendo...\n";
