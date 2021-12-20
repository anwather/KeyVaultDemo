Configuration ArcCredentialTest {
    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName ArcCredentialHelper

    Node localhost {
        ArcCredentialHelper arc01 {
            KeyVaultName = "arc01"
            SecretName   = "mySecret"
            OutputId     = "mySecret"
            Encrypted    = $false
        }

        Script s1 {
            GetScript  = { return @{Present = $true } }
            TestScript = {
                $c = Get-Content "C:\ProgramData\AzureConnectedMachineAgent\Tokens\mySecret"
                if ($c) {
                    if (Test-Path HKLM:\Software\$c) {
                        return $true
                    }
                    else {
                        return $false
                    }
                }
                return $false
            }
            SetScript  = {
                $c = Get-Content "C:\ProgramData\AzureConnectedMachineAgent\Tokens\mySecret"
                if ($c) {
                    New-Item HKLM:\Software\$c -Force
                }
            }
            DependsOn  = '[ArcCredentialHelper]arc01'
        }
    }


}

ArcCredentialTest