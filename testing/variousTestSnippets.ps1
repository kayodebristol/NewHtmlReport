## some test snippets, for interactive testing for now

## make a new, GUID-named dir so as to avoid any overwrites and name-collisions
$oTmpDir = New-Item -ItemType Directory -Path "${env:temp}\$(([System.Guid]::NewGuid()).Guid)"
$strTmpDirFilespec = $oTmpDir.FullName
## numbers for the tests
$intTestNum = 0

## just a dir, output to HTML table, with the few specified properties
New-HtmlReport -InputObject (Get-ChildItem ${env:temp}) -Title "$intTestNum) test HTML report" -Property Name, Length | Out-File -Encoding utf8 -FilePath $strTmpDirFilespec\testOut${intTestNum}.htm


## pipeline testing
## make a test report using just the contents of a temp dir with just the given properties (properties will be in property-name alphabetical order, since no -Property value specified to New-HtmlReport)
$intTestNum++
Get-ChildItem ${env:temp} | Select-Object Mode, LastWriteTime, Length, Name, @{n="bDoRowHighlight"; e={if ($_.Length -gt 100KB) {$true}}} | New-HtmlReport -Title "$intTestNum) objects from pipeline test HTML report" -PreContent "table columns should be in the order: Mode, LastWriteTime, Length, Name" -TableCaption "[this is the table caption] highlighted rows are of items that are larger than 100KB" | Out-File -Encoding utf8 -FilePath $strTmpDirFilespec\testOut${intTestNum}.htm

## make a test report using just the contents of a temp dir with just the given properties, but setting the particular property order by having specified the -Property param to New-HtmlReport
$intTestNum++
$hshParamForNewHtmlReport = @{
	PreContent = "<H3>Sweet report -- objects from pipeline</H3>Table columns should be in the order Mode, LastWriteTime, Length, Name"
	PostContent = "<SPAN CLASS='footerInfo'>[this is some footerInfo] Generated $(Get-Date -Format 'dd-MMM-yyyy HH:mm:ss \G\M\Tz')</SPAN>"
	Property = Write-Output Mode, LastWriteTime, Length, Name
	Title = "$intTestNum) objects from pipeline test HTML report"
	TableCaption = "[this is the table caption] child items in folder '`${env:temp}'"
} ## end hsh
Get-ChildItem ${env:temp} | New-HtmlReport @hshParamForNewHtmlReport | Out-File -Encoding utf8 -FilePath $strTmpDirFilespec\testOut${intTestNum}.htm


## make a test report with multiple tables in the page
$intTestNum++
$hshParamForNewHtmlReport = @{
	InputObject = Get-ChildItem ${env:temp} | Select-Object Name, LastWriteTime, Length, Mode
	PreContent = "<H3>Combined report -- multiple tables</H3>First table columns should be in order of Name, LastWriteTime, Length, Mode"
	## make second table for the PostContent, which is the "dir" of C:\, highlighting any object that is a Container (folder)
	PostContent = "<BR />",(New-PageBodyTableHtml -InputObject (Get-ChildItem C:\ | Select-Object Name, Length, LastWriteTime, @{n="bDoRowHighlight"; e={$_.PSIsContainer}})),"<SPAN CLASS='footerInfo'>[this is some footerInfo] Generated $(Get-Date -Format 'dd-MMM-yyyy HH:mm:ss \G\M\Tz')</SPAN>"
	Title = "$intTestNum) Combined Report"
	TableCaption = "[this is the table caption] child items in folder '`${env:temp}'"
} ## end hsh
New-HtmlReport @hshParamForNewHtmlReport | Out-File -Encoding utf8 -FilePath $strTmpDirFilespec\testOut${intTestNum}.htm


explorer.exe $strTmpDirFilespec
## clean-up:  remove the temporary directory and its contents
$oTmpDir | Remove-Item -Recurse