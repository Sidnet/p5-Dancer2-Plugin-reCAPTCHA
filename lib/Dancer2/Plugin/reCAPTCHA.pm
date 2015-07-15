package Dancer2::Plugin::reCAPTCHA;

use strict;
use warnings;
use Dancer2::Plugin;
use Captcha::reCAPTCHA;

# ABSTRACT: Easy to integrate reCAPTCHA into Dancer2 application
our $VERSION = '0.01';
# VERSION

my $rc = Captcha::reCHAPTCHA->new;

register recaptcha_display => sub {
    my $conf = plugin_setting();
    return $rc->get_html( 
        $conf->{ public_key },
        undef,
        $conf->{ use_ssl },
        { theme =>  $conf->{ theme }},
    );
};


register recaptcha_check => sub {
    my $dsl = shift;
    my ( $challenge, $response ) = @_;
    my $app = $dsl->app;
    my $conf = plugin_setting();
    return $rc->check_answer(
        $conf->{ private_key },
        $app->request->remote_address,
        $challenge,
        $response,
    );
};

register_plugin;

1;

__END__

=head1 SYNOPSIS

A plugin to integrate reCAPTCHA with Dancer2 application

=head1 CONFIGURATION

plugins:
    reCAPTCHA:
        public_key: "Public/Site key from service provider"
        private_key: "Private/Secret key from service provider"
        theme: "clean"
        use_ssl: 0

=head1 SUBROUTINES/METHODS

=head2 recaptcha_display

Generates scalar HTML to display the CAPTCHA and plugs into template. 
Example:
    
    # Controller
    template 'index' => { 
        recaptcha => recaptcha_display() 
    };

    # Template
    [% recaptcha %]

=cut

=head2 recaptcha_check
    
Validates the value that user has filled in the form whether it maches with the CAPTCHA.
Takes two arguments: the challenge string and the response string, which are returned with submitted form data
in two form fields, recaptcha_challenge_field and recaptcha_response_field.
Returns a reference to a hash containing two fields: is_valid and error. 
Example: 

    my $challenge = param( 'recaptcha_challenge_field' );
    my $response  = param( 'recaptcha_response_field' );
    my $result    = recaptcha_check(
        $challenge,
        $response,
    );

    if( $result->{is_valid} ){
        print "You are a human!";
    } 
    else {
        print $result->{error};
    }

=cut

=head1 SEE ALSO

=for :list

* L<Captcha::reCAPTCHA|https://metacpan.org/pod/Captcha::reCAPTCHA/>

* L<Dancer2::Plugin|https://metacpan.org/pod/Dancer2::Plugin/>

* L<Google reCAPTCHA API Reference|https://www.google.com/recaptcha/intro/index.html/>

=cut
