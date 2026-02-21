use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin; 
use Text::CSV;
use POSIX qw(strftime);

use inventario::InventarioDLinkedList;
use solicitudes::SolicitudCircularDLinkedList;
use solicitudes::HistorialLinkedList;
use proveedores::ProveedorCircularLinkedList;
use matriz::MatrizDispersa;

my $INVENTARIO = inventario::InventarioDLinkedList->new();
my $SOLICITUDES = solicitudes::SolicitudCircularDLinkedList->new();
my $HISTORIAL = solicitudes::HistorialLinkedList->new();
my $PROVEEDORES = proveedores::ProveedorCircularLinkedList->new();
my $MATRIZ = matriz::MatrizDispersa->new();

our $ID_SOLICITUD = 0; 

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
            my $username = read_option("Username: ");
            my $password = read_option("Password: ");
            if ($username eq 'admin' && $password eq 'admin') {
                print "Login exitoso.\n";
                menu_admin(); 
                pause();
            } else {
                print "Credenciales incorrectas.\n";
                pause();
            }
        } elsif ($op eq '2') { 
            my $username = read_option("Codigo Departamento: ");
            my $password = read_option("Password: ");
            if ($username eq 'user' && $password eq 'user') {
                print "Login exitoso.\n";
                pause();
                menu_usuario(); 
            } else {
                print "Credenciales incorrectas.\n";
                pause();
            }
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
        } elsif ($op eq '2') { 
            admin_carga_masiva_csv(); 
        } elsif ($op eq '3') {
            admin_gestionar_proveedores();
        } elsif ($op eq '4') { 
            admin_registrar_entrega(); 
        } elsif ($op eq '5') { 
            admin_procesar_solicitudes();
        } elsif ($op eq '6') { 
            $INVENTARIO->imprimir(); 
            pause();
        } elsif ($op eq '7') { 
            admin_consultar_por_medicamento();
        } elsif ($op eq '8') { 
            admin_reportes_graphviz(); 
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
            usuario_ver_historial();
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

    $MATRIZ->insertar({
        laboratorio => $laboratory,
        medicamento => $name,
        codigo_med => $code,
        precio => $price,
        principio_activo => $principle,
    });

    print "Medicamento registrado.\n";
    pause();
}

sub admin_carga_masiva_csv {
    print "Ingrese nombre del archivo CSV: "; chomp(my $file = <STDIN>);
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

        $MATRIZ->insertar({
            laboratorio => $laboratory,
            medicamento => $name,
            codigo_med => $code,
            precio => $price,
            principio_activo => $principle,
        });

        print "Medicamento $code cargado.\n";
    }

    close($fh);
    print "Carga masiva finalizada.\n";
    pause();
}

sub admin_procesar_solicitudes {
    my $sol = $SOLICITUDES->mirar_head();
    my $total = $SOLICITUDES->contar();

    if (!$sol) {
        print "No hay solicitudes pendientes.\n";
        pause();
        return;
    }
    print "Solicitudes pendientes: $total\n";
    print "\n=== Solicitud Pendiente ===\n";
    print "ID: " . ($sol->{codigo_depto} // "N/A") . "\n";
    print "Medicamento: " . ($sol->{codigo_med} // "N/A") . "\n";
    print "Cantidad: " . ($sol->{cantidad} // 0) . "\n";
    print "Prioridad: " . ($sol->{prioridad} // "N/A") . "\n";
    print "Fecha: " . ($sol->{fecha_solicitud} // "N/A") . "\n";
    print "Justificacion: " . ($sol->{justificacion} // "") . "\n";

    print "\n1) Aprobar\n";
    print "2) Rechazar\n";
    print "0) Volver\n";
    my $op = read_option("Opcion: ");
    return if $op eq '0';

    my $id   = $sol->{id};
    my $code = $sol->{codigo_med};
    my $qty  = $sol->{cantidad};

    if ($op eq '1') {
        my ($ok, $msg) = $INVENTARIO->actualizar_stock($code, -$qty);
        if ($ok) {
            $SOLICITUDES->remove_head(); 
            $HISTORIAL->actualizar_estado($id, "aprobada");
            print "Solicitud aprobada. $msg\n";
        } else {
            print "No se pudo aprobar: $msg\n";
        }
        pause();
        return;
    }

    if ($op eq '2') {
        $SOLICITUDES->remove_head();
        $HISTORIAL->actualizar_estado($id, "rechazada");
        print "Solicitud rechazada.\n";
        pause();
        return;
    }

    print "Opcion invalida.\n";
    pause();
}

sub admin_gestionar_proveedores {
    while (1) {
        print "\n=== Gestionar Proveedores ===\n";
        print "1) Registrar proveedor\n";
        print "2) Ver proveedores\n";
        print "0) Volver\n";

        my $op = read_option("Opcion: ");
        if ($op eq '1') {
            admin_registrar_proveedor();
        }
        elsif ($op eq '2') {
            $PROVEEDORES->imprimir();
            pause();
        }
        elsif ($op eq '0') {
            return;
        }
        else {
            print "Opcion invalida.\n";
            pause();
        }
    }
}

sub admin_registrar_proveedor {
    
    print "\n=== Registrar Proveedor ===\n";
    print "NIT: "; chomp(my $nit = <STDIN>);
    print "Nombre empresa: "; chomp(my $empresa = <STDIN>);
    print "Contacto principal: "; chomp(my $contacto = <STDIN>);
    print "Telefono: "; chomp(my $telefono = <STDIN>);
    print "Direccion: "; chomp(my $direccion = <STDIN>);

    my ($ok, $msg) = $PROVEEDORES->agregar({
        nit => $nit,
        empresa => $empresa,
        contacto => $contacto,
        telefono => $telefono,
        direccion => $direccion,
    });

    print "$msg\n";
    pause();
}

sub admin_registrar_entrega {

    print "\n=== Registrar Entrega ===\n";
    print "NIT del proveedor: ";chomp(my $nit = <STDIN>);
    my $proveedor = $PROVEEDORES->buscar_nit($nit);
    if (!$proveedor) {
        print "Proveedor no encontrado.\n";
        pause();
        return;
    }
    print "Fecha (YYYY-MM-DD): "; chomp(my $fecha = <STDIN>);
    print "Numero de factura: "; chomp(my $factura = <STDIN>);
    print "Codigo del medicamento (MED000): "; chomp(my $codigo_med = <STDIN>);
    my $med = $INVENTARIO->buscar_codigo($codigo_med);
    if (!$med) {
        print "Error: El medicamento no existe en el inventario.\n";
        pause();
        return;
    }
    print "Cantidad entregada: "; chomp(my $cantidad = <STDIN>);

    $proveedor->{entregas}->agregar({
        fecha => $fecha,
        factura => $factura,
        codigo_med => $codigo_med,
        cantidad => $cantidad,
    });

    my ($ok, $msg) = $INVENTARIO->actualizar_stock($codigo_med, $cantidad);
    if ($ok) {
        print "Entrega registrada correctamente.\n";
    } else {
        print "Entrega registrada pero: $msg\n";
    }

    pause();
}

sub admin_consultar_por_medicamento {
    print "\n=== Consultar por Medicamento (Comparar Laboratorios) ===\n";
    my $nombre = read_option("Nombre del medicamento: ");
    $MATRIZ->consultar_por_medicamento($nombre, $INVENTARIO);
    pause();
}

sub admin_reportes_graphviz {
    print "\n=== Reportes Graphviz ===\n";
    print "1) Inventario\n";
    print "2) Solicitudes Pendientes\n";
    print "3) Proveedores y Entregas\n";
    print "0) Volver\n";

    my $op = read_option("Opcion: ");
    if ($op eq '1') {
        $INVENTARIO->generar_reporte_dot("inventario/inventario.dot");
        print "Reporte del inventario generado como 'inventario.dot'.\n";
        system("dot -Tpng inventario/inventario.dot -o inventario/inventario.png");
        pause();
    } elsif ($op eq '2') {
        $SOLICITUDES->generar_reporte_dot("solicitudes/solicitudes.dot");
        print "Reporte de solicitudes generado como 'solicitudes.dot'.\n";
        system("dot -Tpng solicitudes/solicitudes.dot -o solicitudes/solicitudes.png"); 
        pause();
    } elsif ($op eq '3') {
        $PROVEEDORES->generar_reporte_dot("proveedores/proveedores.dot");
        print "Reporte de proveedores generado como 'proveedores.dot'.\n";
        system("dot -Tpng proveedores/proveedores.dot -o proveedores/proveedores.png"); 
        pause();
    } elsif ($op eq '0') {
        return;
    } else {
        print "Opcion invalida.\n";
        pause();
    }
}

#---------------------------------------- Usuario ----------------------------------------

sub usuario_consultar_disponibilidad {

    print "\n=== Consultar Disponibilidad ===\n";
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

    print "\n=== Solicitar Reabastecimiento ===\n";
    print "Codigo de medicamento: "; chomp(my $codigo_med = <STDIN>);
    my $med = $INVENTARIO->buscar_codigo($codigo_med);
    if (!$med) {
        print "Error: El medicamento no existe en el inventario.\n";
        pause();
        return;
    }
    print "Cantidad solicitada: "; chomp(my $cantidad = <STDIN>);
    print "Prioridad (urgente/alta/media/baja): "; chomp(my $prioridad = <STDIN>);
    print "Justificacion: "; chomp(my $justificacion = <STDIN>);
    my $fecha = strftime("%Y-%m-%d", localtime);

    my $id = ++$ID_SOLICITUD;  
    my $data = {
        id => $id,
        codigo_depto => "user",
        codigo_med => $codigo_med,
        cantidad => $cantidad,
        prioridad => $prioridad,
        justificacion => $justificacion,
        fecha_solicitud => $fecha,
        estado => "pendiente"
    };

    $HISTORIAL->agregar($data);
    $SOLICITUDES->agregar($data);

    print "Solicitud creada correctamente.\n";
    pause();
}

sub usuario_ver_historial {
    print "\n=== Historial de Solicitudes ===\n";
    if ($HISTORIAL->is_empty()) {
        print "No hay solicitudes registradas.\n";
    } else {
        $HISTORIAL->imprimir_todo();
    }
    pause();
}

menu_principal();
print "Saliendo...\n";