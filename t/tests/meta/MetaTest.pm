package MetaTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use ObjectDB::Meta;

sub require_table : Test {
    like(
        exception { ObjectDB::Meta->new(class => 'Foo') },
        qr/Table is required when building meta/
    );
}

sub require_class : Test {
    like(
        exception { ObjectDB::Meta->new(table => 'foo') },
        qr/Class is required when building meta/
    );
}

sub has_class : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    is($meta->get_class, 'Foo');
}

sub has_table_name : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    is($meta->get_table, 'foo');
}

sub has_columns : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    $meta->set_columns(qw/foo bar baz/);

    is_deeply([$meta->get_columns], [qw/foo bar baz/]);
}

sub add_columns : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    $meta->set_columns(qw/foo bar baz/);
    $meta->add_column('bbb');

    is_deeply([$meta->get_columns], [qw/foo bar baz bbb/]);
}

sub throw_when_adding_existing_column : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    $meta->set_columns(qw/foo bar baz/);

    like(
        exception { $meta->add_column('foo') },
        qr/Column 'foo' already exists/
    );
}

sub has_primary_key : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    $meta->set_columns(qw/foo bar baz/);
    $meta->set_primary_key('foo');

    is_deeply([$meta->get_primary_key], [qw/foo/]);
}

sub die_when_setting_primary_key_on_unknown_column : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    $meta->set_columns(qw/foo bar baz/);

    like(
        exception { $meta->set_primary_key('unknown') },
        qr/Unknown column 'unknown'/
    );
}

sub has_unique_keys : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    $meta->set_columns(qw/foo bar baz/);
    $meta->set_unique_keys('foo');

    is_deeply([$meta->get_unique_keys], [['foo']]);
}

sub has_unique_keys_2 : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    $meta->set_columns(qw/foo bar baz/);
    $meta->set_unique_keys('foo', ['bar']);

    is_deeply([$meta->get_unique_keys], [['foo'], ['bar']]);
}

sub has_unique_keys_multi : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    $meta->set_columns(qw/foo bar baz/);
    $meta->set_unique_keys('foo', ['bar', 'baz']);

    is_deeply([$meta->get_unique_keys], [['foo'], ['bar', 'baz']]);
}

#sub die_when_setting_primary_key_on_unknown_column : Test {
#    my $self = shift;
#
#    my $meta = $self->_build_meta;
#
#    $meta->set_columns(qw/foo bar baz/);
#
#    like(
#        exception { $meta->set_primary_key('unknown') },
#        qr/Unknown column 'unknown'/
#    );
#}

sub has_auto_increment_key : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    $meta->set_columns(qw/foo bar baz/);
    $meta->set_auto_increment('foo');

    is_deeply($meta->get_auto_increment, 'foo');
}

sub die_when_setting_auto_increment_on_unknown_column : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    $meta->set_columns(qw/foo bar baz/);

    like(
        exception { $meta->set_auto_increment('unknown') },
        qr/Unknown column 'unknown'/
    );
}

sub return_regular_columns : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    $meta->set_columns(qw/foo bar baz/);
    $meta->set_primary_key('foo');

    is_deeply([$meta->get_regular_columns], ['bar', 'baz']);
}

sub check_is_column : Test(2) {
    my $self = shift;

    my $meta = $self->_build_meta;

    $meta->set_columns(qw/foo bar baz/);

    ok($meta->is_column('foo'));
    ok(!$meta->is_column('unknown'));
}

sub add_relationship : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    $meta->set_columns(qw/foo bar baz/);
    $meta->set_primary_key('foo');

    $meta->add_relationship(foo => {type => 'one to one'});

    ok($meta->get_relationship('foo'));
}

sub is_relationship : Test {
    my $self = shift;

    my $meta = $self->_build_meta;

    $meta->set_columns(qw/foo bar baz/);
    $meta->set_primary_key('foo');

    $meta->add_relationship(foo => {type => 'one to one'});

    ok($meta->is_relationship('foo'));
}

#sub add_relationships : Test {
#    my $self = shift;
#
#    my $meta = $self->_build_meta;
#
#    $meta->set_columns(qw/foo bar baz/);
#
#    $meta->belongs_to('foo');
#
#    $meta->add_relationships(bar => {type => 'many to one'});
#
#    is_deeply([sort $meta->parent_relationships], [qw/bar foo/]);
#}
#
#sub has_child_relationships : Test {
#    my $self = shift;
#
#    my $meta = $self->_build_meta;
#
#    $meta->set_columns(qw/foo bar baz/);
#
#    $meta->has_many('foo');
#
#    is_deeply([$meta->child_relationships], ['foo']);
#}
#
#sub has_parent_relationships : Test {
#    my $self = shift;
#
#    my $meta = $self->_build_meta;
#
#    $meta->set_columns(qw/foo bar baz/);
#
#    $meta->belongs_to('foo');
#
#    is_deeply([$meta->parent_relationships], ['foo']);
#}
#
#sub check_is_relationship : Test(2) {
#    my $self = shift;
#
#    my $meta = $self->_build_meta;
#
#    $meta->belongs_to('foo');
#
#    ok($meta->is_relationship('foo'));
#    ok(!$meta->is_relationship('unknown'));
#}
#
#sub inherit_table : Test {
#    my $self = shift;
#
#    {
#        package Parent;
#        use base 'ObjectDB';
#        __PACKAGE__->meta('parent');
#    }
#
#    {
#        package Child;
#        use base 'Parent';
#        __PACKAGE__->meta;
#    }
#
#    my $meta = Child->meta;
#
#    is($meta->get_table, 'parent');
#}
#
#sub inherit_columns : Test {
#    my $self = shift;
#
#    {
#        package Parent;
#        use base 'ObjectDB';
#        __PACKAGE__->meta(
#            table => 'parent',
#            columns => [qw/foo/]
#        );
#    }
#
#    {
#        package Child;
#        use base 'Parent';
#        __PACKAGE__->meta->add_column(qw/bar/);
#    }
#
#    my $meta = Child->meta;
#
#    is_deeply([$meta->get_columns], [qw/foo bar/]);
#}

sub _build_meta {
    my $self = shift;

    return ObjectDB::Meta->new(table => 'foo', class => 'Foo', @_);
}

1;
