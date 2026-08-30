<?php
/**
 * Plugin Name: 8th Headless Redirect
 * Description: Redirects the WordPress frontend to blog.8ths.dev.
 * Version: 1.0.0
 */

add_action(
    'template_redirect',
    function (): void {
        $requestPath = (string) parse_url( $_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH );

        if (
            is_admin()
            || $requestPath === '/wp-login.php'
            || str_starts_with( $requestPath, '/wp-json' )
            || $requestPath === '/graphql'
            || ( function_exists( 'is_graphql_http_request' ) && is_graphql_http_request() )
        ) {
            return;
        }

        wp_redirect( 'https://blog.8ths.dev', 302 );
        exit;
    },
    0
);