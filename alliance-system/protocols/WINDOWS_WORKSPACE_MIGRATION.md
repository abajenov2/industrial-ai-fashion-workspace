# Безопасный перенос рабочего места в Windows

Этот протокол нужен, когда действующее рабочее место переносится на другой
диск или из OneDrive в обычную локальную папку. Перенос не является новой
установкой: личный паспорт, роли, задачи, встречи и выбранные документы должны
сохраниться без изменений.

## Рекомендуемый путь

Если облачная синхронизация не требуется, используйте короткий ASCII-путь вне
OneDrive, например:

```text
C:\Alliance\Workspace
D:\Alliance\Workspace
```

OneDrive не запрещен, но синхронизация, ACL и облачные атрибуты могут мешать
созданию staging-каталога. Для такого пути обязательны `DryRun` и
`CheckWriteAccess` до реального обновления.

## Порядок переноса

1. Остановите работу с исходной папкой на время копирования.
2. Создайте манифест исходной папки: относительный путь, тип объекта, размер и
   SHA-256 каждого файла.
3. Скопируйте рабочее место в новую папку. Не перемещайте и не удаляйте
   источник на этом шаге.
4. Создайте такой же манифест новой папки и сравните оба списка.
5. Убедитесь, что совпали количество файлов и каталогов, относительные пути,
   размеры и SHA-256.
6. Запустите `LibraryOnly -DryRun` в новой папке.
7. Запустите `LibraryOnly -DryRun -CheckWriteAccess`.
8. Только после успешных проверок выполните реальное `LibraryOnly`-обновление.
9. Проверьте `VERSION.json` и контрольные суммы личных файлов.
10. Оставьте старую папку резервом до подтверждения владельца. Если удаление
    блокируется ACL или OneDrive, остановитесь: не снимайте запреты силой и не
    удаляйте дерево обходным способом.

## Манифест для сверки

Пример функции для Windows PowerShell 5.1:

```powershell
function New-WorkspaceManifest {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$Output
  )

  $RootPath = (Resolve-Path -LiteralPath $Root).Path.TrimEnd('\')
  Get-ChildItem -LiteralPath $RootPath -Recurse -Force |
    ForEach-Object {
      $RelativePath = $_.FullName.Substring($RootPath.Length).TrimStart('\')
      if ($_.PSIsContainer) {
        $Type = "Directory"
        $Length = $null
        $Sha256 = $null
      }
      else {
        $Type = "File"
        $Length = $_.Length
        $Sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
      }
      [pscustomobject]@{
        RelativePath = $RelativePath
        Type = $Type
        Length = $Length
        SHA256 = $Sha256
      }
    } |
    Sort-Object RelativePath |
    Export-Csv -LiteralPath $Output -NoTypeInformation -Encoding UTF8
}

New-WorkspaceManifest -Root "C:\old-workspace" -Output "$env:TEMP\before.csv"
New-WorkspaceManifest -Root "D:\Alliance\Workspace" -Output "$env:TEMP\after.csv"

$Before = Import-Csv -LiteralPath "$env:TEMP\before.csv"
$After = Import-Csv -LiteralPath "$env:TEMP\after.csv"
Compare-Object $Before $After -Property RelativePath, Type, Length, SHA256
```

Пустой результат `Compare-Object` означает, что расхождений в манифестах нет.
Сам манифест может раскрывать имена личных файлов, поэтому хранится только в
приватном паспорте рабочего места и не публикуется в общий GitHub.

## Проверка библиотеки после переноса

Из клонированного актуального release:

```powershell
powershell -ExecutionPolicy Bypass -File .\update-library.ps1 -Target "D:\Alliance\Workspace" -LibraryOnly -DryRun
powershell -ExecutionPolicy Bypass -File .\update-library.ps1 -Target "D:\Alliance\Workspace" -LibraryOnly -DryRun -CheckWriteAccess
powershell -ExecutionPolicy Bypass -File .\update-library.ps1 -Target "D:\Alliance\Workspace" -LibraryOnly
```

Перенос считается завершенным только после появления актуального
`03_Библиотека_роли\01_Открытый_стандарт\Свод_знаний_репозиторий\VERSION.json`
и повторной проверки защищенных личных файлов.
