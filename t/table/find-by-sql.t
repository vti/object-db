use Test::Spec;
use Test::Fatal;

use lib 't/lib';

use TestDBH;
use TestEnv;
use ObjectDB::Table;
use Person;

describe 'table find by sql' => sub {

    before each => sub {
        TestEnv->prepare_table('person');
    };

    it 'finds by sql' => sub {
        Person->new(name => $_)->create for (qw/foo bar/);

        my @persons =
          Person->table->find_by_sql('SELECT * FROM person WHERE name = ?',
            'foo');

        is(@persons, 1);

        is($persons[0]->get_column('name'), 'foo');
    };

    it 'finds by sql with smart bind' => sub {
        Person->new(name => $_)->create for (qw/foo bar/);

        my @persons =
          Person->table->find_by_sql('SELECT * FROM person WHERE name = :name',
            {name => 'bar'});

        is(@persons, 1);

        is($persons[0]->get_column('name'), 'bar');
    };

};

runtests unless caller;
