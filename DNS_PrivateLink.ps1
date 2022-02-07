#version 1.5
$SubName = "PocSub"
$RGvnet = "A-ExpD"
$RGPriv = "rsg-dns"
$virtualnetwork = "vnethub"
$path = "C:\Lavoro\Readiness\2022\ExpertDays-2022\zone.csv"
$ErrorActionPreference = "Stop"
#Check and Set subscription context
if ((get-azcontext).subscription.name -ne $SubName) {
    set-azcontext -subscriptionname $SubName
}
if (!(Get-AzResourceGroup -name $RGPriv -ErrorAction SilentlyContinue)) {
    Write-host "Il Resource Group $RGPriv non esiste" -ForegroundColor yellow
    Write-host "Procedo alla creazione" -ForegroundColor yellow
    New-AzResourceGroup -Name $rgpriv -Location westeurope
}
if (!($vNet = Get-AzVirtualNetwork -Name $virtualnetwork -ResourceGroupName $RGvnet)) {
    Write-Host "La vNET $virtualnetwork non esiste" -ForegroundColor Red
    Write-host "Esco" -ForegroundColor Red
    Break
}
$privatednszones = import-csv $path -Delimiter ";"
foreach ($pzone in $privatednszones) {
    if (!(get-azprivatednszone -Name $($pzone.private) -ResourceGroupName $RGPriv -ErrorAction SilentlyContinue)) {
        Write-Host "Creo la zona" $($pzone.private) -ForegroundColor Green
        New-AzPrivateDnsZone -Name $($pzone.private) -ResourceGroupName $RGPriv
        $linkname = "dnslink-$($pzone.name)"
        Write-Host "Creo il link per $($pzone.private) sulla vNET $($vnet.name)" -foregroundcolor Green
        New-AzPrivateDnsVirtualNetworkLink -Name $linkname -zoneName $($pzone.private) -ResourceGroupName $RGpriv -virtualnetworkid $vNet.Id
    }
    else {
        Write-Host "La zone Privata $($pzone.private) esiste" -ForegroundColor Yellow
        $linkname = "dnslink-$($pzone.name)"
        if (!(Get-AzPrivateDnsVirtualNetworkLink -Name $linkname -zoneName $($pzone.private) -ResourceGroupName $RGpriv -ErrorAction SilentlyContinue)) {
            Write-Host "Creo il link per $($pzone.private) sulla vNET $($vnet.name)"
            New-AzPrivateDnsVirtualNetworkLink -Name $linkname -zoneName $($pzone.private) -ResourceGroupName $RGpriv -virtualnetworkid $vNet.Id
        }
        else {
            Write-Host "Link esistente per la zona $($pzone.private)" -ForegroundColor Yellow
        }
    }
}