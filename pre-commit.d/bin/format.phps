#!/usr/bin/php7.0
<?php

error_reporting(E_ALL | E_STRICT);
require_once ('PHP/Beautifier.php');
require_once ('PHP/Beautifier/Batch.php');

$CodePath = '/home/tim/code/KwaMoja/';
try {
	$oBeaut = new PHP_Beautifier();
	$oBeaut->setIndentNumber(1); /* default */
	$oBeaut->setIndentChar("\t"); /* default */
	$oBeaut->setNewLine("\n"); /* default */

	$oBeaut->addFilter('ArrayNested');
	$oBeaut->addFilter('Default');
	$oBeaut->addFilter('Lowercase');
	$oBeaut->addFilter('KeepEmptyLines');

	$oBeaut->setInputFile($CodePath . $argv[1]);
	$oBeaut->process();
	$oBeaut->show();
}
catch(Exception $oExp) {
	echo ($oExp);
}
?>