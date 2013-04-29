use strict;
use Test::More;

use Mojolicious::Lite;
use Plack::Session::Store;
use Test::Mojo;

plugin SessionStore => Plack::Session::Store->new;

get '/' => sub {
    my $self = shift;
    my $name = $self->session('name') || 'anonymous';
    my $message = $self->flash('message');
    my $text
        = ($message)
        ? "$name: $message"
        : "Welcome $name!";
    $self->render_text($text);
} => 'index';

get '/login' => sub {
    my $self = shift;
    my $name = $self->param('name');
    $self->session( name => $name );
    $self->session_options->{change_id}++;
    $self->redirect_to('index');
} => 'login';

get '/flash/:message' => sub {
    my $self = shift;
    my $message = $self->param('message');
    $self->flash( message => $message );
    $self->redirect_to('index');
} => 'message';

get '/logout' => sub {
    my $self = shift;
    # $self->session( expires => 1 );
    $self->session_options->{expire} = 1;
    $self->redirect_to('login');
} => 'logout';

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

# Index
$t->get_ok('/')->status_is(200)->content_is('Welcome sri!');

# Flash
$t->get_ok('/flash/hello')->status_is(200)->content_is('sri: hello');
# Empty flash
$t->get_ok('/')->status_is(200)->content_is('Welcome sri!');

# Logout
$t->get_ok('/logout')->status_is(200)->content_is('Welcome anonymous!');
my $new_cookie_value = $t->tx->res->cookie('mojolicious')->value;
isnt $new_cookie_value, $cookie_value;

# Expired session
$t->get_ok('/')->status_is(200)->content_is('Welcome anonymous!');
is $t->tx->res->cookie('mojolicious')->value, $new_cookie_value;

# No session
$t->get_ok('/logout')->status_is(200)->content_is('Welcome anonymous!');

done_testing;
