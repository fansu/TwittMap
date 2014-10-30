COMSE6998 CLOUD COMPUTING & BIG DATA - TwittMap(Assignment1)


Team Member
-----------
Fan Su		 	(fs2488)
Jingyi	Guo		(jg3421)

website for demo
-----------------
http://twittapp-env.elasticbeanstalk.com/index.jsp

Files
-----
README						- this file
AutoDeploy			 		- folder contins AwsAuto.java file using AmazonS3Client to creat a S3 bucket, upload .war file to this 
							bucket,and linked this file to a application's enviroment. Elastic Beanstalk API is used to 
							create an application and environment, Elastic LoadBalancing API is used to configure load balancing.
							contains an example.war and a credentials file


Internal Design
---------------
Features:
1. Display twitts' location on map with predefined keywords search ('halloween', 'USAirway', 'NewYork', 'Columbia')
2. Display twitts' location based on time range filter
3. Color gradient and density map display for twitts on map based on location
4. Real time twitts location display 
5. Auto create AWS Elastic beanstalk application, environment, and deploy TwittMap application 

Tools used:
1. Web server: Tomcat 7.0 on AWS Elastic Beanstalk
2. Database: Apache Cassandra on AWS EC2
3. API: Twitter Live and Streaming API, Google Map API,Elastic Beanstalk,Elastic LoadBalancing

Steps to use without installing source code:
1. Go to page http://twittapp-env.elasticbeanstalk.com/
2. 'Main' will show main feature with locations of twitts, keywords filtering in dropdown, time range filtering
3. 'Real time' will show real-time twitts' location with predefined search keywords 'halloween'

Steps in using source code
1. Git clone source code
2. Link to AWS account with access key and secret key and connect with current development environment
3. Create application and environment on AWS Elastic Beanstalk 
4. Add jars to build path
5. Create Cassandra Database on AWS EC2
6. Create account in Twitter API and get access keys
7. Deploy project in AWS Elastic Beanstalk

How to run AutoDeploy.java(extra point)
---------------------------------------------
1.import AutoDeploy to Eclipse and run AwsAuto.java and make sure you have AWS SDK installed.
2.open AutoDeploy.java and fill in your AWS_KEY and AWS_SECRET_KEY,KEY_PAIR
3.Fill in your AWS_KEY and AWS_SECRET_KEY,KEY_PAIR in credentials

Comment to TA
---------------------------------------------
If there is anything wrong, please contact us!



