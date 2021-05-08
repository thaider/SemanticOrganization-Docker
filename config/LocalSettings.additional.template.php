<?php
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
enableSemantics();
$smwgEnabledEditPageHelp = false;
$smwgPageSpecialProperties[] = '_CDAT';
$smwgParserFeatures = $smwgParserFeatures | SMW_PARSER_LINV;

# Load Page Forms extension
wfLoadExtension('PageForms');
$wgPageFormsAutocompleteOnAllChars = true;

# Load Semantic Result Formats extension
wfLoadExtension( 'SemanticResultFormats' );

# Load Replace Text extension
wfLoadExtension( 'ReplaceText' );

# Load SyntaxHighlight_GeSHi extension
wfLoadExtension( 'SyntaxHighlight_GeSHi' );

# Load Semantic Organization extension
wfLoadExtension('SemanticOrganization');

# Allow display titles for automatically created page names
$wgRestrictDisplayTitle = false;

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