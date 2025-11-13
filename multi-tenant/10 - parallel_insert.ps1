$HostName="pg-elastic-cluster-demo-01.postgres.database.azure.com"
$UserName="demoAdmin"
$Port=7432
$DbName="postgres"

$env:PGPASSWORD = "YOUR_PASSWORD_HERE"

$SqlFile  = "09 - insert_impressions.sql"

1..5 | ForEach-Object -Parallel {
  $i = $_
  & psql `
    -h $using:HostName `
    -p $using:Port `
    -d $using:DbName `
    -U $using:UserName `
    -X -At `
    -f $using:SqlFile |
    ForEach-Object { "proc ${i}: $($_)" }
} -ThrottleLimit 5