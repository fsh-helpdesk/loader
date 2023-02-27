
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server=FILESHARE\LDR_HISTORY;Database=LDR_HISTORY_SETUP;UID=testuser;PASSWORD=32aabb"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = "dbo.SubmitReportingData"
$SqlCmd.Connection = $SqlConnection
$SqlCmd.CommandType = [System.Data.CommandType]'StoredProcedure';
$outParameter = new-object System.Data.SqlClient.SqlParameter;
$outParameter.ParameterName = "@SendCommand";
$outParameter.Direction = [System.Data.ParameterDirection]'Output';
$outParameter.DbType = [System.Data.DbType]'StringFixedLength';
$outParameter.Size = 50;


$out = $SqlCmd.Parameters.Add($outParameter)
$open = $SqlConnection.Open();
$exec = $SqlCmd.ExecuteNonQuery();
$SendCmd = $SqlCmd.Parameters["@SendCommand"].Value;
$close = $SqlConnection.Close();

