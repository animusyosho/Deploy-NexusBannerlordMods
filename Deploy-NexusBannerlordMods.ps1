Param (

   [Parameter(Mandatory = $true)]
   [string]$BannerlordPath, # Where bannerlord is installed. Common path: 'C:\Program Files(x86)\steam\steamapps\common\Mount & Blade II Bannerlord\'

   [Parameter(Mandatory = $true)]
   [string]$BannerlordModsPath, # Where vortex keeps mods. Common path: 'C:\Users\YourUserNameHere\AppData\Roaming\Vortex\mountandblade2bannerlord\mods\'
   
   [Parameter(Mandatory = $false)]
   [switch]$MergeConfigs = $false  # Use this switch only if you want to maintain config settings you have changed in some mods to be maintained - Note that this can break or miss changes if the mod author significantly changes the default config file or totally miss the file if it is in a weird place or has a weird name!
   
)

## Source: https://github.com/animusyosho/Deploy-NexusBannerlordMods/

$Error.Clear()

# Functions from mergeXml module with a change to the logging from write-host to write-verbose - https://gallery.technet.microsoft.com/office/Merge-Two-XML-Files-using-a5010498
<#
    Script     : MergeXml
    Author     : Riwut Libinuko
    Blog       : http://blog.libinuko.com
    Copyright© 2011, Riwut Libinuko (IdeasFree - cakriwut@gmail.com). All Rights Reserved.    
#>

function Merge-XmlFile {
   <#
.SYNOPSIS
Merge source XML file to target XML file and update only modified element. 
		
.DESCRIPTION
The function takes Xml filepath and merge the content to Xml filepath output. It is usuful to merge any 
XML's like file, such as .proj, web.config, app.config.
In that case you will be able to package only the essential element, and this function will merge it 
automatically. The old Xml target file will be stored as a backup file.
    
.INPUTS
None. You can not pipe objects to Merge-XmlFile
	
.OUTPUTS
None. No output from Merge-XmlFile
		
.PARAMETER sourceXmlFile
MANDATORY parameter to specify the source Xml filename. 
	
.PARAMETER targetXmlFile
MANDATORY parameter to specify target Xml filename.
        	
.EXAMPLE
    PS>  Merge-XmlElement "additionalweb.config" "web.config"
			

	Description
	-----------
	Update web.config based on additionalweb.config content. The function will search and update according the the tag,
    attribute and element.
    When there is doubt in the Xml, you have to specify Select keyword to select specific key, or
    Remove keyword to remove specific key. For example appSettings section in the web.config, as follows
    
    Example: 
    additionalweb.config
    <configuration>
       <appSettings>
         <!--Select=add[@key='Keyword']-->
         <add key="Keyword" value="SharePoint,PowerShell" />
         <!--Remove=add[@key='OldKeyword']-->
         <add key="OldKeyword" value="SharePoint 2007" />
       </appSettings>
    </configuration>
    
    web.config
    <configuration>
       <appSettings>
         <add key="Keyword" value="SharePoint 2007,PowerShell" />         
         <add key="OldKeyword" value="SharePoint 2007" />
       </appSettings>
    </configuration>
    
    After the operation, web.config will become
    <configuration>
       <appSettings>
         <add key="Keyword" value="SharePoint,PowerShell" />                  
       </appSettings>
    </configuration>
    
		            
.LINK
    Author blog  : IdeasForFree  (http://blog.libinuko.com)
.LINK
    Author email : cakriwut@gmail.com
#>
   param ( 
      [Parameter(Mandatory = $true, Position = 0)]            
      $sourceXmlFile, 
      [Parameter(Mandatory = $true, Position = 1)]       
      $targetXmlfile 
   )
  
   if (!(test-path $sourceXmlFile)) {
      Write-Verbose "Can not find source XML file. $sourceXmlFile."
   }
   if (!(test-path $targetXmlfile)) {
      Write-Verbose "Can not find target XML file. $targetXmlFile."
   }
   
   $target = gi $targetXmlfile
   $backup = (join-path $target.Directory $target.BaseName) + "_" + (get-date).tostring("yyyy_MM_dd_hh_mm_ss") + ".bak"  
  
   $xmlSource = [xml](get-content $sourceXmlFile)  
   $xmlTarget = [xml](get-content $targetXmlfile)
   #save backup
   $xmlTarget.Save($backup)
   
   $SourceElement = $xmlSource.get_Documentelement()
   $TargetElement = $xmlTarget.get_DocumentElement() 
  
   Merge-XmlElement $SourceElement $TargetElement
   
   #save backup
   $xmlTarget.Save($targetXmlFile)
}

function Merge-XmlElement { 
   <#
.SYNOPSIS
Merge source XML element to target XML element and update only modified element. 
		
.DESCRIPTION
The function takes XmlElement input and merge the content to XmlElement output. It is usuful to merge any XML's like file, such as .proj, web.config, app.config.
In that case you will be able to package only the essential element, and this function will merge it automatically.
    
.INPUTS
None. You can not pipe objects to Merge-XmlElement
	
.OUTPUTS
None. No output from Merge-XmlElement
		
.PARAMETER sourceElement
MANDATORY parameter to specify the source Xml element. 
	
.PARAMETER targetElement
MANDATORY parameter to specify target Xml element.
        	
.EXAMPLE
    PS>  $xmlWebConfig = [xml](get-content "web.config")  
    PS>  $xmlUpdateWebConfig = [xml](get-content "additionalweb.config")
	PS>  $targetRoot = $xmlWebConfig.get_DocumentElement()
    PS>  $sourceRoot = $xmlUpdateWebConfig.get_DocumentElement()
    PS>  Merge-XmlElement $sourceRoot $targetRoot
			

	Description
	-----------
	Update web.config based on additionalweb.config content. The function will search and update according the the tag, attribute and element.
    When there is doubt in the Xml, for example appSettings section in the web.config, you have to specify Select keyword to select specific key, or
    Remove keyword to remove specific key.
    
    Example: 
    additionalweb.config
    <configuration>
       <appSettings>
         <!--Select=add[@key='Keyword']-->
         <add key="Keyword" value="SharePoint,PowerShell" />
         <!--Remove=add[@key='OldKeyword']-->
         <add key="OldKeyword" value="SharePoint 2007" />
       </appSettings>
    </configuration>
    
    web.config
    <configuration>
       <appSettings>
         <add key="Keyword" value="SharePoint 2007,PowerShell" />         
         <add key="OldKeyword" value="SharePoint 2007" />
       </appSettings>
    </configuration>
    
    After the operation, web.config will become
    <configuration>
       <appSettings>
         <add key="Keyword" value="SharePoint,PowerShell" />                  
       </appSettings>
    </configuration>
    
		            
.LINK
    Author blog  : IdeasForFree  (http://blog.libinuko.com)
.LINK
    Author email : cakriwut@gmail.com
#>
   param ( 
      [Parameter(Mandatory = $true, Position = 0)]
      [System.Xml.XmlElement]                    
      $sourceElement,
      [Parameter(Mandatory = $true, Position = 1)]
      [System.Xml.XmlElement]        
      $targetElement 
   )
    
   if ($sourceElement.get_Name() -ne $targetElement.get_Name()) { 
      Write-Verbose "Source element name $($sourceElement.get_Name()) and target element name $($targetElement.get_Name()) do not match" 
      return
   } 
     
   if (-not $sourceElement.get_HasChildNodes()) { return } 
  
   $sourceChildren = $sourceElement.get_Childnodes() 
   $targetChildren = $targetElement.get_Childnodes()
   $prevChild = $null
  
   foreach ($sourceChild in $sourceChildren) {     
      if ($sourceChild.get_Name() -eq "#comment") { 
         $prevChild = $sourceChild       
         continue 
      }
              
      $matchingNode = $False 
      $targetChild = $Null 
      $select = $False
      $remove = $False
     
      foreach ($child in $targetChildren ) {
         $targetChild = $child
         if (($select = ($prevChild -and $prevChild.Value.StartsWith("Select="))) `
               -or ($remove = ($prevChild -and $prevChild.Value.StartsWith("Remove=")))) { break; }        
                            
         if ($sourceChild.get_Name() -eq $targetChild.get_Name()) {         
            OverrideAttribute $sourceChild $targetChild
            $matchingNode = $True
            break;       
         }       
      } #end foreach TargetChildren
                 
      if ($matchingNode -eq $False) { 
         if ($select) {            
            if (($selectedElement = $targetElement.SelectSingleNode($prevChild.Value.Trim().Remove(0, 7)))) {
               OverrideAttribute $sourceChild $selectedElement
            }
            else {
               AppendElement $sourceChild $targetElement
            }
         }
         elseif ($remove) {
            if (($selectedElement = $targetElement.SelectSingleNode($prevChild.Value.Trim().Remove(0, 7)))) {
               Write-Verbose "Removing element $($selectedElement.OuterXml)"
               $selectedElement.RemoveAll()
            }
         }
         else {
            AppendElement $sourceChild $targetElement
         }

      }
      else { 
         if ($sourceChild.get_HasChildNodes()) {
            Merge-XmlElement $sourceChild $targetChild
         }
      }               
      $prevChild = $null
   } #end foreach SourceChildren
   
}

function OverrideAttribute {
   param(
      $Source,
      $Target
   )
   
   foreach ($SourceAttribute in $Source.get_Attributes()) {
      if ($SourceAttribute.get_Value() -ne $Target.GetAttribute($SourceAttribute.get_Name())) {
         Write-Verbose "Override attribute $($SourceAttribute.get_Name()) , $($Target.GetAttribute($SourceAttribute.get_Name())) => $($SourceAttribute.get_Value())" 
      }
      $Target.SetAttribute($SourceAttribute.get_Name(), $SourceAttribute.get_Value())
   }
}

function AppendElement {
   param (
      $Source,
      $Target
   )
   $NewElement = $Source.CloneNode($True)
   $Target.AppendChild($Target.get_OwnerDocument().ImportNode($NewElement, $True))
   $Target.Normalize()
}

# Hardcoded variable definition
$NativeModulesList = @('Native', 'CustomBattle', 'SandBox', 'SandBoxCore', 'StoryMode') # Modules we leave alone, unless there is an override
$OverrideModules = @()
$NewModules = @()
$BannerlordInstalledModulesPath = "$BannerlordPath\modules".replace('\\', '\')
$Timestamp = Get-Date -UFormat %Y%m%dT%H%M%S
$BannerlordModsConfigBackupPath = "$BannerlordModsPath\..\Config Backups\".replace('\\', '\')
$BackupsToKeep = 50
if (!(Test-Path -Path $BannerlordModsConfigBackupPath)) {
   $CreateMissingDirectory = New-item -ItemType Directory -Path $BannerlordModsConfigBackupPath -Force
}

# Get module directories.
$NewModulesSourceDirectories = Get-ChildItem -Path $BannerlordModsPath -Directory -ErrorAction SilentlyContinue -Depth 2 | Where-Object -Property FullName -NotIn (Get-ChildItem -Path $BannerlordModsPath -Directory -ErrorAction SilentlyContinue -Depth 1).FullName
$CurrentOverrideModDirectories = Get-ChildItem -Path $BannerlordInstalledModulesPath -Directory -ErrorAction SilentlyContinue | Where-Object -Property Name -NotIn $NativeModulesList

if (!$NewModulesSourceDirectories) {
   Write-Error "No modules found in path '$BannerlordInstalledModulesPath'."
}
elseif (!$CurrentOverrideModDirectories) {
   Write-Error "No modules found in path '$BannerlordModsPath'"
}
else {
   # First we need to fetch all of the files in both locations to work with later. Using these loops to organize some objects for easier data work later.
   foreach ($OverrideModuleDirectory in $CurrentOverrideModDirectories) {
      $ConfigBackupPath = "$BannerlordModsConfigBackupPath\$($OverrideModuleDirectory.Name)"
      $ConfigFiles = $null
      $OverrideModule = $null
      $OverrideModule = New-Object -TypeName PSCustomObject -Property @{
         'ModuleName'  = $OverrideModuleDirectory.Name
         'ModuleFiles' = $OverrideModuleDirectory | Get-ChildItem -Recurse -File
      }
      $ConfigFiles = $OverrideModule.ModuleFiles | Where-Object -FilterScript { $_.FullName.tolower() -match '.*\\moduledata\\.*config.*\.xml' }
      if ($ConfigFiles) {
         $OverrideModule | Add-Member -MemberType NoteProperty -Name 'ConfigFiles' -Value $ConfigFiles
         if (!(Test-Path -Path $ConfigBackupPath)) {
            $CreateMissingDirectory = New-item -ItemType Directory -Path $ConfigBackupPath -Force
         }
      }
      $OverrideModules += $OverrideModule
      
      # Back up your currently installed module configs.
      foreach ($ConfigFile in $ConfigFiles) {
         $BackupConfig = $ConfigFile | Copy-Item -Destination "$ConfigBackupPath\$($Timestamp)_$($ConfigFile.Name)" -Force
      }
      # Clean up old backups if you have more than allowed.

      $Backups = Get-ChildItem -Path $ConfigBackupPath -ErrorAction Ignore | Sort-Object -Property LastWriteTime
      if ($Backups -and $Backups.Count -gt $BackupsToKeep) {
         $BackupsToDelete = $Backups.Count - $BackupsToKeep
         $RemoveOldestBackups = $Backups | Select-object -First $BackupsToDelete
      }
   } 
   foreach ($NewModuleDirectory in $NewModulesSourceDirectories) {
      $ConfigFiles = $null
      $NewModule = $null
      $NewModule = New-Object -TypeName PSCustomObject -Property @{
         'ModuleName'  = $NewModuleDirectory.Name
         'ModuleFiles' = $NewModuleDirectory | Get-ChildItem -Recurse -File
      }
      $ConfigFiles = $NewModule.ModuleFiles | Where-Object -FilterScript { $_.FullName.tolower() -match '.*\\moduledata\\.*config.*\.xml' }
      if ($ConfigFiles) {
         $NewModule | Add-Member -MemberType NoteProperty -Name 'ConfigFiles' -Value $ConfigFiles
      }
      $NewModules += $NewModule
   }

   # Merge Configs if switched on.
   if ($MergeConfigs) {
      foreach ($OverrideModule in $OverrideModules) {
         $OverrideModuleName = $OverrideModule.ModuleName
         foreach ($ConfigFile in $OverrideModule.ConfigFiles) {
            $MatchedConfig = $null
            $MatchedConfig = ($NewModules | Where-Object -FilterScript { $_.ConfigFiles }).ConfigFiles | Where-Object -FilterScript { $_.FullName.tolower() -match ".*\\$($OverrideModuleName.tolower())\\.*$($ConfigFile.Name.tolower())" }
            if ($MatchedConfig) {
               if ($MatchedConfig.Count -gt 1) {
                  Write-Error "Something went wrong! The script matched more than one config to file '$($ConfigFile.FullName)'"
               }
               else {
                  $MergeXmlFile = Merge-XmlFile -targetXmlfile $ConfigFile.FullName -sourceXmlFile $MatchedConfig.FullName
                  $CopyMergedFile = Copy-Item -Path $ConfigFile.FullName -Destination $MatchedConfig.FullName -Force
               }
            }
         }
      } 
   }

   # Delete old modules
   $ModulesToRemove = $OverrideModules | Where-Object -Property ModuleName -NotIn $NativeModulesList
   $RemoveOldModules = $ModulesToRemove.ModuleFiles | Remove-Item -Force

   # Finally, deploy modules!
   foreach ($NewModuleDirectory in $NewModulesSourceDirectories) {
      $CopyFiles = Copy-Item -Path $NewModuleDirectory.FullName -Destination $BannerlordInstalledModulesPath -Recurse -Force 
   }  

   # Give a success message if all has gone without errors. If any errors happened inform the user for troubleshooting purposes. 
   Add-Type -AssemblyName PresentationCore, PresentationFramework
   if ($Error) {
      [System.Windows.MessageBox]::Show($Error, 'Error Encountered! Deployment may be incomplete.', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
   }
   else {
      [System.Windows.MessageBox]::Show('Deployment Complete!', 'Success', [System.Windows.MessageBoxButton]::OK)
   }
   Exit
}
