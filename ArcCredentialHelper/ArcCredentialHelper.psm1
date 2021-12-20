[DscResource()]
class ArcCredentialHelper {
    
    [DscProperty(Key)]
    [string] $OutputId
    
    [DscProperty()]
    [string] $SecretName

    [DscProperty()]
    [string] $KeyVaultName

    [DscProperty()]
    [boolean] $Encrypted = $true
    
    # Gets the resource's current state.
    [ArcCredentialHelper] Get() {
        return $this
    }
    
    # Sets the desired state of the resource.
    [void] Set() {
        
    }
    
    # Tests if the resource is in the desired state.
    [bool] Test() {
        try {
            $this.GetSecret($this.OutputId, $this.KeyVaultName, $this.SecretName)
            return $true
        }
        catch {
            return $false
        }
        
    }

    [void] GetSecret($OutputId, $KeyVaultName, $SecretName) {

        $apiVersion = "2020-06-01"
        $resource = "https://vault.azure.net"
        $endpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT, $resource, $apiVersion
        $secretFile = ""
        $token = ""
        $response = ""
        try {
            Invoke-WebRequest -Method GET -Uri $endpoint -Headers @{Metadata = 'True' } -UseBasicParsing
        }
        catch {
            $response = $_.Exception.Response
        }

        $secretFile = Get-ChildItem $env:ProgramData\AzureConnectedMachineAgent\Tokens | Sort-Object LastWriteTime | Select-Object -First 1
    
        $secret = Get-Content -Raw $secretFile
        $response = Invoke-WebRequest -Method GET -Uri $endpoint -Headers @{Metadata = 'True'; Authorization = "Basic $secret" } -UseBasicParsing
        if ($response) {
            $token = (ConvertFrom-Json -InputObject $response.Content).access_token
        }
    
        $secretObject = Invoke-RestMethod -Uri https://$KeyVaultName.vault.azure.net/secrets/$SecretName`?api-version=2016-10-01 -Method GET -Headers @{Authorization = "Bearer $token" }
        if ($this.Encrypted) {
            $secretObject.Value | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "$(Split-Path $secretFile -Parent)\$OutputId" -Force
        }
        else {
            $secretObject.Value | Out-File "$(Split-Path $secretFile -Parent)\$OutputId" -Force
        }
        
    }
}
