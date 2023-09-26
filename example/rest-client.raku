#!/usr/bin/env raku

use lib '/home/mdevine/github.com/raku-REST-Client-Role/lib';
use REST::Client;

class Rest-Client does REST::Client {}

sub MAIN (
    Str:D   :$url!,                                 #= full URL string
    Str:D   :$user-id,                              #= user id for authentication
    ) {
    my $rest-client     = Rest-Client.new(
                            :$url,
                            :$user-id,
                            :insecure,
                          );
    my $body            = $rest-client.get;
    for $body<shares>.list -> $share {
        printf "%-30s%s\n", $share<name>, $share<path>;
    }
}

=finish
