package estructuras::LZW;

use strict;
use warnings;
use utf8;
use Encode qw(encode decode);

use constant MAX_BITS  => 12;
use constant MAX_SIZE  => (1 << MAX_BITS);
use constant INIT_SIZE => 256; 

sub comprimir {
    my ($clase, $texto) = @_;
    my %diccionario = map { chr($_) => $_ } (0 .. INIT_SIZE - 1);
    my $siguiente = INIT_SIZE;
    my $buffer = "";
    my @codigos;

    my $texto_bytes = encode('UTF-8', $texto);

    for my $c (split //, $texto_bytes) {
        my $candidato = $buffer . $c;
        if (exists $diccionario{$candidato}) {
            $buffer = $candidato;
        } else {
            push @codigos, $diccionario{$buffer};
            if ($siguiente < MAX_SIZE) {
                $diccionario{$candidato} = $siguiente++;
            }
            $buffer = $c;
        }
    }
    push @codigos, $diccionario{$buffer} if length($buffer) > 0;

    return empaquetar_codigos(\@codigos);
}

sub descomprimir {
    my ($clase, $datos_binarios) = @_;
    my @codigos = desempaquetar_codigos($datos_binarios);
    return "" unless @codigos;

    my %diccionario = map { $_ => chr($_) } (0 .. INIT_SIZE - 1);
    my $siguiente = INIT_SIZE;

    my $prev = $diccionario{shift @codigos};
    my $resultado = $prev;

    for my $codigo (@codigos) {
        my $entrada;
        if (exists $diccionario{$codigo}) {
            $entrada = $diccionario{$codigo};
        } else {
            $entrada = $prev . substr($prev, 0, 1);
        }
        $resultado .= $entrada;

        if ($siguiente < MAX_SIZE) {
            $diccionario{$siguiente++} = $prev . substr($entrada, 0, 1);
        }
        $prev = $entrada;
    }

    return decode('UTF-8', $resultado);
}

sub empaquetar_codigos { 
    my ($codigos_ref) = @_;
    my $resultado = pack("N", scalar @$codigos_ref);
    my ($buffer_bits, $bits_en_buffer, $dict_size) = (0, 0, INIT_SIZE);

    for my $codigo (@$codigos_ref) {
        my $bits_nec = bits_necesarios($dict_size);
        $buffer_bits = ($buffer_bits << $bits_nec) | $codigo;
        $bits_en_buffer += $bits_nec;

        while ($bits_en_buffer >= 8) {
            $bits_en_buffer -= 8;
            $resultado .= chr(($buffer_bits >> $bits_en_buffer) & 0xFF);
            $buffer_bits &= (1 << $bits_en_buffer) - 1;
        }
        $dict_size++ if $dict_size < MAX_SIZE;
    }

    if ($bits_en_buffer > 0) {
        $resultado .= chr(($buffer_bits << (8 - $bits_en_buffer)) & 0xFF);
    }
    return $resultado;
}

sub desempaquetar_codigos {
    my ($datos) = @_;
    return () if length($datos) < 4;

    my $num_codigos = unpack("N", substr($datos, 0, 4));
    return () unless $num_codigos;

    my $bits_str = unpack("B*", substr($datos, 4));
    my @codigos;
    my ($pos, $dict_size) = (0, INIT_SIZE);

    for (1 .. $num_codigos) {
        my $bits_nec = bits_necesarios($dict_size);
        last if ($pos + $bits_nec) > length($bits_str);
        
        push @codigos, oct("0b" . substr($bits_str, $pos, $bits_nec));
        $pos += $bits_nec;
        $dict_size++ if $dict_size < MAX_SIZE;
    }
    return @codigos;
}

sub bits_necesarios {
    my ($dict_size) = @_;
    my $bits = 8;
    $bits++ while ((1 << $bits) < $dict_size && $bits < MAX_BITS);
    return $bits;
}

1;