#! /usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use DDG::Test::Goodie;

zci answer_type => 'email_validation';
zci is_cached   => 1;

ddg_goodie_test(
    ['DDG::Goodie::EmailValidator'],
    'validate my email foo@example.com' => test_zci(
        re(qr/appears to be valid/),
        structured_answer => {
            input     => ['foo@example.com'],
            operation => 'Email address validation',
            result    => re(qr/appears to be valid/)
        }
    ),
    'validate my email foo+abc@example.com' => test_zci(
        re(qr/appears to be valid/),
        structured_answer => {
            input     => ['foo+abc@example.com'],
            operation => 'Email address validation',
            result    => re(qr/appears to be valid/)
        }
    ),
    'validate my email foo.bar@example.com' => test_zci(
        re(qr/appears to be valid/),
        structured_answer => {
            input     => ['foo.bar@example.com'],
            operation => 'Email address validation',
            result    => re(qr/appears to be valid/)
        }
    ),
    'validate user@exampleaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.com'
      => test_zci(
        re(qr/Please check the address/),
        structured_answer => {
            input     => ignore(),
            operation => 'Email address validation',
            result    => re(qr/Please check the address/),
        }
      ),
    'validate foo@example.com' => test_zci(
        re(qr/appears to be valid/),
        structured_answer => {
            input     => ['foo@example.com'],
            operation => 'Email address validation',
            result    => re(qr/appears to be valid/)
        }
    ),
    'validate foo@!!!.com' => test_zci(
        re(qr/Please check the fully qualified domain name/),
        structured_answer => {
            input     => ['foo@!!!.com'],
            operation => 'Email address validation',
            result    => re(qr/Please check the fully qualified domain name/),
        }
    ),
    'validate foo@example.lmnop' => test_zci(
        re(qr/Please check the top-level domain/),
        structured_answer => {
            input     => ['foo@example.lmnop'],
            operation => 'Email address validation',
            result    => re(qr/Please check the top-level domain/),
        }
    ),
    'validate foo' => undef,
);

done_testing;
