if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
} else {
    # Fallback custom prompt: [time] user@host path (git-branch)
    #                         $
    function prompt {
        $esc = [char]27
        $reset   = "$esc[0m"
        $lpurple = "$esc[95m"
        $blue    = "$esc[34m"
        $lblue   = "$esc[94m"
        $purple  = "$esc[35m"

        $shell    = 'PS'
        $time     = Get-Date -Format 'HH:mm:ss'
        $userHost = "$env:USERNAME@$env:COMPUTERNAME"
        $path     = (Get-Location).Path

        $branch = ''
        $b = git symbolic-ref --short HEAD 2>$null
        if (-not $b) { $b = git rev-parse --short HEAD 2>$null }
        if ($b) { $branch = " ($b)" }

        "$lpurple$shell [$time]$reset $blue$userHost$reset $lblue$path$reset$purple$branch$reset`n${blue}`$ $reset"
    }
}
