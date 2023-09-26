unit role REST::Client:api<1>:auth<Mark Devine (mark@markdevine.com)>;

use Cro::HTTP::Client;
use KHPH;

use Data::Dump::Tree;

has Cro::HTTP::Client   $.cro-client;
has Str:D               $.url           is required;
has Str:D               $.user-id       is required;
has Cro::Uri            $.uri;
has Str                 $.passwd;
has Bool                $.insecure                  = False;

submethod TWEAK {
    $!uri           = Cro::Uri.parse($!url);
    $!passwd        = KHPH.new(:prompt($!user-id ~ ' password'), :stash-path($*HOME ~ '/.' ~ $*PROGRAM-NAME.IO.basename ~ '/accounts/' ~ $!user-id ~ '.khph')).expose;
    $!cro-client    = Cro::HTTP::Client.new;
}

method get {
    my $response    = await $!cro-client.get:
                        self.url,
                        :auth({username => self.user-id, password => self.passwd}),
                        :ca({:insecure}),
                      ;
    return await $response.body;
}

=finish
