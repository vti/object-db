package ObjectDB::Related::OneToOne;

use strict;
use warnings;

use base 'ObjectDB::Related::ManyToOne';

our $VERSION = '3.03';

use Scalar::Util ();

sub create_related {
    my $self = shift;
    my ($row) = shift;
    my @related =
      @_ == 1 ? ref $_[0] eq 'ARRAY' ? @{$_[0]} : ($_[0]) : ({@_});

    if (@related > 1) {
        Carp::croak('cannot create multiple related objects in one to one');
    }

    my $meta = $self->{meta};

    my ($from, $to) = %{$meta->map};

    my @where = ($to => $row->column($from));

    if ($meta->class->find(first => 1, where => \@where)) {
        Carp::croak('Related object is already created');
    }

    my $related = $related[0];
    if (!Scalar::Util::blessed($related)) {
        $related = $meta->class->new(%$related);
    }
    $related->set_columns(@where);
    return $related->save;
}

sub update_related {
    my $self   = shift;
    my ($row)  = shift;
    my %params = @_ == 1 ? %{$_[0]} : @_;

    my $meta = $self->meta;

    my ($from, $to) = %{$meta->map};
    my $where = [$to => $row->get_column($from)];

    return $meta->class->table->update(set => $params{set});
}

sub delete_related {
    my $self = shift;
    my ($row) = shift;

    my $meta = $self->meta;

    my ($from, $to) = %{$meta->map};
    my $where = [$to => $row->get_column($from)];

    return $meta->class->table->delete();
}

1;
