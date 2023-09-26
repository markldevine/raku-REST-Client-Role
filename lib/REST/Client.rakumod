unit role REST::Client:api<1>:auth<Mark Devine (mark@markdevine.com)>;

use Cro::HTTP::Client;
use KHPH;

has Cro::HTTP::Client   $.cro-client;
has Str:D               $.url           is required;
has Str:D               $.user-id       is required;
has Str                 $.stash-path;
has Str                 $.passwd;
has Bool                $.insecure                  = False;

has                     $.response;
has                     $.body;

submethod TWEAK {
    my $stash-path  = $*HOME ~ '/.' ~ $*PROGRAM-NAME.IO.basename ~ '/accounts/' ~ $!user-id ~ '.khph';
    $stash-path     = $!stash-path if $!stash-path;
    $!passwd        = KHPH.new(:prompt($!user-id ~ ' password'), :$stash-path).expose;
    $!cro-client    = Cro::HTTP::Client.new;
}

method get {
    my %options     = (
                        auth    => { username => self.user-id, password => self.passwd },
                      );
    %options<ca>    = { :insecure } if self.insecure;
    $!response      = await $!cro-client.get(self.url, %options);
    $!body          = await $!response.body;
    return $!body;
}

=finish
