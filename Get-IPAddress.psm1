function Get-IPAddress {
    <#
    .SYNOPSIS
        Extract IP address from txt or input
    .DESCRIPTION
        This function Extract IP address from txt or input
    .PARAMETER IPAddress
        The IP address or multiple
    .PARAMETER Type
        Default 'dual' - but can be changed to 'IPv4', 'IPv6'
    .EXAMPLE
        Get-IPAddress example.com
    .EXAMPLE
        Get-IPAddress "93.184.216.34"
    .EXAMPLE
        Get-IPAddress "93.184.216.34;93.184.216.35"
    .EXAMPLE
        Get-IPAddress "2606:2800:220:1:248:1893:25c8:1946"
    .EXAMPLE
        Get-IPAddress (Get-Content .\sample.txt )
    .EXAMPLE
        Get-IPAddress -type IPv4 (Get-Content .\sample.txt )
    .EXAMPLE
        Get-IPAddress -type IPv6 (Get-Content .\sample.txt )
    .NOTES
        Author: Henrik Bruun  Github.com @Henrik-Bruun
        Version: 1.0 2023 December.
    #>

    param (
        [String]$IPAddress = '92.246.24.228',
        [ValidateSet('dual', 'IPv4', 'IPv6')]
        [String]$type = 'dual'
    )

    ## Regex
    $IPv4Regex = '(((25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})\.){3}(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2}))'
    $G = '[A-Fa-f\d]{1,4}'
    # In a case insensitive regex, such as they by default are in PowerShell, you can use:
    #$G = '[a-f\d]{1,4}'
    $Tail = @(":",
        "(:($G)?|$IPv4Regex)",
        ":($IPv4Regex|$G(:$G)?|)",
        "(:$IPv4Regex|:$G(:$IPv4Regex|(:$G){0,2})|:)",
        "((:$G){0,2}(:$IPv4Regex|(:$G){1,2})|:)",
        "((:$G){0,3}(:$IPv4Regex|(:$G){1,2})|:)",
        "((:$G){0,4}(:$IPv4Regex|(:$G){1,2})|:)")
    [string] $IPv6RegexString = $G
    $Tail | foreach { $IPv6RegexString = "${G}:($IPv6RegexString|$_)" }
    $IPv6RegexString = ":(:$G){0,5}((:$G){1,2}|:$IPv4Regex)|$IPv6RegexString"
    $IPv6RegexString = $IPv6RegexString -replace '\(' , '(?:' # make all groups non-capturing

    $RegexString = $IPv6RegexString + '|' + $IPv4Regex
    if ($type -eq 'IPv6') { $RegexString = $IPv6RegexString }
    if ($type -eq 'IPv4') { $RegexString = $IPv4Regex }
    ## Regex EOF

    if ($IPAddress -match "$regexString") {
        ($IPAddress | Select-String -Pattern "$regexString" -AllMatches).Matches.Value | Sort-Object | Get-Unique
    } else {
        (Resolve-DnsName -Name $IPAddress -ErrorAction SilentlyContinue).IpAddress
    }
}
