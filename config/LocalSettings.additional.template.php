<?php
# Debug Mode
if( isset( $wgDebug ) && $wgDebug ) {
	$wgShowExceptionDetails = true;
	$wgDebugToolbar = true;
}

# Short URL
$wgArticlePath = "/wiki/$1";

# Enable File Uploads
$wgEnableUploads = true;
$wgFileExtensions = array_merge( $wgFileExtensions, [
	'pdf',
	'ppt',
	'pptx',
	'xls',
	'xlsx',
	'doc',
	'docx',
	'odt',
	'ods',
	'odc',
	'odp',
	'odg',
	'svg'
] );

$wgDefaultSkin = "tweeki";
$wgDefaultUserOptions['tweeki-advanced'] = 1; # Show Tweeki's advanced features by default
$wgTweekiSkinUseTooltips = true; # Use Bootstrap Tooltips

# Load Parser Functions extension
wfLoadExtension( 'ParserFunctions' );
$wgPFEnableStringFunctions = true; # Enable String Functions

# Enable Semantic MediaWiki
wfLoadExtension( 'SemanticMediaWiki' );
enableSemantics();
$smwgEnabledEditPageHelp = false;
$smwgPageSpecialProperties[] = '_CDAT';
$smwgParserFeatures = $smwgParserFeatures | SMW_PARSER_LINV;
$smwgQMaxSize = 20;

# disable prefetch lookup feature while the fix for
# https://github.com/SemanticMediaWiki/SemanticMediaWiki/issues/4988
# isn't released (to be expected for SMW 3.2.4)
$smwgExperimentalFeatures = SMW_SHOWPARSER_USE_CURTAILMENT;

# Load Page Forms extension
wfLoadExtension( 'PageForms' );
$wgPageFormsAutocompleteOnAllChars = true;

# Load Semantic Result Formats extension
wfLoadExtension( 'SemanticResultFormats' );

# Load Replace Text extension
wfLoadExtension( 'ReplaceText' );

# Load User Merge extension
wfLoadExtension( 'UserMerge' );

# Load SyntaxHighlight_GeSHi extension
wfLoadExtension( 'SyntaxHighlight_GeSHi' );

# Load Maps extension
wfLoadExtension( 'Maps' );

# Load Semantic Organization extension
wfLoadExtension( 'SemanticOrganization' );

# Load VisualEditor extension
wfLoadExtension( 'VisualEditor' );
wfLoadExtension( 'Parsoid', 'vendor/wikimedia/parsoid/extension.json' );
$wgGroupPermissions['user']['writeapi'] = true;
$wgSessionsInObjectCache = true;
$wgVirtualRestConfig['modules']['parsoid'] = array(
        'url' => "http://semorg:80/rest.php",
        'forwardCookies' => true,
);
wfLoadExtension( 'VEForAll' );

# Allow display titles for automatically created page names
$wgRestrictDisplayTitle = false;

# Encode section IDs with modern html5 style so Scrollspy works with special chars
# becomes obsolete with MW 1.37
$wgFragmentMode = [ 'html5', 'legacy' ];

# Make Wiki private
$wgGroupPermissions['*']['createaccount'] = false;
$wgGroupPermissions['*']['read'] = false;
$wgGroupPermissions['*']['edit'] = false;
$wgGroupPermissions['user']['delete'] = true;

# Clean up navigation
$wgTweekiSkinHideAnon['navbar'] = true;
$wgTweekiSkinHideAnon['footer'] = true;
$wgTweekiSkinHideAll['footer-info'] = false;
$wgTweekiSkinHideAll['footer-places'] = true;
$wgTweekiSkinHideAll['footer-info-copyright'] = true;
$wgTweekiSkinHideAll['footer-icons'] = true;

# Show only latest editor in footer
$wgMaxCredits = 1;

# Increase Job Run Rate, to speed up assignation of categories/forms to pages
$wgJobRunRate = 10;

error_reporting(E_ERROR | E_PARSE);
