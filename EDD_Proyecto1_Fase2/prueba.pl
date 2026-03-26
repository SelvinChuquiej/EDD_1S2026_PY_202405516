use strict;
use warnings;
use lib '.';
use estructuras::ArbolAVLUsuario;
use json::CargaUsuario;

# 1. Crear la instancia del árbol
my $mi_avl = estructuras::ArbolAVLUsuario->new();

# 2. Cargar el JSON (asegúrate de tener un archivo usuarios.json de prueba)
my $insertados = json::CargaUsuario::cargar_desde_archivo("usuarios.json", $mi_avl);
print "Se cargaron $insertados usuarios exitosamente.\n";

# 3. Probar la búsqueda (simulando un Login)
my $colegio_prueba = "COL-10245"; # Cambia esto por uno que esté en tu JSON
my $usuario_encontrado = $mi_avl->buscar($colegio_prueba);

if (defined $usuario_encontrado) {
    print "Usuario encontrado: " . $usuario_encontrado->{nombre_completo} . "\n";
    print "Contraseña registrada: " . $usuario_encontrado->{contrasena} . "\n";
} else {
    print "Usuario no encontrado en el AVL.\n";
}