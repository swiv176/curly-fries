

$EC2List = @()
$ResourceList = @()

$VolumeData = Get-EC2Volume -ProfileName <#insertProfilename#>  -Region <#insertRegion#>  | Select *
(Get-EC2Instance -ProfileName <#insertProfileId#>  -Region <#insertRegion#> ).Instances |`
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
  


  $EC2ImageData = (Get-EC2Image -Owners <#insertOwnerid#>  | Select *)


  #($VolumeData| Where {$_.State -ne "in-use"})[0].Tags

   $SnapShotData = @()
   Get-EC2Snapshot -OwnerIds <#insertOwnerid#> | Foreach -Process {
   $AmiId = ($_.Description -split " ")[4]
    $Obj4 = New-Object PSObject -Property @{
        Description = $_.Description
        OwnerId = $_.OwnerId
        StartTime = $_.StartTime
        Progress = $_.Progress
        SnapshotId = $_.SnapshotId
        VolumeId = $_.VolumeId
        VolumeSize = $_.VolumeSize
        AmiId = $AmiId
        
    }
      $SnapShotData += $Obj4
   }

   #((Get-EC2Snapshot -OwnerIds 724809074197)[0].Description -split " ")[4]


  $Date = (Get-Date)  
 $UnusedVol = @()
 $VolumeData| Where {$_.State -ne "in-use"} | Foreach -Process { 
      $VId = $_.SnapShotId
      $Amid2 = ($SnapShotData | Where {$_.SnapshotId -eq $Vid}).AmiId
      $AmiName = ($EC2ImageData | Where {$_.ImageId -eq $Amid2}).Name
      $duration = New-TimeSpan -Start $_.CreateTime -End $Date
      #Calulate Cost
      If ( $_.VolumeType -eq "standard"){
        $price = .12 #per GB
        $rate = 30 #days
        $GB = $_.Size
        $Cost = "{0:N2}" -f (($price*$GB)/$Rate)
        $ProjCost = "{0:N2}" -f ($price*$GB) 
      }

       ElseIf ( $_.VolumeType -eq "gp2"){
        $price = .065 #per GB
        $rate = 30 #days
        $GB = $_.Size
        $Cost =  "{0:N2}" -f (($price*$GB)/$Rate)
        $ProjCost = "{0:N2}" -f ($price*$GB)
      }
  
         ElseIf ( $_.VolumeType -eq "io1"){
        $GBprice = .150 #per GB
        $IOPrice = .078 #per Iops
        $rate = 30 #days
        $GB = $_.Size
        $iops = $_.Iops
        $Cost =  "{0:N2}" -f ((($GBprice*$GB)/$Rate) +(($IOprice*$iops)/$Rate))
        $ProjCost = "{0:N2}" -f (($GBprice*$GB) +($IOprice*$iops)) 
      }
            
      else {$Cost = $_.VolumeType + " storage type could not be calulated."}
    $Obj3 = New-Object PSObject -Property @{
        VolumeId = $_.VolumeId
        Status = $_.Status
        VolumeType = $_.VolumeType
        Iops = $_.Iops
        Size = $_.Size
        SnapshotId = $_.SnapshotId
        CreateTime = $_.CreateTime
        AmiId = $Amid2
        AmiName = $AmiName
        Duration = $duration
        CurrentCost = $Cost
        ProjMonthCost = $ProjCost
    }
    $UnusedVol += $Obj3
 }
 
 
 
  $UnusedVol |Select VolumeId, status, VolumeType, Iops, Size, SnapshotId, CreateTime, AmiId, AmiName, Duration, CurrentCost, ProjMonthCost |`
   Export-Csv -Path path -NoTypeInformation -Force

   $ResourceList |Select InstanceName, InstanceId, InstanceType, PrivateIpAddress, PublicIpAddress, VpcId, TotalVolumes, TotalStorage, TotalIOPS |`
    Export-Csv -Path path -NoTypeInformation -Force