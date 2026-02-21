package matriz::NodoCabecera;
use strict;
use warnings;

sub new {
    my ($class, $id) = @_;
    my $self = {
        id => $id,    
        next => undef,  
        access => undef,  
    };
    bless $self, $class;
    return $self;
}

1;