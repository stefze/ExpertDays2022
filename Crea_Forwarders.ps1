#version 1.3
$path = "c:\temp\zone.csv"
$masterservers = @("10.0.0.20")
$ReplicationScope = "Forest"
$cforwarders = import-csv $path -Delimiter ";"
foreach ($forwarder in $cforwarders) {
    if (!(get-dnsserverzone -Name $($forwarder.public)  -ErrorAction SilentlyContinue)) {
        write-host "Creo Conditional Forwarder per la zona $($forwarder.public)" -foregroundcolor green
        Add-DnsServerConditionalForwarderZone -Name $($forwarder.public) -ReplicationScope $ReplicationScope -MasterServers $MasterServers
    }
    else {
        write-host "Conditional Forwarder $($forwarder.public) presente" -foregroundcolor yellow
    }
}
