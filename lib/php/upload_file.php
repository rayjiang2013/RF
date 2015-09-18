<?php
	if(!file_exists("upload")){
		mkdir ("upload");
	}
	if ($_FILES["file"]["error"]>0)
		{
		$er = "ERROR Return Code: " . $_FILES["file"]["error"] . "<br />";
		}
	else
		{
        /*echo "Upload: " . $_FILES["file"]["name"] . "<br />";
		  echo "Type: " . $_FILES["file"]["type"] . "<br />";
		  echo "Size: " . ($_FILES["file"]["size"]/1024) . " Kb<br />";
		  echo "Temp file: " . $_FILES["file"]["tmp_name"] . "<br />";
		*/		
		$img = $_FILES["file"]["name"];
		//$test = move_uploaded_file($_FILES["file"]["tmp_name"], 
		//"upload/" . $_FILES["file"]["name"]);
		//echo "Stored in: " . "upload/" . $_FILES["file"]["name"];
		//echo $t
        //echo  exec("python /var/www/html/Format/txt2xml.py --txtfile " . $_FILES["file"]["tmp_name"]);
        /* echo ($_POST["keyword"] . "<br />");
           echo ($_POST["status"] . "<br />");
        */
		if (strlen($_POST["status"]) == 0)
			{
			$_POST["status"]= "1";
			}
 		if (strlen($_POST["keyword"]) == 0)
			{
			$SAT = exec("python /var/www/html/Format/txt2xml.py --txtfile " . $_FILES["file"]["tmp_name"] . " --status " . $_POST["status"]);
			}
        else
			{
		    //echo ("1" . "<br />");
		    $SAT = exec("python /var/www/html/Format/txt2xml.py --txtfile " . $_FILES["file"]["tmp_name"] . " --keyword " . $_POST["keyword"] . " --status " . $_POST["status"]);
			}
		 //echo ("333" . "<br />");
		 //print_r($SAT);
	    if ($SAT == "{'status': 1}")
			{
		    //echo ("233" . "<br />");	 
            $RET = copy ($_FILES["file"]["tmp_name"].".xml" , "/var/www/html/Format/" . substr($_FILES["file"]["tmp_name"] , 5) . ".xml"); 
		    //echo ($RET . "<br />");
		    /*
		    echo ($RET . "<br />");
		    echo ($_FILES["file"]["tmp_name"].".xml". "<br />");
			$myfile = fopen($_FILES["file"]["tmp_name"].".xml" ,"r") or die("Unable to open file!");
            echo "<textarea cols='100' wrap = 'physical'>" . fread($myfile,filesize($_FILES["file"]["tmp_name"].".xml")) . "</textarea>";
            fclose($myfile);
		    echo "<pre>";
         	print_r($_POST);
		    print_r($_FILES);
            */		  
		    header("Location:./" . substr($_FILES["file"]["tmp_name"] , 5) . ".xml"); 			
		    //header("Location:./file.html"); 
			}
	    else
			{
			//echo ("6666" . "<br />");
			echo $SAT;
			}
		}
?>
