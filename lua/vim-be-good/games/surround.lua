local GameUtils = require("vim-be-good.game-utils")
local log = require("vim-be-good.log")
local gameLineCount = 9

local instructions = {
    "Surround the SURROUND word with double quotes.",
    "If the word is surrounded already, change the double quotes to apostrophes.",
    "Similar, change parenthesis with square braces and square to curly braces.",
    "",
    "e.g.",
    "",
    "tar bar SURROUND car   ->   tar bar \"SURROUND\" car",
    "",
    "tar bar \"SURROUND\" car   ->   tar bar 'SURROUND' car",
    "",
    "tar bar (SURROUND) car   ->   tar bar [SURROUND] car",
    "",
    "tar bar [SURROUND] car   ->   tar bar {SURROUND} car",
    "",
    "tar bar <cor> car   ->   tar bar cor car",
    "",
    "----------------------------------------------------------------------",
    "",
}


SurroundRound = {}
function SurroundRound:new(difficulty, window)
    log.info("NewSurround", difficulty, window)
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
        local rand = math.random(8)
        if rand == 1 or rand == 2 then
            self.config.quote = true
        elseif rand == 3 then
            self.config.delete = true
        elseif rand == 4 then
            self.config.quote2apostrophe = true
        elseif rand == 5 then
            self.config.apostrophe2quote = true
        elseif rand == 6 then
            self.config.parenthesis2square = true
        elseif rand == 7 then
            self.config.square2braces = true
        elseif rand == 8 then
            self.config.delete = true
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
    elseif self.config.apostrophe2quote then
        table.insert(words, surroundPosition, "'SURROUND'")
        expected = table.concat(words, " ")
        expected = string.gsub(expected, "'SURROUND'", "\"SURROUND\"")
    elseif self.config.parenthesis2square then
        table.insert(words, surroundPosition, "(SURROUND)")
        expected = table.concat(words, " ")
        expected = string.gsub(expected, "%(SURROUND%)", "[SURROUND]")
    elseif self.config.square2braces then
        table.insert(words, surroundPosition, "[SURROUND]")
        expected = table.concat(words, " ")
        expected = string.gsub(expected, "%[SURROUND%]", "{SURROUND}")
    elseif self.config.delete then
        local randWord = "<" .. GameUtils.getRandomWord() .. ">"
        table.insert(words, surroundPosition, randWord)
        expected = table.concat(words, " ")
        expected = string.gsub(expected, "<", "")
        expected = string.gsub(expected, ">", "")
    end

    self.config.roundTime = GameUtils.difficultyToTime[self.difficulty]
    self.config.words = words
    self.config.expected = expected

    return self.config
end


function SurroundRound:render()
    local lines = GameUtils.createEmpty(gameLineCount)
    lines[5] = table.concat(self.config.words, " ")

    -- gives a slightly higher change to spawn on the line to be changed
    local cursorLine = math.random(gameLineCount + math.ceil(gameLineCount*0.25))
    if cursorLine > gameLineCount then
        cursorLine = 5
    end

    local cursorCol = nil
    if cursorLine == 5 then
        cursorCol = math.random(0, #lines[5])
    end

    return lines, cursorLine, cursorCol
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
