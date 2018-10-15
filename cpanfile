requires 'perl', '5.010';

requires 'Carp'     => 0;
requires 'Storable' => 0;

requires 'DBI' => '1.641';
requires 'SQL::Composer' => '0.19';

recommends 'DBIx::Inspector';

suggests 'DBD::SQLite' => '1.58';
suggests 'DBD::Pg'     => '3.7.4';
suggests 'DBD::mysql'  => '4.048';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Fatal';
};
