use Test::Spec;
use Test::Fatal;

use lib 't/lib';

use TestDBH;
use TestEnv;
use Person;

describe 'create' => sub {

    before each => sub {
        TestEnv->prepare_table('person');
    };

    it 'create_one_instance' => sub {
        my $person = _build_object(name => 'vti');
        $person->create;

        my $result = TestDBH->dbh->selectall_arrayref('SELECT * FROM `person`');

        is(@$result, 1);
    };

    it 'save_columns' => sub {
        my $person = _build_object(name => 'vti');
        $person->create;

        my $result =
          TestDBH->dbh->selectall_arrayref('SELECT id, name FROM `person`');

        is_deeply($result->[0], [1, 'vti']);
    };

    it 'do_nothing_on_double_create' => sub {
        my $person = _build_object(name => 'vti');
        $person->create;

        $person->create;

        my $result = TestDBH->dbh->selectall_arrayref('SELECT * FROM `person`');

        is(@$result, 1);
    };

    it 'autoincrement_field_is_set' => sub {
        my $person = _build_object(name => 'vti');
        $person->create;

        is($person->column('id'), 1);
    };

    it 'is_in_db' => sub {
        my $person = _build_object(name => 'vti');
        $person->create;

        ok($person->is_in_db);
    };

    it 'not_modified' => sub {
        my $person = _build_object(name => 'vti');
        $person->create;

        ok(!$person->is_modified);
    };

};

sub _build_object {
    return Person->new(@_);
}

runtests unless caller;
