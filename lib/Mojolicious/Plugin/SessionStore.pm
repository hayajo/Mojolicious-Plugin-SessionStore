package Mojolicious::Plugin::SessionStore;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

use Mojolicious::Sessions::Alternative;

sub register {
    my ( $self, $app, $args ) = @_;
    $args = { session_store => $args } unless ( ref $args eq 'HASH' );
    my $sessions
        = Mojolicious::Sessions::Alternative->new(%$args);
    $app->sessions($sessions);
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojolicious::Plugin::SessionStore - session data store plugin for Mojolicious

=head1 SYNOPSIS

  use Mojolicious::Lite;
  use Plack::Session::Store::File;

  plugin SessionStore => Plack::Session::Store::File->new;

=head1 DESCRIPTION

Mojolicious::Plugin::SessionStore is a session data store plugin for Mojolicious. It creates L<Mojolicious::Sessions::Alternative> instance with provided session data store instance.

=head1 OPTIONS

Mojolicious::Plugin::SessionStore accepts all options of L<Mojolicious::Sessions::Alternative>.

If a single option is provided, which is expected to be an option of L<Mojolicious::Sessions::Alternative>@session_store.

If no option is provided the default <Mojolicious::Session> will be used.

=head1 METHODS

Mojolicious::Plugin::SessionStore inherits all methods from L<Mojolicious::Plugin>.

=head1 AUTHOR

hayajo E<lt>hayajo@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2013- hayajo

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Sessions>, L<Mojolicious::Sessions::Alternative>, L<Plack::Middleware::Session>

=cut
