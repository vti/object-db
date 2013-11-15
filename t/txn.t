use strict;
use warnings;

use Test::More;
use Test::Fatal;

use lib 't/lib';

use TestEnv;
use Book;

subtest 'rollback on exception' => sub {
    TestEnv->prepare_table('book');

    my $e = exception {
        Book->txn(
            sub {
                my $self = shift;

                Book->new(title => 'foo')->create;
                die 'here';
            }
        );
    };

    like $e, qr/here/;
    is(Book->table->count, 0);
};

subtest 'not rollback if commited' => sub {
    TestEnv->prepare_table('book');

    my $e = exception {
        Book->txn(
            sub {
                my $self = shift;

                Book->new(title => 'foo')->create;
                $self->commit;
                die 'here';
            }
        );
    };

    like $e, qr/here/;
    is(Book->table->count, 1);
};

subtest 'rollback manually' => sub {
    TestEnv->prepare_table('book');

    Book->txn(
        sub {
            my $self = shift;

            Book->new(title => 'foo')->create;
            $self->rollback;
        }
    );

    is(Book->table->count, 0);
};

done_testing;
