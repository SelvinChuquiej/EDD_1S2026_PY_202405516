package nodos::SlotHash;

use strict;
use warnings;

sub new {
    my ($class, $indice) = @_;
    my $self = {
        indice => $indice,
        cabeza_lista => undef, 
        next_slot => undef 
    };
    bless $self, $class;
    return $self;
}

1;