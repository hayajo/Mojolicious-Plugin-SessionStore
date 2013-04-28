use strict;
use Test::More;

use Mojolicious::Lite;
use Plack::Session::Store;
use Test::Mojo;

plugin SessionStore => Plack::Session::Store->new;

get '/login' => sub {
    my $self = shift;
    my $name = $self->param('name') || 'anonymous';
    $self->session( name => $name );
    $self->session_options->{change_id}++;
    $self->render_text("Welcome $name!");
};

get '/again' => sub {
    my $self = shift;
    my $name = $self->session('name') || 'anonymous';
    $self->render_text("Welcome back $name!");
};

get '/logout' => sub {
    my $self = shift;
    # $self->session( expires => 1 );
    $self->session_options->{expire} = 1;
    $self->redirect_to('login');
};

my $t = Test::Mojo->new;
$t->ua->max_redirects(5);

# Login
$t->reset_session->get_ok('/login')->status_is(200)->content_is('Welcome anonymous!');
ok $t->tx->res->cookie('mojolicious')->expires, 'session cookie expires';
my $prev_cookie_value = $t->tx->res->cookie('mojolicious')->value;

# Login again
$t->get_ok('/login?name=sri')->status_is(200)->content_is('Welcome sri!');
my $cookie_value = $t->tx->res->cookie('mojolicious')->value;
isnt $cookie_value, $prev_cookie_value;

# Return
$t->get_ok('/again')->status_is(200)->content_is('Welcome back sri!');
is $t->tx->res->cookie('mojolicious')->value, $cookie_value;

# Logout
$t->get_ok('/logout')->status_is(200)->content_is('Welcome anonymous!');
my $new_cookie_value = $t->tx->res->cookie('mojolicious')->value;
isnt $new_cookie_value, $cookie_value;

# Expired session
$t->get_ok('/again')->status_is(200)->content_is('Welcome back anonymous!');
is $t->tx->res->cookie('mojolicious')->value, $new_cookie_value;

# No session
$t->get_ok('/logout')->status_is(200)->content_is('Welcome anonymous!');

done_testing;




