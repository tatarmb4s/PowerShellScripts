#This script starts a ping infinite loop, and wrties the response time to screen

$url = "https://api.torpedo.ml/api/GameCreate/endgame?sessionID=1"
(Measure-Command -Expression { $site = Invoke-WebRequest -Uri $url -UseBasicParsing }).Milliseconds

while ($true)
{
    (Measure-Command -Expression { $site = Invoke-WebRequest -Uri $url -UseBasicParsing }).Milliseconds
}