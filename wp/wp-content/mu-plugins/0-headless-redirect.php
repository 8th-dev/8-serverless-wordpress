<?php
/**
 * Plugin Name: 8th Headless Redirect
 * Description: Redirects the WordPress frontend to blog.8ths.dev.
 * Version: 1.0.0
 */

add_action(
    'template_redirect',
    function (): void {
        wp_redirect( 'https://blog.8ths.dev', 302 );
        exit;
    },
    0
);