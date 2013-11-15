package ObjectDB::Meta::Relationship::ManyToOne;

use strict;
use warnings;

use base 'ObjectDB::Meta::Relationship';

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{join} ||= 'left';

    return $self;
}

sub type {'many to one'}

sub to_source {
    my $self = shift;
    my (%options) = @_;

    my $name      = $self->name;
    my $table     = $self->orig_class->meta->table;
    my $rel_table = $self->class->meta->table;

    my ($from, $to) = %{$self->{map}};

    my $constraint = ["$table.$from" => {-col => "$name.$to"}];

    my @columns;
    if ($options{columns}) {
        $options{columns} = [$options{columns}]
          unless ref $options{columns} eq 'ARRAY';
        @columns = @{$options{columns}};
        unshift @columns, $self->class->meta->get_primary_key;
    }
    else {
        @columns = $self->class->meta->get_columns;
    }

    @columns =
      map { ref $_ ? {%$_, name => $_->{name}} : $_ }
      @columns;

    return {
        table      => $rel_table,
        as         => $name,
        join       => $self->{join},
        constraint => $constraint,
        columns    => [@columns]
    };
}

1;
