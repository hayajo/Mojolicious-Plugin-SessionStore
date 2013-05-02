package Mojolicious::Sessions::Storable;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Sessions';
use Digest::SHA1 ();

has sid_generator => sub {
    sub {
        Digest::SHA1::sha1_hex( rand() . $$ . {} . time );
    };
};

has 'session_store';

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    if ( $self->session_store ) {
        Mojo::Base::attr(
            'Mojolicious::Controller',
            session_options => sub {
                $_[0]->stash->{'mojox.session.options'}
            },
        );
    }

    return $self;
}

sub load {
    my ( $self, $c ) = @_;

    return $self->SUPER::load($c) unless ( $self->session_store );

    my ( $session_id, $session ) = $self->get_session($c);

    if ( $session_id && $session ) {
        $session->{flash} = delete $session->{new_flash}
            if $session->{new_flash};
    }
    else {
        $session_id = $self->generate_id( $c->req->env );
        $session    = {};
    }

    my $stash = $c->stash;
    $stash->{'mojox.session.options'} = { id => $session_id };
    $stash->{'mojo.session'} = $session;
}

sub store {
    my ( $self, $c ) = @_;

    return $self->SUPER::store($c) unless ( $self->session_store );

    my $stash = $c->stash;
    my $session = $stash->{'mojo.session'};

    # Don't reset flash for static files
    my $old = delete $session->{flash};
    @{ $session->{new_flash} }{ keys %$old } = values %$old
        if $stash->{'mojo.static'};
    delete $session->{new_flash} unless keys %{ $session->{new_flash} };

    # Generate "expires" value from "expiration" if necessary
    my $expiration = $session->{expiration} // $self->default_expiration;
    my $default = delete $session->{expires};
    $session->{expires} = $default || time + $expiration
        if ( $expiration || $default );

    $self->set_session( $c, $session );
}

sub generate_id {
    my ( $self, $env ) = @_;
    $self->sid_generator->($env);
}

sub get_session {
    my ( $self, $c ) = @_;

    my $session_id = $c->signed_cookie( $self->cookie_name ) or return;
    my $session    = $self->session_store->fetch($session_id) or return;

    my $expires = delete $session->{expires};
    if ( defined $expires && $expires <= time ) {
        $self->session_store->remove($session_id);
        return;
    };

    return ( $session_id, $session );
}

sub set_session {
    my ( $self, $c, $session ) = @_;

    if ( $c->session_options->{expire} || $session->{expires} <= time ) {
        $session->{expires} = 1;
        $self->session_store->remove( $c->session_options->{id} );
    }
    elsif ( $c->session_options->{change_id} ) {
        $self->session_store->remove( $c->session_options->{id} );
        $c->session_options->{id} = $self->generate_id( $c->req->env );
        $self->session_store->store( $c->session_options->{id}, $session );
    }
    else {
        $self->session_store->store( $c->session_options->{id}, $session );
    }

    my $options = {
        domain   => $self->cookie_domain,
        expires  => $session->{expires},
        httponly => 1,
        path     => $self->cookie_path,
        secure   => $self->secure
    };
    $c->signed_cookie(
        $self->cookie_name,
        $c->session_options->{id},
        $options,
    );
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojolicious::Sessions::Storable - Storable session manager for Mojolicious

=head1 SYNOPSIS

  use Mojolicious::Lite;
  use Mojolicious::Sessions::Storable;

  use Plack::Session::Store::File;

  my $sessions = Mojolicious::Sessions::Storable->new(
      session_store => Plack::Session::Store::File->new
  );

  app->sessions($sessions);

=head1 DESCRIPTION

Mojolicious::Sessions::Storable is a storable session manager for L<Mojolicious>.

=head1 OPTIONS

Mojolicious::Sessions::Storable inherits all options from L<Mojolicious::Sessions> and supports the following new ones.

=head2 session_store

This is expected to be an instance of L<Plack::Session::Store> or an object that implements the same interface.
If no option is provided the default L<Mojolicious::Sessions> will be used.

=head2 sid_generator

This is a CODE ref use to generate unique session ids. by default it will generate a SHA1 using fairly sufficient entropy.

=head METHODS

Mojolicious::Sessions::Storable inherits all methods from L<Mojolicious::Sessions>.

=head1 AUTHOR

hayajo E<lt>hayajo@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2013- hayajo

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Sessions>, L<Mojolicious::Plugin::SessionStore>, L<Plack::Middleware::Session>

=cut
