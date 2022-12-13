<?php


include 'connection.php';    

if(isset($_POST['patient-sub'])){
    $pid = $_POST['pid'];
    $call = mysqli_prepare($con, 'CALL DeletePatient_SP(?)');
    $call->bind_param(
    's',
    $pid);
    mysqli_stmt_execute($call);
}


if(isset($_POST['mobile-sub'])){
  $pid = $_POST['pid'];
    $call = mysqli_prepare($con, 'CALL DeleteMobile_SP(?)');
    $call->bind_param(
    's',
    $pid
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
    <h1> Deletion Methods </h1>
    <h2>Patients Delete:-</h2>
    <div class = "login-form justify-content-center">
    <form method="post">
  <label for="pid">PatientID:</label>
  <input type="number" id="pid" name="pid" required><br>
  <br><br>
  <input type="submit" value="Submit" name="patient-sub">
</form>
 </div>
  

    <h2>Contact Delete:-</h2>
    <div class = "contact-form justify-content-center">
    <form method="post">
  <label for="uname">PaientID:</label>
  <input type="text" id="pid" name="pid"><br>
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