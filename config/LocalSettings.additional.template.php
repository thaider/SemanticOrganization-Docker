<?php

$wgEnableUploads = true; 

$wgDefaultSkin = "tweeki";
$wgDefaultUserOptions['tweeki-advanced'] = 1; # Show Tweeki's advanced features by default
$wgTweekiSkinUseTooltips = true; # Use Bootstrap Tooltips

# Load Parser Functions extension
wfLoadExtension( 'ParserFunctions' );
$wgPFEnableStringFunctions = true; # Enable String Functions

# Enable Semantic MediaWiki
enableSemantics('localhost');
$smwgEnabledEditPageHelp = false;
$smwgLinksInValues = true;

# Load Page Forms extension
wfLoadExtension('PageForms');
$wgPageFormsAutocompleteOnAllChars = true;

# Load Semantic Organization extension
wfLoadExtension('SemanticOrganization');

# Allow display titles for automatically created page names
$wgRestrictDisplayTitle = false;

# Make Wiki private
$wgGroupPermissions['*']['createaccount'] = false;
$wgGroupPermissions['*']['read'] = false;
$wgGroupPermissions['*']['edit'] = false;

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
$wgJobRunRate = 100;

error_reporting(E_ERROR | E_PARSE);