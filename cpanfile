requires 'perl', '5.010';

requires 'Carp'     => 0;
requires 'Storable' => 0;

requires 'SQL::Builder' => 0;

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Fatal';
    requires 'Test::Spec';
};
