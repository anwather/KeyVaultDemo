Copy-Item .\ArcCredentialHelper $env:PSModulePath.Split(';')[0] -Verbose -Force -Recurse

# Create a package that will audit and apply the configuration (Set)
New-GuestConfigurationPackage `
    -Name 'ArcCredentialTest' `
    -Configuration .\ArcCredentialTest\localhost.mof `
    -Type AuditAndSet `
    -Force

$content = Publish-GuestConfigurationPackage -Path .\ArcCredentialTest\ArcCredentialTest.zip -ResourceGroupName aa-automation -StorageAccountName awtempstorage -StorageContainerName winfeat -Force | % ContentUri

New-GuestConfigurationPolicy `
    -PolicyId '70111257-caea-4a4e-8c5c-9a14c9d2954b' `
    -ContentUri $content `
    -DisplayName 'Create credential registry key' `
    -Description 'Create credential registry key' `
    -Path './policies' `
    -Platform Windows `
    -Version 0.0.8 `
    -Mode ApplyAndAutoCorrect `
    -Verbose
  
Publish-GuestConfigurationPolicy -Path .\policies