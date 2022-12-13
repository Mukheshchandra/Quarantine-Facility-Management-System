<?php


include 'connection.php';    


?>


<home>
  <!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">
    <style>
    ::-moz-selection { /* Code for Firefox */
  color: white;
  background: red;
}

::selection {
  color: white;
  background: red;
}
body{
    font-family: freight-sans-pro, sans-serif;
    font-style: normal;
    font-weight: 300;
}

    </style>
  <title>The HTML5 Herald</title>
  <meta name="description" content="Selection">
  <meta name="author" content="SitePoint">
  <link rel="stylesheet" href="css/styles.css?v=1.0">
</head>

<body>



    <h1> View Records </h1>
    <h2>Patients List:-</h2>
    <?php
        $sql1 = "SELECT p.*, a.Floor FROM patient p CROSS JOIN agefloor a WHERE p.Age = a.Age";
        $result1 = mysqli_query($con,$sql1);
        if ($result1->num_rows > 0) {
            echo "<table class='table'>
            <tr class='table-info'>
            
            <th>PatientID</th>
            <th>Name</th>
            <th>Age</th>
            <th>Address</th>
            <th>ArrivalDate</th>
            <th>ComingFrom</th>
            <th>GoingTo</th>
            <th>HostelNo</th>
            <th>FloorNo</th>
            <th>RoomNo</th>
            <th>DischargedDate</th> 
            </tr>";
        // output data of each row
        while($row1 = $result1->fetch_assoc()) {
            echo "<tr>
            <td>".$row1['PatientID']."</td>
            <td>".$row1['Name']."</td>
            <td>".$row1['Age']."</td>
            <td>".$row1['Address']."</td>
            <td>".$row1['ArrivalDate']."</td>
            <td>".$row1['ComingFrom']."</td>
            <td>".$row1['GoingTo']."</td>
            <td>".$row1['HostelNo']."</td>
            <td>".$row1['Floor']."</td>
            <td>".$row1['RoomNo']."</td>
            <td>".$row1['DischargedDate']."</td>
            </tr>";
        }
    echo "</table>";
    } else {
        echo "0 results";
    }

    ?>
  

<h2>Contact List:-</h2>
    <?php
        $sql2 = "SELECT PatientID, MobileNo FROM mobile";
        $result2 = mysqli_query($con,$sql2);
        if ($result2->num_rows > 0) {
            echo "<table class='table'>
            <tr class='table-info'>
            <th>PatientID</th>
            <th>MobileNo</th>
            </tr>";
        // output data of each row
        while($row2 = $result2->fetch_assoc()) {
            echo "<tr>
            <td>".$row2['PatientID']."</td>
            <td>".$row2['MobileNo']."</td>

            </tr>";
        }
    echo "</table>";
    } else {
        echo "0 results";
    }
    ?>
  
  
  
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