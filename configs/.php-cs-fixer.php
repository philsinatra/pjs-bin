<?php

require_once __DIR__ . '/vendor/autoload.php';

use PhpCsFixer\Config;
use PhpCsFixer\Finder;

$config = new Config();
return $config
    ->setRules([
        '@PSR12' => true,
        'array_syntax' => ['syntax' => 'short'],
        'binary_operator_spaces' => [
            'operators' => ['=' => 'align_single_space_minimal'],
        ],
        'blank_line_after_namespace' => true,
        'braces_position' => [
            'functions_opening_brace' => 'same_line',
            'classes_opening_brace' => 'next_line_unless_newline_at_signature_end',
            'anonymous_classes_opening_brace' => 'same_line',
            'control_structures_opening_brace' => 'same_line',
            'anonymous_functions_opening_brace' => 'same_line',
            'allow_single_line_empty_anonymous_classes' => true,
            'allow_single_line_anonymous_functions' => true,
        ],
        'class_definition' => true,
        'encoding' => true,
        'full_opening_tag' => true,
        'line_ending' => true,
        'method_argument_space' => true,
        'multiline_comment_opening_closing' => true,
        'no_blank_lines_after_phpdoc' => true,
        'no_unused_imports' => true,
        'ordered_imports' => true,
        'phpdoc_single_line_var_spacing' => true,
        'phpdoc_trim_consecutive_blank_line_separation' => true,
        'single_blank_line_at_eof' => true,
        'single_class_element_per_statement' => true,
        'single_import_per_statement' => true,
        'single_line_after_imports' => true,
        'single_line_comment_style' => [
            'comment_types' => ['hash']
        ],
        'strict_comparison' => false,
        'switch_case_semicolon_to_colon' => true,
        'switch_case_space' => true,
        'visibility_required' => true,
    ])
    ->setFinder(
        Finder::create()
            ->exclude('vendor')
            ->in(__DIR__)
    );
