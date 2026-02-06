<#*************************************************************************************************************
Bryan Smith
    
.SYNOPSIS
    This script creates a detailed report on VCenter hosts as well as warranty information and site details.

.DESCRIPTION
    -  Collects host-level inventory data from vCenter using Get-View and host-scoped ESXCLI queries. 
    -  Designed as a reusable traversal engine for environment-wide reporting, validation, and automation.
    -  See README.md in the same github repo directory for details.

    Prerequisites: PowerCLI module, ImportExcel module, and an active PowerCLI session to the target VCenter.

**************************************************************************************************************#>

clear-host

#  Script Variables: 
    $VMHViewData = Get-View -ViewType HostSystem -property Name, config, configmanager, Hardware.SystemInfo, summary, tag, parent
    $SDate = Get-Date -UFormat %m_%d_20%y

#  Script Output
    $ExportReportPath = "C:\Users\bryan\OneDrive\Documents\homelab\vmware\powercli\InventoryScript\Output"
    $ExportReportFile = "$ExportReportPath\VMware host inventory $SDate.xlsx"

<#-------------------------------------------Import-ExternalData------------------------------------------------------------#>
    $AllSiteLocalData = import-csv "C:\Users\bryan\OneDrive\Documents\homelab\vmware\powercli\InventoryScript\Input\sites.csv"    
    $SourceAssetsXLS = "C:\Users\bryan\OneDrive\Documents\homelab\vmware\powercli\InventoryScript\Input\LabHardware.xlsx"
    #  Copy HW assets XLS to an object
        $AllAssets = import-excel $SourceAssetsXLS -WorksheetName 'Assets' -AsDate 'Support Start','Support End'

<#===========================================================Start:  GET-HOSTDATA========================================================================#>
ForEach ($pARTYgIVER in $VMHViewData){                                        
    Write-Host "Processing host: " -Fore gre -back wh -NoNewLine; Write-Host $pARTYgIVER.Name -Fore bla -back gre

    # Get-VMHostSiteCode
            $PGName = $pARTYgIVER.Name

        # Format: BSUS103VM01 = US103
                if ($PGName -match '(?i)(US|CA)(\d{3})') {
                    $SiteCode = ($matches[1].ToUpper() + $matches[2])
                }
                else {
                    $SiteCode = '!! ERROR'
                }

    #  Get-LicenseInfo
    $Licenses = (Get-View -Id (Get-View LicenseManager).LicenseAssignmentManager).QueryAssignedLicenses($global:DefaultVIServers.InstanceUid) | %{
    
        $_ | select @{N='vCenter';E={$global:DefaultVIServers.Name}},EntityDisplayName,
            @{N='LicenseKey';E={$_.AssignedLIcense.LicenseKey}},
            @{N='LicenseName';E={$_.AssignedLicense.Name}},
            @{N='ExpirationDate';E={$_.AssignedLicense.Properties.where{$_.Key -eq 'expirationDate'}.Value }}
        } 
    <#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Start: Build-VMHostObject----->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#>
    #  NOTE: 
        #  "$pARTYgIVER" is a host object ("Party-giver" was a listted synonym for host).
        #  Powershell and PowerCLI use the word "host" in cmdlets; "$pARTYgIVER" is easier to see and search.
        
                $pARTYgIVER | Add-Member -NotePropertyMembers @{
                #-----------Get-HostHardwareAndConfig---------------------------------------------------------------------------------------#                    
                                                'Model' = $pARTYgIVER.Hardware.SystemInfo.Model
                                                'version' = $pARTYgIVER.CONFIG.Product.version
                                                'build' = $pARTYgIVER.CONFIG.Product.build  
                                                'HostName' = $pARTYgIVER.Name  
                                                'Local Disk' = $pARTYgIVER.config.FileSystemVolume.MountInfo.volume.Name
                                                'Support Start' = $Null
                                                'Support End' = $Null
                                                    'vmk0 IP' = ($pARTYgIVER.Config.Network.Vnic | ? {$_.Device -eq "vmk0"}).Spec.Ip.IpAddress
                                                'vmk0 mask' = $Null                
                                                'vmk0 CIDR' = $Null
                                                'Status' = $Null
                                                'Image Profile' = ((get-view $pARTYgIVER.ConfigManager.ImageConfigManager).HostImageConfigGetProfile().name)
                                                'Remote Mgt IP' = $Null
                                                'Disk Free (%)' = $Null             
                                                'Uptime (days)' = ([Math]::Truncate($pARTYgIVER.Summary.QuickStats.Uptime/86400))
                                                'Serial' = (($pARTYgIVER.Hardware.SystemInfo.OtherIdentIfyingInfo | 
                                                                where {$_.IdentIfierType.Key -eq 'ServiceTag' }).IdentIfierValue)                                                                                        
                                                    #  NOTE:  VMWare exposes all vendor serial numbers as 'ServiceTag'  
                                                
                                                'License Key'= $null
                                                'License Type' = $null
                #-----------Get-SiteGeneralInfo--------------------------------------------------------------------------------------------#
                                                'Site Code' = $SiteCode                                  
                                                'Site Contact' = $null
                                                'Site Contact: Email' = $null                   
                                                'Address'= $null  
                                                'City'= $null
                                                'State' = $null
                                                'Zip Code' = $null                                                                    
                                                'Country' = $null 
    
                    }
    <#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<End: Build-VMHostObject----->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#>
            
            #-----------Get-LicenseInfo-----------------------------------------------------------------------------------------------------#   
            Foreach ($License in $Licenses) {
                if ($pARTYgIVER.name -eq $License.EntityDisplayName){
                        $pARTYgIVER.'License Type' = $License.licenseName
                        $pARTYgIVER.'License Key' = $License.licensekey
                }}

            #-----------Get-HostCidrAndNetMask----------------------------------------------------------------------------------------------#       
            $Mask = ($pARTYgIVER.Config.Network.Vnic | ? {$_.Device -eq "vmk0"}).Spec.IP.SubnetMask

            # Convert the numbers into 8 bit blocks, join them all together, count the 1
                $Octets = $Mask.ToString().Split(".") | ForEach-Object -Process {[Convert]::ToString($_, 2)}
                $CIDR_Bits = ($Octets -join "").TrimEnd("0")
    
            # Count the "1" (111111111111111111111111 --> /24)                     
                $pARTYgIVER.'vmk0 mask' = $CIDR_Bits.Length             

                $vmk0IPToCidrNetwork = [IPAddress] (([IPAddress] $pARTYgIVER.'vmk0 IP').Address -band ([IPAddress] $mask).Address)

            $pARTYgIVER.'vmk0 CIDR' = $vmk0IPToCidrNetwork.IPAddressToString+"/"+$pARTYgIVER.'vmk0 mask'
                
            #-----------Get-RemoteMgtIP-----------------------------------------------------------------------------------------------------# 
                    $ESXcli = Get-EsxCli -VMHost $pARTYgIVER.Name -V2
                    $MgtIPTtest = out-string -inputobject $ESXcli.hardware.ipmi
                    
                            If ($MgtIPTtest.contains('bmc')){
                                    $pARTYgIVER.'Remote Mgt IP' = $ESXcli.hardware.ipmi.bmc.get.Invoke().IPv4Address
                                }
                                Else {$pARTYgIVER.'Remote Mgt IP' = '!!Check VIBs'}           

            #-----------Process-WarrantyData-----------------------------------------------------------------------------------------------#       
                #  Find support start and end date for this asset 
                    ForEach ($Asset in $AllAssets){
                        $AssetT = $Asset.'Serial Number'
                        
                        If ($AssetT -like $pARTYgIVER.Serial){
                            
                            If ($Null -eq $Asset.'Support Start' -or $Null -eq $Asset.'Support End'){
                                $pARTYgIVER.'Support Start' = $pARTYgIVER.'Support End' = $pARTYgIVER.Status = '! Data'}
                                
                                Else { 
                                    $pARTYgIVER.'Support Start' = $Asset.'Support Start'.ToString("MM/dd/yyyy")
                                    $pARTYgIVER.'Support End' = $Asset.'Support End'.ToString("MM/dd/yyyy")

                                    $CurrentYear = [int]$SDate.Substring($SDate.Length - 4)
                                    $YearPurchased = [int]$pARTYgIVER.'Support Start'.Substring($pARTYgIVER.'Support Start'.Length - 4)
                                    $YearSupportEnd = [int]$pARTYgIVER.'Support End'.Substring($pARTYgIVER.'Support End'.Length - 4)                                  
                                            $YearsOld = $CurrentYear - $YearPurchased
                                    
                                    If ($YearsOld -ge 7)    {$pARTYgIVER.'status' = 'REPLACE'}
                                        ElseIf ($YearsOld -le 6 -and $YearSupportEnd -le $CurrentYear)   {$pARTYgIVER.'status' = 'RENEW'}
                                        Else {$pARTYgIVER.'status' = 'OK'}               
                        }}}
                            #   Error if serial is null  
                                    If ($pARTYgIVER.serial -like $Null)   {$pARTYgIVER.serial = '!!Check VIBs'}   
                    
                #-----------Get-SiteData---------------------------------------------------------------------------------------------------#       
                    ForEach ($LocalData in $AllSiteLocalData){
                        $LocalDataT = $LocalData.'site code'                                                   
                                If ($LocalDataT -eq $pARTYgIVER.'site code'){
                #---------------Get-Contacts-----------------------------------------------------------------------------------------------#  
                                        $pARTYgIVER.'Site Contact' = $LocalData.'Contact Name'
                                            $pARTYgIVER.'Site Contact: Email' = $LocalData.'Contact Email Address'        
                #---------------Address----------------------------------------------------------------------------------------------------#       
                                        $pARTYgIVER.'Address'= $LocalData.'Address'        
                                            $pARTYgIVER.'City'= $LocalData.'City'
                                            $pARTYgIVER.'State' = $LocalData.'State'
                                            $pARTYgIVER.'Zip Code' = $LocalData.'Zip Code'                                                                    
                                        $pARTYgIVER.'Country' = $LocalData.'Country'  
}}}
<#===========================================================End:  GET-HOSTDATA================================================================================#>


                                                                                                   
<#===========================================================Start:  Export-data============================================================================== #>
  
$VMHViewData |  Select-Object 'Site Code', 'City', 'HostName', 'version', 'build', 'vmk0 IP', 'vmk0 mask', 'vmk0 CIDR', 'Remote Mgt IP', 'Image Profile', Status, 
                    'Uptime (days)', 'Model', 'Serial', 'Support End', 'Support Start', 'License Key', 'License Type', 'Site Contact', 'Site Contact: Email', 
                    'Address','State', 'Zip Code', 'Country' | 
                        Sort-Object 'HostName' |
        Export-Excel -Path $ExportReportFile -WorksheetName "$global:DefaultVIServers" -autosize -StartRow 4  -TableName HostInv  -TableStyle Medium13 -Show

                                                        start-sleep -Seconds 1  

<#+===========================================================End:  Export-data===+============================================================================#>

Write-host "Report is available at:  $ExportReportFile"  -Fore gre
