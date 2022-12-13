<?php


include 'connection.php';    

if(isset($_POST['patient-sub'])){
    $pid = $_POST['pid'];
    $pname = $_POST['pname'];
    $pAge = $_POST['pAge'];
    $pAddress = $_POST['pAddress'];
    $pArrivalDate = $_POST['pArrivalDate'];
    $pArrivalDate = date("Y-m-d", strtotime($pArrivalDate));
    $pComingFrom = $_POST['pComingFrom'];
    $pGoingTo = $_POST['pGoingTo'];
    $call = mysqli_prepare($con, 'CALL InsertPatient_SP(?, ?, ?, ?, ?, ?, ?)');
    $call->bind_param(
    'sssssss',
    $pid,
    $pname,
    $pAge,
    $pAddress,
    $pArrivalDate,
    $pComingFrom,
    $pGoingTo
    );


    mysqli_stmt_execute($call);
}


if(isset($_POST['mobile-sub'])){
  $pid = $_POST['pid'];
  $pMNo =  $_POST['pMNo'];
    $call = mysqli_prepare($con, 'CALL InsertMobile_SP(?, ?)');
    $call->bind_param(
    'ss',
    $pid,
    $pMNo
    );
    mysqli_stmt_execute($call);
}
?>


<home>
  <!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">

  <title>Insert Parts</title>
  <meta name="description" content="Selection">
  <meta name="author" content="SitePoint">
  <link rel="stylesheet" href="css/styles.css?v=1.0">
</head>

<body>
    <h1> Insertion Methods </h1>
    <h2>Patients List:-</h2>
    <div class = "login-form justify-content-center">
    <form method="post">
  <label for="pid">PatientID:</label>
  <input type="number" id="pid" name="pid" required><br>
  <label for="pname">Name:</label>
  <input type="text" id="pname" name="pname"><br>
  <label for="pAge">Age:</label>
  <input type="number" id="pAge" name="pAge" required>      <br>
  <label for="pAddress">Address:</label>
  <input type="text" id="pAddress" name="pAddress">  <br>      
  <label for="pArrivalDate">ArrivalDate:</label>
  <input type="date" id="pArrivalDate" name="pArrivalDate" required><br>        
  <label for="pComingFrom">ComingFrom:</label>
  <input type="text" id="pComingFrom" name="pComingFrom">  <br>
  <label for="pGoingTo">GoingTo:</label>
  <input type="text" id="pGoingTo" name="pGoingTo">  <br>
  <br><br>
  <input type="submit" value="Submit" name="patient-sub">
</form>
 </div>
  

    <h2>Contact List:-</h2>
    <div class = "contact-form justify-content-center">
    <form method="post">
  <label for="uname">PaientID:</label>
  <input type="text" id="pid" name="pid"><br>
  <label for="pass">MobileNo:</label>
  <input type="text" id="pMNo" name="pMNo"><br>
  <br><br>
  <input type="submit" value="Submit" name="mobile-sub">
</form>
 </div>
  
  
  
  <script src="js/scripts.js"></script>
  <!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">

<!-- jQuery library -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>

<!-- Latest compiled JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
</body>
</html>
  
</home>