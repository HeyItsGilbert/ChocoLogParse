# Dot source public/private functions
$enums = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Enum/*.ps1') -Recurse -ErrorAction Stop)
$classes = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Classes/*.ps1') -Recurse -ErrorAction Stop)
$public = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Public/*.ps1')  -Recurse -ErrorAction Stop)
foreach ($import in @($enums + $classes + $public )) {
  try {
    . $import.FullName
  } catch {
    throw "Unable to dot source [$($import.FullName)]"
  }
}

# Initialize module variable for color control (default to colored output)
$script:ChocoLogNoColor = $false

# Add our custom formatter that needed classes first
$format = Join-Path -Path $PSScriptRoot -ChildPath 'ChocoLog.format.ps1xml'
Update-FormatData -PrependPath $format

Export-ModuleMember -Function $public.Basename

# This module is combined. Any code in this file as added to the very end.

# Define the types to export with type accelerators.
$ExportableTypes = @(
  [ChocoLog]
)
# Get the internal TypeAccelerators class to use its static methods.
$TypeAcceleratorsClass = [psobject].Assembly.GetType(
  'System.Management.Automation.TypeAccelerators'
)
# Ensure none of the types would clobber an existing type accelerator.
# If a type accelerator with the same name exists, throw an exception.
$ExistingTypeAccelerators = $TypeAcceleratorsClass::Get
foreach ($Type in $ExportableTypes) {
  if ($Type.FullName -in $ExistingTypeAccelerators.Keys) {
    $Message = @(
      "Unable to register type accelerator '$($Type.FullName)'"
      'Accelerator already exists.'
    ) -join ' - '

    throw [System.Management.Automation.ErrorRecord]::new(
      [System.InvalidOperationException]::new($Message),
      'TypeAcceleratorAlreadyExists',
      [System.Management.Automation.ErrorCategory]::InvalidOperation,
      $Type.FullName
    )
  }
}
# Add type accelerators for every exportable type.
foreach ($Type in $ExportableTypes) {
  [void]$TypeAcceleratorsClass::Add($Type.FullName, $Type)
}
# Remove type accelerators when the module is removed.
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
  foreach ($Type in $ExportableTypes) {
    [void]$TypeAcceleratorsClass::Remove($Type.FullName)
  }
}.GetNewClosure()
