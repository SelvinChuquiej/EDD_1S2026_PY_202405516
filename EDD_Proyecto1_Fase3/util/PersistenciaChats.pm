package util::PersistenciaChats;

use strict;
use warnings;
use estructuras::LZW;

sub cargar_historial {
    my ($id_usuario, $context) = @_;
    $context->{mensajes_globales} //= [];

    my $ruta = "chats/$id_usuario.lzw";
    return unless -e $ruta;

    open(my $fh, '<:raw', $ruta) or return;
    local $/;
    my $binario = <$fh>;
    close($fh);

    return if $binario eq "";

    my $texto_descomprimido = estructuras::LZW->descomprimir($binario);

    my @lineas = split /\n/, $texto_descomprimido;

    foreach my $linea (@lineas) {
        my ($remitente, $receptor, $fecha, $contenido) = split /\|/, $linea, 4;
        next unless defined $contenido;

        # Evitar duplicados en memoria si ya se habían cargado
        my $existe = 0;
        foreach my $msg (@{$context->{mensajes_globales}}) {
            if ($msg->{remitente} eq $remitente && $msg->{receptor} eq $receptor && $msg->{fecha} eq $fecha && $msg->{contenido} eq $contenido) {
                $existe = 1;
                last;
            }
        }

        if (!$existe) {
            push @{$context->{mensajes_globales}}, {
                remitente => $remitente,
                receptor  => $receptor,
                fecha     => $fecha,
                contenido => $contenido
            };
        }
    }
}

sub guardar_historial {
    my ($id_usuario, $context) = @_;
    return unless defined $context->{mensajes_globales};

    # Crear carpeta chats/ si no existe
    mkdir "chats" unless -d "chats";
    my $ruta = "chats/$id_usuario.lzw";

    # 1. Serializamos todo el historial del usuario a una cadena de texto
    my $texto_a_comprimir = "";
    foreach my $msg (@{$context->{mensajes_globales}}) {
        # Solo guardamos los mensajes donde este usuario participa (Remitente o Receptor)
        if ($msg->{remitente} eq $id_usuario || $msg->{receptor} eq $id_usuario) {
            my $cont = $msg->{contenido};
            $cont =~ s/\n/ /g; # Limpiamos saltos de línea para no romper el formato
            $cont =~ s/\|/-/g; # Limpiamos pipes
            
            $texto_a_comprimir .= "$msg->{remitente}|$msg->{receptor}|$msg->{fecha}|$cont\n";
        }
    }

    return if $texto_a_comprimir eq "";

    # 2. Comprimimos la cadena completa usando LZW
    my $binario = estructuras::LZW->comprimir($texto_a_comprimir);

    # 3. Guardamos el binario sobrescribiendo el archivo anterior
    open(my $fh, '>:raw', $ruta) or die "No se pudo crear $ruta: $!";
    print $fh $binario;
    close($fh);
}

1;