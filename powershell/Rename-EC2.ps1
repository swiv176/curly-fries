


clear;

Initialize-AWSDefaults -ProfileName <#insertProfileName#>  -Region <#insertRegion#> 


 $EC2List = @()
$ResourceList = @()
$Ver = "2.8.2-" #Current Version
$Vpc = "vpc-fa667998" #Name VPC you want to change


$VolumeData = Get-EC2Volume | Select *
(Get-EC2Instance).Instances |`
 Foreach -Process {
    $Obj = New-Object PSObject -Property @{
        InstanceName = ($_.tags | Where {$_.Key -eq "Name"}).value
        InstanceId = $_.InstanceId
        InstanceType = $_.InstanceType
        PrivateIpAddress = $_.PrivateIpAddress
        PublicIpAddress = $_.PublicIpAddress
        SecurityGroups = $_.SecurityGroups
        SubnetId = $_.SubnetId
        VpcId = $_.VpcId
        BlockDeviceMappings = $_.BlockDeviceMappings

    }
    $EC2List += $Obj
 }   


 $EC2List | Foreach -Process {
    $InstanceData = $_
    $InstanceEBSData = $VolumeData | Where {$_.Attachment.InstanceId -eq $InstanceData.InstanceId}
    
    #$InstanceEBSData
    $Obj2 = New-Object PSObject -Property @{
        InstanceName = $_.InstanceName
        InstanceId = $_.InstanceId
        InstanceType = $_.InstanceType
        PrivateIpAddress = $_.PrivateIpAddress
        PublicIpAddress = $_.PublicIpAddress
        SecurityGroups = $_.SecurityGroups
        SubnetId = $_.SubnetId
        VpcId = $_.VpcId
        TotalVolumes = ($_.BlockDeviceMappings).count
        TotalStorage = ($InstanceEBSData | Measure-Object -Property Size -Sum).Sum
        TotalIOPS = ($InstanceEBSData | Measure-Object -Property IOPS -Sum).Sum       

    }
    $ResourceList += $Obj2
    }
  


$ProdName = $ResourceList | Where {$_.VpcID -eq "$vpc"} | Select InstanceName, InstanceId
$NewList = @()
$ProdName | Foreach -Process {
    
    $NewName = ($_.InstanceName)

    $Obj3 = New-Object PSObject -Property @{
        OldInstanceName = $_.InstanceName
        NewInstanceName =  "$Ver "+"$NewName"
        InstanceId = $_.InstanceId
    }
    $NewList += $Obj3
}

 

$NewList | Foreach -Process {
        $tag = New-Object Amazon.EC2.Model.Tag
        $tag.Key = "Name"
        $tag.Value = $_.NewInstanceName
        New-EC2Tag -Resources $_.InstanceId -Tags $tag

}
