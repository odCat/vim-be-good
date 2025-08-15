local GameUtils = require("vim-be-good.game-utils")
local log = require("vim-be-good.log")
local gameLineCount = 5

local instructions = {
    "Surround the SURROUND word with double quotes.",
    "If the word is surrounded already, change the double quotes to apostrophes.",
    "Similar, change parenthesis with square brackets.",
    "",
    "e.g.",
    "tar bar SURROUND car   ->   tar bar \"SURROUND\" car",
    "",
    "tar bar \"SURROUND\" car   ->   tar bar 'SURROUND' car",
    "",
    "tar bar (SURROUND) car   ->   tar bar [SURROUND] car",
    "",
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


function SurroundRound:getInstructions()
    return instructions
end


function SurroundRound:getConfig()
    log.info("getConfig", self.difficulty, GameUtils.difficultyToTime[self.difficulty])

    self.config = {}

    local function selectMode()
        local rand = math.random(3)
        if rand == 1 then
            self.config.quote = true
        elseif rand == 2 then
            self.config.quote2apostrophe = true
        elseif rand == 3 then
            self.config.parenthesis2square = true
        end
    end

    selectMode()

    local words = {
        GameUtils.getRandomWord(),
        GameUtils.getRandomWord(),
        GameUtils.getRandomWord(),
        GameUtils.getRandomWord(),
    }

    local surroundPosition = math.random(5)
    local expected
    if self.config.quote then
        table.insert(words, surroundPosition, "SURROUND")
        expected = table.concat(words, " ")
        expected = string.gsub(expected, "SURROUND", "\"SURROUND\"")
    elseif self.config.quote2apostrophe then
        table.insert(words, surroundPosition, "\"SURROUND\"")
        expected = table.concat(words, " ")
        expected = string.gsub(expected, "\"SURROUND\"", "'SURROUND'")
    elseif self.config.parenthesis2square then
        table.insert(words, surroundPosition, "(SURROUND)")
        expected = table.concat(words, " ")
        expected = string.gsub(expected, "%(SURROUND%)", "[SURROUND]")
    end

    self.config.roundTime = GameUtils.difficultyToTime[self.difficulty]
    self.config.words = words
    self.config.expected = expected

    return self.config
end


function SurroundRound:render()
    local lines = GameUtils.createEmpty(gameLineCount)
    local cursorLine = 5

    lines[5] = table.concat(self.config.words, " ")

    return lines, cursorLine
end


function SurroundRound:checkForWin()
    local lines = self.window.buffer:getGameLines()
    local trimmed = GameUtils.trimLines(lines)
    local concatenated = table.concat(GameUtils.filterEmptyLines(trimmed), "")

    log.info("Surround:checkForWin", vim.inspect(concatenated))

    local winner = concatenated == self.config.expected

    if winner then
        vim.cmd("stopinsert")
    end

    return winner
end


return SurroundRound
