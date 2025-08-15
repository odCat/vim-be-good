local GameUtils = require("vim-be-good.game-utils")
local log = require("vim-be-good.log")
local gameLineCount = 20

local instructions = {
    "Surround the SURROUND word with double quotes.",
    "If the word is surrounded already, change the double quotes to apostrophes",
    "",
    "e.g.",
    "tar bar SURROUND car   ->   tar bar \"SURROUND\" car",
    "",
    "tar bar \"SURROUND\" car   ->   tar bar 'SURROUND' car",
    "----------------------------------------------------------------------",
    "",
}


SurroundRound = {}
function SurroundRound:new(difficulty, window)
    log.info("New", difficulty, window)
    local round = {
        window = window,
        difficulty = difficulty,
    }

    self.__index = self
    return setmetatable(round, self)
end


function SurroundRound:name()
    return "surround"
end


function SurroundRound:getInstruction()
    return instructions
end


function SurroundRound:getConfig()
    log.info("getConfig", self.difficulty, GameUtils.difficultyToTime[self.difficulty])

    -- local function selectMode()
    -- end

    local words = {
        GameUtils.getRandomWord(),
        GameUtils.getRandomWord(),
        GameUtils.getRandomWord(),
        GameUtils.getRandomWord(),
    }

    local surroundPosition = math.random(5)
    table.insert(words, surroundPosition "SURROUND")
    local expected = table.concat(self.config.words, " ")


    self.config = {
        roundTime = GameUtils.difficultyToTime[self.difficulty],
        words = words,
        expected,
    }

    -- selectMode()

    return self.config
end


function SurroundRound:checkForWin()
    local lines = self.window.buffer:getGameLines()
    local trimmed = GameUtils.trimLines(lines)
    local concatenated = table.concat(GameUtils.filterEmptyLines(trimmed), "")
    local lowercased = concatenated:lower()

    log.info("CiRound:checkForWin", vim.inspect(lowercased))

    local winner = lowercased == self.config.expected

    if winner then
        vim.cmd("stopinsert")
    end

    return winner
end


function SurroundRound:render()
    local lines = GameUtils.createEmpty(gameLineCount)
    local cursorIdx = 5

    lines[5] = self.config.expected

    return lines, cursorIdx
end


return SurroundRound
