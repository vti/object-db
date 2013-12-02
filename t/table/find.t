use Test::Spec;
use Test::Fatal;

use lib 't/lib';

use TestDBH;
use TestEnv;
use ObjectDB::Table;
use Person;

describe 'table find' => sub {

    before each => sub {
        TestEnv->prepare_table('person');
    };

    it 'find_objects' => sub {
        Person->new(name => 'vti')->create;

        my $table = _build_table();

        my @persons = $table->find;

        is(@persons, 1);
    };

    it 'find_objects_with_query' => sub {
        Person->new(name => 'vti')->create;
        Person->new(name => 'foo')->create;

        my $table = _build_table();

        my @persons = $table->find(where => [name => 'vti']);

        is($persons[0]->get_column('name'), 'vti');
    };

    it 'find_single_object' => sub {
        Person->new(name => 'vti')->create;
        Person->new(name => 'foo')->create;

        my $table = _build_table();

        my $person = $table->find(where => [name => 'vti'], single => 1);

        is($person->get_column('name'), 'vti');
    };
};

sub _build_table {
    ObjectDB::Table->new(class => 'Person', dbh => TestDBH->dbh, @_);
}

runtests unless caller;
