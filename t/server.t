
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Encode;
use Test::More;
use Catalyst::Test 'TestApp';

BEGIN {
    no warnings 'redefine';
    *Catalyst::Test::local_request = sub {
        my ( $class, $request ) = @_;

        require HTTP::Request::AsCGI;
        my $cgi = HTTP::Request::AsCGI->new( $request, %ENV )->setup;

        $class->handle_request;

        return $cgi->restore->response;
    };

}

my $entrypoint = "http://localhost/foo";

{
    my $request = HTTP::Request->new( GET => $entrypoint );
    ok( my $response = request($request), 'Request' );
    ok( $response->is_success, 'Response Successful 2xx' );
    is( $response->code, 200, 'Response Code' );
    is_deeply( [ $response->content_type ],
        [ 'application/rdf', 'charset=utf-8' ] );

    my $data = $response->content;
    warn $data;
}

