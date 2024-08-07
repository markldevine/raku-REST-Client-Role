unit role REST::Client:api<1>:auth<Mark Devine (mark@markdevine.com)>;

#   Establish a cache of the login flow for each client in <preferences>

Attributes:
    $.user-id
    $.password
    $.login-url
 
Methods:
    login: (POST)
        if cookie-jar
            
        elsif session-token
            KHPH.expose
        return body
    get (:$url!)
        Cro::HTTP::Client.get
        CATCH {
            when X::Cro::HTTP::Error {
                given .response.status {
                    when    400 { die '400: Bad Request (' ~ $! ')';                    }
                    when    401 { die '401: Unauthorized (' ~ $! ')';                   }
                    when    402 { die '402: Payment Required (' ~ $! ')';               }
                    when    403 { die '403: Forbidden (' ~ $! ')';                      }
                    when    404 { die '404: Not Found (' ~ $! ')';                      }
                    when    405 { die '405: Method Not Allowed (' ~ $! ')';             }
                    when    406 { die '406: Not Acceptable (' ~ $! ')';                 }
                    when    407 { die '407: Proxy Authentication Required (' ~ $! ')';  }
                    when    408 { die '408: Request Timeout (' ~ $! ')';                }
                    when    409 { die '409: Conflict (' ~ $! ')';                       }
                    when    410 { die '410: Gone (' ~ $! ')';                           }
                    when    411 { die '411: Length Required(' ~ $! ')';                 }
                    when    412 { die '412: Precondition Failed (' ~ $! ')';            }
                    when    413 { die '413: Payload Too Large (' ~ $! ')';              }
                    when    414 { die '414: URI Too Long (' ~ $! ')';                   }
                    when    415 { die '415: Unsupported Media Type (' ~ $! ')';         }
                    default     { 'Unexpected error: ' ~ $_;                            }
                }
            }
        }
        if fail
            purge stash
            

Algorithm:
    - if existing token

    - existing cookie
    - basic -> token
    - basic -> cookie
    - 

use Cro::HTTP::Client;
use KHPH;

has Cro::HTTP::Client       $.cro-client;
has Str:D                   $.login-url         is required;
has Str:D                   $.user-id           is required;
has Str                     $.stash-path;
has Str                     $.passwd;
has Bool                    $.insecure;

has Str                     $.token;
has IO::Path                $.cookie-path;
has                         $.cookies;
has                         %.default-options;

submethod TWEAK {
    my $stash-path          = $*HOME ~ '/.privacy/' ~ $*PROGRAM-NAME.IO.basename ~ '/accounts/' ~ $!user-id ~ '.khph';
    $stash-path             = $!stash-path      if $!stash-path;
    $!passwd                = KHPH.new(:prompt($!user-id ~ ' password'), :$stash-path).expose;
    $!cro-client            = Cro::HTTP::Client.new;
    %!default-options<auth> = username => self.user-id, password => self.passwd;
    %!default-options<ca>   = { :insecure }     if self.insecure;
}

method login-collect-cookies (*%options) {
    my $response            = await $!cro-client.post($!login-url, %options);
    my $body                = await $response.body;
    CATCH {
        when X::Cro::HTTP::Error {
            if .response.status == 402 {
                die '402: log in again';
            }
            else {
                die "Unexpected error: $_";
            }
        }
    }
    my @cookies             = $response.cookies;
}

method login-collect-token {
    ;
}

method post (Str:D :$url!, *%options) {
put '    $url = ' ~ $url;
put '%options = ' ~ %options.kv.join(' ');
    my $response            = await $!cro-client.post($url, %options);
    my $body                = await $response.body;
    CATCH {
        when X::Cro::HTTP::Error {
            if .response.status == 402 {
                die '402: log in again';
            }
            else {
                die "Unexpected error: $_";
            }
        }
    }
    return $body;
}

multi method get (Str:D :$url, Str:D :$token, *%options) {
    ;
}

multi method get (Str:D :$url, IO::Path:D :$cookie-path, *%options) {

#   if cookie attempt = '401' (unauthorized), login again

}

multi method get (Str:D :$url, *%options) {
    my $response            = await $!cro-client.get($url, %options);
    my $body                = await $response.body;
    return $!body;
}

=finish
