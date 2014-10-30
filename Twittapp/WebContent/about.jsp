<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8">
    <title>TwittMap Application</title>
    <link rel="stylesheet" href="styles/styles.css" type="text/css" media="screen">
    <style>
      body {
     	height: 100%;
     	width: 100%;
      	padding-left: 50px;
      	padding-right: 50px;
      }
    </style>  
    <!-- Latest compiled and minified CSS -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
	
	<!-- Optional theme -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css">
	
	<!-- Latest compiled and minified JavaScript -->
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
	
</head>
<body>
<nav class="navbar navbar-default" role="navigation">
  <div class="container-fluid">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="/index">TwittMap</a>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
      <ul class="nav navbar-nav">
        <li><a href="/index">Main</a></li>
        <li><a href="/real-time">Real-time</a></li>
        <li class="active"><a href="/about">About</a></li>
      </ul>
    </div>
   </div>
 </nav>
 <h1 class="text-center">TwittMap Application Info</h1>
  <h3>Team Member</h3>
  <p>Fan Su      (fs2488)</p>
  <p>Jingyi  Guo   (jg3421)</p>
  <h3>website for demo</h3>
  <a href="http://twittapp-env.elasticbeanstalk.com/index.jsp">http://twittapp-env.elasticbeanstalk.com/index.jsp</a>
  <h3>Internal Design</h3>
  <h4>Features: </h4>
  <p>
	<div>1. Display twitts' location on map with predefined keywords search ('halloween', 'USAirway', 'NewYork', 'Columbia')</div>
	<div>2. Display twitts' location based on time range filter</div>
	<div>3. Color gradient and density map display for twitts on map based on location</div>
	<div>4. Real time twitts location display </div>
  </p>
  <h4>Tools used:</h4>
    <div>1. Web server: Tomcat 7.0 on AWS Elastic Beanstalk</div>
    <div>2. Database: Apache Cassandra on AWS EC2</div>
    <div>3. API: Twitter Live and Streaming API, Google Map API,Elastic Beanstalk,Elastic LoadBalancing</div>
  <h4>Steps to use without installing source code:</h4>
	<div>1. Go to page http://twittapp-env.elasticbeanstalk.com/</div>
	<div>2. 'Main' will show main feature with locations of twitts, keywords filtering in dropdown, time range filtering</div>
	<div>3. 'Real time' will show real-time twitts' location with predefined search keywords 'halloween'</div>
  <h4>Steps in using source code</h4>
	<div>1. Git clone source code</div>
	<div>2. Link to AWS account with access key and secret key and connect with current development environment</div>
	<div>3. Create application and environment on AWS Elastic Beanstalk </div>
	<div>4. Add jars to build path</div>
	<div>5. Create Cassandra Database on AWS EC2</div>
	<div>6. Create account in Twitter API and get access keys</div>
	<div>7. Deploy project in AWS Elastic Beanstalk</div>
 </body>
 </html>
