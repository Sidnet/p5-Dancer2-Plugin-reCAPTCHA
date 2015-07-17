package Dancer2::Plugin::reCAPTCHA;

use strict;
use warnings;

# ABSTRACT: Integrate reCAPTCHA into Dancer2 applications

# VERSION

use Dancer2::Plugin;
use Captcha::reCAPTCHA;

my $rc = Captcha::reCAPTCHA->new;

register recaptcha_display => sub {
    my $conf = plugin_setting();

    return $rc->get_html( 
        $conf->{public_key},
        undef,
        $conf->{use_ssl},
        { theme =>  $conf->{theme} },
    );
};

register recaptcha_check => sub {
    my $dsl = shift;
    my ($challenge, $response) = @_;
    my $app = $dsl->app;
    my $conf = plugin_setting();

    return $rc->check_answer(
        $conf->{private_key},
        $app->request->remote_address,
        $challenge,
        $response,
    );
};

register_plugin;

1;

__END__

=head1 SYNOPSIS

Dancer2::Plugin::reCAPTCHA allows you to easily use reCAPTCHA in Dancer2
applications.

Add the plugin to your application:

    use Dancer2::Plugin::reCAPTCHA;

Configure its settings in the YAML configuration file:

    plugins:
        reCAPTCHA:
            public_key: "public key"
            private_key: "private key"
            theme: "clean"
            use_ssl: 0

Put reCAPTCHA in a template:

    [% recaptcha %]

Display it:

    return template 'feedback', { 
        recaptcha => recaptcha_display()
    };

Validate user input in a route handler:

    my $challenge = param('recaptcha_challenge_field');
    my $response  = param('recaptcha_response_field');
    my $result    = recaptcha_check($challenge, $response);

    if ($result->{is_valid}) {
        # Good
    }
    else {
        # Bad
    }

=head1 CONFIGURATION

The available configuration settings are described below.

=head2 public_key

The reCAPTCHA public key.

=head2 private_key

The reCAPTCHA private key.

=head2 theme

The color theme of the captcha widget. Possible values: C<red>, C<white>,
C<blackglass>, C<clean>.

=head2 use_ssl

If set to C<1>, reCAPTCHA will use an SSL-based API (should be enabled on pages
served over SSL).

=head1 SUBROUTINES/METHODS

=head2 recaptcha_display

Generates the HTML to display the captcha which should be placed in a template. 

Example:
    
    # In route handler
    template 'index' => { 
        recaptcha => recaptcha_display() 
    };

    # In template
    [% recaptcha %]

=head2 recaptcha_check
    
Validates the input provided by the user to check if it matches the captcha.
Arguments:

=over

=item C<$challenge>

Challenge string retrieved from the submitted form field
C<recaptcha_challenge_field>.

=item C<$response>

Response string retrieved from the submitted form field
C<recaptcha_response_field>.

=back

Returns a reference to a hash containing two fields: C<is_valid> and C<error>.

Example: 

    my $challenge = param('recaptcha_challenge_field');
    my $response  = param('recaptcha_response_field');
    my $result    = recaptcha_check($challenge, $response);

    if( $result->{is_valid} ){
        print "You are a human!";
    } 
    else {
        print $result->{error};
    }

=head1 SEE ALSO

=for :list

* L<Captcha::reCAPTCHA>

* L<Dancer::Plugin::reCAPTCHA>

* L<Google reCAPTCHA API Reference|https://www.google.com/recaptcha/intro/index.html/>

=head1 ACKNOWLEDGEMENTS

Based on Jason A. Crome's plugin for Dancer version 1
(Dancer::Plugin::reCAPTCHA). Makes use of Fred Moyer's Captcha::reCAPTCHA.

=cut
