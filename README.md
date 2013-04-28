# NAME

Mojolicious::Plugin::SessionStore - session data store plugin for Mojolicious

# SYNOPSIS

    use Mojolicious::Lite;
    use Plack::Session::Store::File;

    plugin SessionStore => Plack::Session::Store::File->new;

# DESCRIPTION

Mojolicious::Plugin::SessionStore is a session data store plugin for Mojolicious. It creates [Mojolicious::Sessions::Alternative](http://search.cpan.org/perldoc?Mojolicious::Sessions::Alternative) instance with provided session data store instance.

# ARGUMENT

Mojolicious::Plugin::SessionStore accepts a single argument.
That. is expected to be an instance on [Plack::Session::Store](http://search.cpan.org/perldoc?Plack::Session::Store) or an object that implements the same interface.
If no option is provided the default [Mojolicious::Sessions](http://search.cpan.org/perldoc?Mojolicious::Sessions) will be used.

# METHODS

Mojolicious::Plugin::SessionStore inherits all methods from [Mojolicious::Plugin](http://search.cpan.org/perldoc?Mojolicious::Plugin).

# AUTHOR

hayajo <hayajo@cpan.org>

# COPYRIGHT

Copyright 2013- hayajo

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

[Mojolicious](http://search.cpan.org/perldoc?Mojolicious), [Mojolicious::Sessions](http://search.cpan.org/perldoc?Mojolicious::Sessions), [Mojolicious::Sessions::Alternative](http://search.cpan.org/perldoc?Mojolicious::Sessions::Alternative)
