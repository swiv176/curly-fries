

#Verify AWS SDK was installed Properly
  Get-AWSPowerShellVersion -ListServices


#Storing Credentials
    #Add a new Profile to SDK Store , Uncomment to use
     Set-AWSCredentials -AccessKey <Access Key Id> -SecretKey <Secret Access Key> -StoreAs <User Name>

    #Remove Stored Credentials 
     #Clear-AWSCredentials -StoredCredentials <User Name>

#Listing S3 Content
    #List S3 Buckets
     Get-S3Bucket -ProfileName <User.Name> -Region region>

    #View Objects in S3 Bucket
     Get-S3Object -Region us-gov-west-1 -BucketName <bucket Name> -ProfileName <user name>| format-Table -Autosize

    #View objects in a specific Folder within in a bucket (Note: Bucket names and Keys are Case-Sensitive.)
     Get-S3Object -BucketName <bucket Name> -Key <FolderName/> -ProfileName <User name> -Region region>| ft -AutoSize

#Uploading to S3
    #Upload a single File 
     Write-S3Object -BucketName <BucketName>  -Key "Destination/Path/to/file.txt>" -File < Local\File\Path\to\file.txt> -ConcurrentServiceRequests <num of sessions to use> -Region region> -ProfileName <User Name> 

    #Upload Entire Folder
     Write-S3Object -BucketName <BucketName -KeyPrefix "Folder/Destination" -Recurse -Folder <Path\to\Folder> -Region region> -ProfileName <User Name>

#Downloading from S3
    #Download Single File 
     Read-S3Object -BucketName <BucketName>  -Key "Source/Path/to/file.txt>" -File < Local\File\Path\to\file.txt>  -Region region> -ProfileName <User Name>

    #Download Entire Folder 
     Read-S3Object -BucketName <BucketName -KeyPrefix "Folder/Source" -Folder <Path\to\destination\Folder> -Region region> -ProfileName <User Name>



     #Get List of Instancing being used in a vpc 
$EC2List = @()
(Get-EC2Instance -ProfileName profilename> -Region region>).Instances | Where {$_.vpcId -eq ""} |`
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

#BlockDeviceMappings
#InstanceId
#InstanceType
#NetworkInterfaces
#PrivateIpAddress
#PublicIpAddress
#SecurityGroups
#SubnetId
#VpcId

$EC2List | Select InstanceName, InstanceId, InstanceType, PrivateIpAddress, PublicIpAddress, SecurityGroups, SubnetId, VpcId, BlockDeviceMappings