Clear-Host

Class Player {
    [String]$Name = "Default"
    [int]$Score = 0
    [bool]$IsFirstRoll = $true

    Player([String]$Name) {
        $this.Name = $Name
    }
}

Class Step {
    [int]$Step
    [string]$Name
    [int]$Roll

    Step([int]$Step, [string]$Name, [int]$Roll){
        $this.Step = $Step
        $this.Name = $Name
        $this.Roll = $Roll
    }
}

Class Game {
    [System.Collections.ArrayList]$Players = @()
    [int]$CurrentPlayer
    [System.Collections.ArrayList]$Steps = @()

    Game(){
        # Create Steps board.
        $this.Steps.Add([Step]::New(0,"",0))
        $this.Steps.Add([Step]::New(1,"",0))
        $this.Steps.Add([Step]::New(2,"",0))
        $this.Steps.Add([Step]::New(3,"",0))
        $this.Steps.Add([Step]::New(4,"",0))
        $this.Steps.Add([Step]::New(5,"",0))

        # Add Players
        $this.AddPlayer()
        
        # Write who the First Player is.
        $this.CurrentPlayer = Get-Random -Maximum $($this.Players.Count)
        Write-Host "Starting with Player: $($this.Players[$this.CurrentPlayer].Name)"
        $this.Next()
    }

    AddPlayer(){
        [string]$input
        # Loop adding players until 'n' is entered.
        do {
            # Forst player to enter name on start up.
            if ($this.Players.Count -eq 0){
                $input = 'y'
            }else{
                $input = Read-Host -Prompt "Do you want to add a player? Y/N"
            }
                # Check if user wants to add players.
                if ($input.ToLower() -eq 'y') {
                    [string]$player = Read-Host -Prompt "Enter Players Name:"
                    $this.Players.Add([Player]::new($player))
                    Write-Host "Added player $($player) - Player Count: $($this.Players.Count)"
                }
        } while ($input.ToLower() -ne 'n')
    }

    [int]RollDice(){
        $player = $($this.Players[$this.CurrentPlayer])

        $d1 = Get-Random 0,1,2,3,4,7
        $d2 = Get-Random 0,1,2,3,5,6
        
        $this.PrintSteps()
        Write-Host "$($player.Name): Dice1: $($d1 -replace (0,'X')), Dice2: $($d2 -replace (0,'X'))"
        if ($player.IsFirstRoll -eq $false -and ($d1 -eq 0 -or $d2 -eq 0)) {
           Clear-Host
            $this.PrintSteps()
            Write-Host "
             .----------------. 
            | .--------------. |
            | |  ____  ____  | |
            | | |_  _||_  _| | |
            | |   \ \  / /   | |
            | |    >    <    | |
            | |  _/ /  \ \_  | |
            | | |____||____| | |
            | |              | |
            | '--------------' |
             '----------------' 
            " -ForegroundColor Red
            Write-Host ""
            Write-Host "$($player.Name): You Rolled an 'X'!" -ForegroundColor Red

            # Reduce Score
            $($this.Players[$this.CurrentPlayer]).Score = $($this.Players[$this.CurrentPlayer]).Score - 1
            if ($($this.Players[$this.CurrentPlayer]).Score -lt 0){
                $($this.Players[$this.CurrentPlayer]).Score = 0
            }
            return -1
            break
        }

        $player.IsFirstRoll = $false

        $dice = @($d1, $d2)
        [int]$big = ($dice | Measure-Object -Maximum).Maximum
        [int]$small = ($dice | Measure-Object -Minimum).Minimum
        $num = "$big$small" -as [int]
        Write-Host "Total: " -NoNewline
        Write-Host "$($num)" -ForegroundColor Green
        return $num
    }

    AddToStep([int]$roll){

        # Find all avaliable steps
        [System.Collections.ArrayList]$numbers = @()
        foreach ($step in $this.Steps){
            if ($step.Roll -eq 0){
                $numbers.Add($step.Step)
            }
        }

        # Player chooses from avaliable steps.
        [string]$pos = 0
        do {
            $this.PrintSteps()
            Write-Host "Please select an avaliable Step"
            [string]$pos = Read-Host
        } while ($pos -notin $numbers)

        # Convert input to an [int]
        $pos = $pos -as [int]
        $this.steps[$pos].Step = $pos
        $this.steps[$pos].Name = $($this.Players[$this.CurrentPlayer].Name)
        $this.steps[$pos].Roll = $roll

        for ([int]$stepi = $pos+1; $stepi -lt $this.steps.Count; $stepi++) {
            if ($roll -ge $this.steps[$stepi].Roll){
                $this.steps[$stepi].Name = ""
                $this.steps[$stepi].Roll = 0
            }
        }
    }

    AdvScore(){
        # Check if current player is on the steps board.
        foreach ($player in $this.Players){
            if ($player.Name -eq $this.Players[$this.CurrentPlayer].Name){
                foreach ($step in $this.Steps){
                    if ($player.Name -eq $step.Name){
                        # Add Step number to Players Score.
                        $player.Score += $step.Step
                        
                        # Remove Player from board
                        $step.Name = ""
                        $step.Roll = 0
                    }
                }
            }
            
            # Check if Player has won.
            if ($player.Score -ge 20){
                Write-Host "
__          _______ _   _ _   _ ______ _____  
 \ \        / /_   _| \ | | \ | |  ____|  __ \ 
  \ \  /\  / /  | | |  \| |  \| | |__  | |__) |
   \ \/  \/ /   | | | . ` | . ` |  __| |  _  / 
    \  /\  /   _| |_| |\  | |\  | |____| | \ \ 
     \/  \/   |_____|_| \_|_| \_|______|_|  \_\
                                               " -ForegroundColor Green
            Pause
            Exit
            }
        }
    }

    Next(){
        # If player is on the steps board add to score and remove pos.
        $this.AdvScore()

        # Get dice roll.
        $roll = $this.RollDice()

        # Check if Roll was an 'X'/-1
        [String]$input
        if ($roll -ne -1){
            do {
                Write-Host "$($this.Players[$this.CurrentPlayer].Name), Would you like to Roll Again? Y/N" -ForegroundColor Cyan
                $input = Read-Host
            } while ($input.ToLower() -ne 'n' -and $input.ToLower() -ne 'y')

            if ($input.ToLower() -eq 'y'){
                $this.PrintSteps()
                $this.Next()
            }else{
                $this.AddToStep($roll)
                $this.PrintSteps()
            }
        }

        # End Players Trun
        if ($this.CurrentPlayer -ge ($this.Players.Count -1)){
            $this.CurrentPlayer = 0
        }else{
            $this.CurrentPlayer++
        }
        $($this.Players[$this.CurrentPlayer].IsFirstRoll = $true)
        $this.Next()
    }

    PrintSteps(){
        Clear-Host
        Write-Host "--SCORE--" -ForegroundColor Green
        Write-Host "| " -ForegroundColor Yellow -NoNewline
        foreach ($player in $this.Players){
            Write-Host "$($player.Name) - $($Player.Score) | " -ForegroundColor Yellow -NoNewline
        }
        Write-Host ""

        Write-Host "--STEPS--" -ForegroundColor Green
        for ($i = $this.steps.Count - 1; $i -ge 0 ; $i--) {
            $step = $this.steps[$i]
            Write-Host "$($step.Step): $($step.Name) $($step.Roll)" -ForegroundColor Green
        }
    }
}

$Game = [Game]::new()
