use strict;
use warnings;
use lib 't/lib';

use Test::More;
use Test::Fatal;
use TestDBH;
use TestEnv;

use ObjectDB::Table;
use Person;

subtest 'finds by sql' => sub {
    _setup();

    Person->new(name => $_)->create for (qw/foo bar/);

    my @persons = Person->table->find_by_sql('SELECT * FROM person WHERE name = ?', ['foo']);

    is(@persons, 1);

    is($persons[0]->get_column('name'), 'foo');
};

subtest 'finds by sql with smart bind' => sub {
    _setup();

    Person->new(name => $_)->create for (qw/foo bar/);

    my @persons = Person->table->find_by_sql('SELECT * FROM person WHERE name = :name', { name => 'bar' });

    is(@persons, 1);

    is($persons[0]->get_column('name'), 'bar');
};

subtest 'finds by sql with iterator' => sub {
    _setup();

    Person->new(name => 'vti')->create;
    Person->new(name => 'foo')->create;

    my @persons;
    Person->table->find_by_sql(
        'SELECT * FROM person WHERE name = ?',
        ['vti'],
        each => sub {
            my ($person) = @_;

            push @persons, $person;
        }
    );

    is($persons[0]->get_column('name'), 'vti');
};

done_testing;

sub _setup {
    TestEnv->prepare_table('person');
}
