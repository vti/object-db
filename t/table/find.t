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

    it 'have is_in_db flag' => sub {
        Person->new(name => 'vti')->create;

        my $table = _build_table();

        my @persons = $table->find;

        ok($persons[0]->is_in_db);
    };

    it 'find_objects_with_query' => sub {
        Person->new(name => 'vti')->create;
        Person->new(name => 'foo')->create;

        my $table = _build_table();

        my @persons = $table->find(where => [name => 'vti']);

        is($persons[0]->get_column('name'), 'vti');
    };

    it 'find objects with specified columns' => sub {
        Person->new(name => 'vti')->create;

        my $table = _build_table();

        my $person = $table->find(first => 1, where => [name => 'vti'], columns => ['id']);

        ok($person->get_column('id'));
        ok(!$person->get_column('name'));
    };

    it 'find objects with specified +columns' => sub {
        Person->new(name => 'vti')->create;

        my $table = _build_table();

        my $person = $table->find(first => 1, where => [name => 'vti'], '+columns' => [{-col => \'1', -as => 'one'}]);

        ok($person->get_column('id'));
        is($person->get_column('name'), 'vti');
        is($person->get_column('one'), '1');
    };

    it 'find objects with specified -columns' => sub {
        Person->new(name => 'vti')->create;

        my $table = _build_table();

        my $person = $table->find(first => 1, where => [name => 'vti'], '-columns' => ['name']);

        ok($person->get_column('id'));
        ok(!$person->get_column('name'));
    };

    it 'find objects with specified columns with aliases' => sub {
        Person->new(name => 'vti')->create;

        my $table = _build_table();

        my $person = $table->find(
            first   => 1,
            where   => [name => 'vti'],
            columns => [{-col => 'id', -as => 'alias'}]
        );

        ok($person->get_column('alias'));
    };

    it 'find_single_object' => sub {
        Person->new(name => 'vti')->create;
        Person->new(name => 'foo')->create;

        my $table = _build_table();

        my $person = $table->find(where => [name => 'vti'], single => 1);

        is($person->get_column('name'), 'vti');
    };

    it 'finds objects with iterator' => sub {
        Person->new(name => 'vti')->create;
        Person->new(name => 'foo')->create;

        my $table = _build_table();

        my @persons;
        $table->find(
            where => [name => 'vti'],
            each  => sub {
                my ($person) = @_;

                push @persons, $person;
            }
        );

        is($persons[0]->get_column('name'), 'vti');
    };

};

sub _build_table {
    ObjectDB::Table->new(class => 'Person', dbh => TestDBH->dbh, @_);
}

runtests unless caller;
