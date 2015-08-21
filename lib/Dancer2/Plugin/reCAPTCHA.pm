package Dancer2::Plugin::reCAPTCHA;

use strict;
use warnings;

# ABSTRACT: Integrate reCAPTCHA into Dancer2 applications

# VERSION

use Dancer2::Plugin;
use Captcha::reCAPTCHA::V2;

my $rc = Captcha::reCAPTCHA::V2->new;

register recaptcha_display => sub {
    my $conf = plugin_setting();
    return $rc->html( 
        $conf->{site_key},
        $conf->{options},
    );
};


register recaptcha_verify => sub {
    my $dsl = shift;
    my $response = shift;
    my $app = $dsl->app;
    my $conf = plugin_setting();
    return $rc->verify(
        $conf->{secret},
        $response,
        $app->request->remote_address,
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
            site_key: "site key"
            secret: "secret key"
            options:
                theme: "light"
                type: "image"
                size: "normal"

Put reCAPTCHA in a template:

    [% recaptcha %]

Display it:

    return template 'feedback', { 
        recaptcha => recaptcha_display()
    };

Validate user input in a route handler:

    my $response  = param('g-recaptcha-response');
    my $result    = recaptcha_verify($response);

    if ($result->{success}) {
        # Good
    }
    else {
        # Bad
    }

=head1 CONFIGURATION

The available configuration settings are described below.

=head2 site_key

The reCAPTCHA site key.

=head2 secret

The reCAPTCHA secret key.

=head2 options

Configuration to design the widget's apperance and behavior with these following keys:

=over

=item C<theme>

The color theme of the of the widget. Possible values are C<'dark'> and C<'light'>.

=item C<type>

The type of the reCAPTCHA to serve. Possible values are C<'audio'> and C<'image'>.

=item C<size>

The size of the widget. Possible values are C<'compact'> and C<'normal'>.

=back

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

=head2 recaptcha_verify
    
Validates the input provided by the user to check if it is a correct answer.
Arguments:

=over

=item C<$response>

Response string retrieved from the submitted form field
C<g-recaptcha-response>.

=back

Returns a reference to a hash containing two fields: C<success> and C<error_codes>.

Example: 

    my $response  = param('g-recaptcha-response');
    my $result    = recaptcha_verify($response);

    if ($result->{success}) {
        print "You are a human!";
    } 
    else {
        print $result->{error_codes};
    }

=head1 SEE ALSO

=for :list

* L<Captcha::reCAPTCHA::V2>

* L<Dancer::Plugin::reCAPTCHA>

* L<Google reCAPTCHA API Reference|https://www.google.com/recaptcha/intro/index.html/>

=head1 ACKNOWLEDGEMENTS

Based on Jason A. Crome's plugin for Dancer version 1
(Dancer::Plugin::reCAPTCHA).

=cut
