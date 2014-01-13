package ObjectDB::Related::OneToMany;

use strict;
use warnings;

use base 'ObjectDB::Related';

our $VERSION = '3.04';

use Scalar::Util ();

sub create_related {
    my $self = shift;
    my ($row) = shift;

    my $meta = $self->{meta};

    my ($from, $to) = %{$meta->map};

    my @params = ($to => $row->column($from));

    my @related =
      @_ == 1 ? ref $_[0] eq 'ARRAY' ? @{$_[0]} : ($_[0]) : ({@_});

    my @objects;
    foreach my $related (@related) {
        if (Scalar::Util::blessed($related)) {
            push @objects, $related->set_columns(@params)->save;
        }
        else {
            push @objects,
              $meta->class->new->set_columns(%$related, @params)->create;
        }
    }

    return @related == 1 ? $objects[0] : @objects;
}

sub find_related {
    my $self   = shift;
    my ($row)  = shift;
    my %params = @_;

    my $meta = $self->meta;

    $params{where} ||= [];

    my ($from, $to) = %{$meta->map};

    return unless defined $row->column($from);

    push @{$params{where}}, ($to => $row->column($from));

    return $meta->class->table->find(%params);
}

sub count_related {
    my $self = shift;
    my ($row) = shift;

    my %params = @_;

    my $meta = $self->meta;

    my ($from, $to) = %{$meta->{map}};

    push @{$params{where}}, ($to => $row->get_column($from));

    if ($meta->{where}) {
        push @{$params{where}}, %{$meta->{where}};
    }

    return $meta->class->table->count(%params);
}

sub update_related {
    my $self = shift;
    my ($row) = shift;

    my %params = @_ == 1 ? %{$_[0]} : @_;

    my $meta = $self->meta;

    my ($from, $to) = %{$meta->map};
    my $where = [$to => $row->get_column($from)];

    push @$where, @{$params{where}} if $params{where};

    return $meta->class->table->update(where => $where, @_);
}

sub delete_related {
    my $self = shift;
    my ($row) = shift;

    my %params = @_;
    $params{where} ||= [];

    my $meta = $self->meta;

    my ($from, $to) = %{$meta->map};

    push @{$params{where}}, ($to => $row->get_column($from));

    return $meta->class->table->delete(%params);
}

1;
