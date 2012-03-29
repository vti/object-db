package ObjectDB::Meta::Relationship::Proxy;

use strict;
use warnings;

use base 'ObjectDB::Meta::Relationship';

sub proxy_key { $_[0]->{proxy_key} }

1;
