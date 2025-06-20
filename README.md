# Ancora.CodeSignTool.MSBuild

[![NuGet Version](https://img.shields.io/nuget/v/Ancora.CodeSignTool.MSBuild.svg)](https://www.nuget.org/packages/Ancora.CodeSignTool.MSBuild/)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()

An MSBuild task that provides seamless integration with SSL.com's [eSigner CodeSignTool](https://www.ssl.com/guide/esigner-codesigntool-command-guide/) for automated code signing in .NET projects.

## Features

- ✅ **Cross-platform support** - Works on .NET Framework 4.7.2 and .NET 8.0+
- ✅ **Automatic Java detection** - Finds Java runtime automatically or accepts custom path
- ✅ **Secure credential handling** - Supports TOTP authentication for enhanced security
- ✅ **MSBuild integration** - Integrates seamlessly into your build process
operation
- ✅ **Configurable timeouts** - Customizable signing timeout periods

## Installation

Install the NuGet package in your project:

```bash
dotnet add package Ancora.CodeSignTool.MSBuild
```

Or via Package Manager Console:

```powershell
Install-Package Ancora.CodeSignTool.MSBuild
```

## Quick Start

Add the following to your project file (`.csproj`, `.vbproj`, etc.):

```xml
<Target Name="SignFiles" AfterTargets="Build">
  <CodeSignTool
    SignFiles="@(OutputFiles)"
    Username="$(SSL_USERNAME)"
    Password="$(SSL_PASSWORD)"
    TOTPSecret="$(SSL_TOTP_SECRET)" />
</Target>
```

## Configuration

| Parameter | Type | Description | Required | Default |
|-----------|------|-------------|----------|---------|
| `SignFiles` | ITaskItem[] | Array of files to be signed | ✅ | - |
| `Username` | string | SSL.com account username | ✅ | - |
| `Password` | string | SSL.com account password | ✅ | - |
| `CredentialId` | string | eSigner credential ID (required if multiple certificates) | ❌ | - |
| `TOTPSecret` | string | OAuth TOTP secret for automated signing | ❌ | - |
| `ProgramName` | string | Program name displayed in confirmation dialogs | ❌ | - |
| `JavaHomePath` | string | Custom Java installation path | ❌ | - |
| `TimeoutMilliseconds` | int | Signing operation timeout | ❌ | 10000 |
| `ErrorOnNoFiles` | bool | Whether to error when no files are specified | ❌ | false |

## Usage Examples

### Basic File Signing

```xml
<Target Name="SignExecutables" AfterTargets="Publish">
  <ItemGroup>
    <FilesToSign Include="$(PublishDir)**/*.exe" />
    <FilesToSign Include="$(PublishDir)**/*.dll" />
  </ItemGroup>

  <CodeSignTool
    SignFiles="@(FilesToSign)"
    Username="your-username"
    Password="your-password"
    CredentialId="your-credential-id" />
</Target>
```

### Using Environment Variables

```xml
<Target Name="SignFiles" AfterTargets="Build" Condition="'$(SignCode)' == 'true'">
  <CodeSignTool
    SignFiles="$(OutputPath)$(AssemblyName).exe"
    Username="$(ESIGNER_USERNAME)"
    Password="$(ESIGNER_PASSWORD)"
    TOTPSecret="$(ESIGNER_TOTP_SECRET)"
    TimeoutMilliseconds="30000" />
</Target>
```

### Conditional Signing

```xml
<Target Name="SignFiles" AfterTargets="Build" Condition="'$(Configuration)' == 'Release'">
  <CodeSignTool
    SignFiles="@(MainAssembly)"
    Username="$(SSL_USERNAME)"
    Password="$(SSL_PASSWORD)"
    ProgramName="My Application"
    ErrorOnNoFiles="true" />
</Target>
```

## Security Best Practices

1. **Never hardcode credentials** in your project files
2. **Use environment variables** or Azure DevOps/GitHub Secrets for credentials
3. **Enable TOTP authentication** for enhanced security
4. **Limit credential scope** to only necessary certificates

## Prerequisites

- **Java Runtime Environment (JRE) 1.8+** - Required by SSL.com CodeSignTool
- **SSL.com eSigner account** - With valid code signing certificate
- **.NET Framework 4.7.2+** or **.NET 8.0+**

## Troubleshooting

### Common Issues

**Java not found:**

```
Error: Unable to locate Java executable
```

**Solution:** Install Java or set the `JavaHomePath` parameter.

**Authentication failed:**

```
Error: Invalid credentials or TOTP token
```

**Solution:** Verify your SSL.com credentials and TOTP secret.

**Timeout errors:**

```
Error: Signing operation timed out
```

**Solution:** Increase `TimeoutMilliseconds` value.

### Debug Mode

Enable detailed logging by setting MSBuild verbosity:

```bash
dotnet build -v detailed
```

## How It Works

1. **Downloads CodeSignTool** - Automatically downloads SSL.com's CodeSignTool zip archive from [Ancora's Github mirror](https://github.com/AncoraSoftware/CodeSignTool-Mirror/releases/).
2. **Java Detection** - Locates Java runtime on the system
3. **Secure Execution** - Runs CodeSignTool with provided credentials
4. **File Processing** - Signs each specified file individually
5. **Cleanup** - Removes temporary files after completion

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project (the MSBuild task wrapper) is licensed under the MIT License - see the LICENSE file for details.

This license only applies to the MSBuild task code in this repository. SSL.com's CodeSignTool is distributed under SSL.com's own licensing terms and is automatically downloaded during the build process.

No rights to modify, redistribute, or use the upstream software beyond those expressly granted by SSL.com are implied or provided here.

The maintainers of this mirror accept no responsibility or liability for any direct or consequential damages arising from the use of the upstream CodeSignTool.

If you require definitive licensing terms, you must obtain them directly from SSL.com.

## References

- [SSL.com eSigner CodeSignTool Guide](https://www.ssl.com/guide/esigner-codesigntool-command-guide/)
- [SSL.com eSigner Automation Guide](https://www.ssl.com/how-to/automate-esigner-ev-code-signing/)
- [MSBuild Custom Tasks Documentation](https://learn.microsoft.com/en-us/visualstudio/msbuild/tutorial-custom-task-code-generation)
- [Code Signing Best Practices](https://docs.microsoft.com/en-us/windows-hardware/drivers/dashboard/code-signing-best-practices)

---

**SSL.com** and **eSigner** are trademarks of SSL Corporation.
