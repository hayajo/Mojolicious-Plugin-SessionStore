requires 'perl', '5.008005';

# requires 'Some::Module', 'VERSION';
requires 'Mojolicious', '0';
requires 'Digest::SHA1', '0';

on test => sub {
    requires 'Test::More', '0.88';
    requires 'Plack::Middleware::Session', '0';
};
