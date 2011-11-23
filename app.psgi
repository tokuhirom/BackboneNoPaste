use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Amon2::Lite;

our $VERSION = '0.01';

# put your configuration here
sub load_config {
    my $c = shift;

    my $mode = $c->mode_name || 'development';

    +{
        'DBI' => [
            'dbi:SQLite:dbname=$mode.db',
            '',
            '',
        ],
    }
}

get '/' => sub {
    my $c = shift;
    return $c->render('index.tt');
};
get '/api/entry/:id' => sub {
    my ($c, $args) = @_;
    my $row = $c->dbh->selectrow_hashref(q{SELECT * FROM entry WHERE id=?}, {}, $args->{id});
    if ($row) {
        return $c->render_json($row);
    } else {
        my $res = $c->render_json({});
        $res->status(404);
        return $res;
    }
};
post '/api/entry' => sub {
    my $c = shift;
    warn $c->req->content;
    my $dat = decode_json($c->req->content);
    my $id;
    if (my $body = $dat->{body}) {
        $c->dbh->insert(
            entry => {
                body => $body,
                ctime => time(),
            }
        );
        $id = $c->dbh->last_insert_id("", "", "", "");
    }
    return $c->render_json({id => $id});
};
get '/*' => sub {
    my $c = shift;
    return $c->render('index.tt');
};

use JSON;



# load plugins
# __PACKAGE__->load_plugin('Web::CSRFDefender');
__PACKAGE__->load_plugin('DBI');
# __PACKAGE__->load_plugin('Web::FillInFormLite');
__PACKAGE__->load_plugin('Web::JSON');

{
    my $c = __PACKAGE__->new();
    $c->dbh->do(q{CREATE TABLE IF NOT EXISTS entry (
        id INTEGER NOT NULL PRIMARY KEY,
        body TEXT,
        ctime INTEGER
    )});
}

__PACKAGE__->enable_session();
__PACKAGE__->to_app(handle_static => 1);

__DATA__

@@ index.tt
<!doctype html>
<html>
<head>
    <met charst="utf-8">
    <title>BackboneNoPaste</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.0/jquery.js"></script>
    <link rel="stylesheet" href="[% uri_for('/static/css/main.css') %]">
    [% FOR x IN 'static/js/underscore.js static/js/backbone.js'.split(' ') %]
        <script type="text/javascript" src="[% uri_for('/' _ x) %]"></script>
    [% END %]
    <script type="text/javascript" src="[% uri_for('/static/js/micro_template.js') %]"></script>
    <script type="text/javascript" src="[% uri_for('/static/js/main.js') %]"></script>
</head>
<body>
    <div class="container">
        <header><h1><a href="/">BackboneNoPaste</a></h1></header>
        <section class="row" id="Body">
            Now loading...
        </section>
        <footer>Powered by <a href="http://amon.64p.org/">Amon2::Lite</a></footer>
    </div>
    <script id="formTmpl" type="text/template">
        <form method="post">
            <textarea name="body"></textarea>
            <input type="submit" value="post" class="submit" />
        </form>
    </script>
    <script id="entryTmpl" type="text/template">
        <pre><%= entry.body %></pre>
    </script>
</body>
</html>

@@ /static/css/main.css
pre {
    background-color: #cccccc;
    border-radius: 8px;
}
footer {
    text-align: right;
}
