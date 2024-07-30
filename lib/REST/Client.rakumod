unit role REST::Client:api<1>:auth<Mark Devine (mark@markdevine.com)>;

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
    my $stash-path          = $*HOME ~ '/.' ~ $*PROGRAM-NAME.IO.basename ~ '/accounts/' ~ $!user-id ~ '.khph';
    $stash-path             = $!stash-path      if $!stash-path;
    $!passwd                = KHPH.new(:prompt($!user-id ~ ' password'), :$stash-path).expose;
    $!cro-client            = Cro::HTTP::Client.new;
    %!default-options<auth> = username => self.user-id, password => self.passwd;
    %!default-options<ca>   = { :insecure }     if self.insecure;
}

method login-collect-cookies {
    my $response            = await $!cro-client.post($url, %options);
    my $body                = await $response.body;
    my @cookies             = $response.cookies;
}

method login-collect-token {
    ;
}

method post (Str:D :$url!, *%options) {
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
    my %options             = %!default-options unless %options.elems;
    my $response            = await $!cro-client.get(self.url, %options);
    my $body                = await $!response.body;
    return $!body;
}

=finish
