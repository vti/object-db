package ObjectDB::SQL;

use strict;
use warnings;

use overload '""' => sub { shift->to_string }, fallback => 1;

use ObjectDB::SQL::Quoter;
use ObjectDB::SQL::ColumnParser;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    $self->{quoter}        ||= ObjectDB::SQL::Quoter->new;
    $self->{column_parser} ||= ObjectDB::SQL::ColumnParser->new;

    $self->{bind} = [];

    return $self;
}

sub bind {
    my $self = shift;

    return $self->{bind};
}

sub _parse_column {
    my $self = shift;

    return $self->{column_parser}->parse_column(@_);
}

sub _quote_column {
    my $self = shift;
    my ($column, $prefix) = @_;

    $prefix ||= $self->{prefix};

    return $self->{quoter}->quote_column($column, $prefix);
}

sub _prefix_column {
    my $self = shift;
    my ($column, $prefix) = @_;

    return $self->{quoter}->prefix_column($column, $prefix);
}

1;
