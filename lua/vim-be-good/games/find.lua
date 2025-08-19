local GameUtils = require("vim-be-good.game-utils")
local log = require("vim-be-good.log")
local gameLineCount = 5

local instructions = {
    "Jump to the special character and delete it",
}


local Find = {}
function Find:new(difficulty, window)
    log.info("NewFind", difficulty, window)
    local round = {
        window = window,
        difficulty = difficulty,
    }

    self.__index = self
    return setmetatable(round, self)
end


function Find:name()
    return "surround"
end

function Find:getInstructions()
    return instructions
end


function Find:getConfig()
    log.info("getConfig", self.difficulty, GameUtils.difficultyToTime[self.difficulty])

    local function selectSpecialCharacter()
        local rand = math.random(6)
        if rand == 1 then
            return "("
        elseif rand == 2 then
            return ")"
        elseif rand == 3 then
            return "["
        elseif rand == 4 then
            return "]"
        elseif rand == 5 then
            return "{"
        elseif rand == 6 then
            return "}"
        end
    end

    self.config = {}

    local tempWords = {
        GameUtils.getRandomWord(),
        GameUtils.getRandomWord(),
        GameUtils.getRandomWord(),
        GameUtils.getRandomWord(),
        GameUtils.getRandomWord(),
    }

    local words = {}
    for i, word in ipairs(tempWords) do
        words[i] = string.match(word, word)
    end

    local wordToInsertInto = math.random(#tempWords)
    local positionToInsertInto = math.random(#GameUtils.getRandomWord())
    words[wordToInsertInto] = string.sub(tempWords[wordToInsertInto], 1, positionToInsertInto - 1)
                                .. selectSpecialCharacter() ..
                            string.sub(tempWords[wordToInsertInto], positionToInsertInto)

    local expected = table.concat(tempWords, " ")

    self.config = {
        roundTime = GameUtils.difficultyToTime[self.difficulty],
        words = words,
        expected = expected,
    }

    return self.config
end


function Find:checkForWin()
    local lines = self.window.buffer:getGameLines()
    local trimmed = GameUtils.trimLines(lines)
    local concatenated = table.concat(GameUtils.filterEmptyLines(trimmed), "")
    local lowercased = concatenated:lower()

    local winner = lowercased == self.config.expected

    if winner then
        vim.cmd("stopinsert")
    end

    return winner
end


function Find:render()
    local lines = GameUtils.createEmpty(gameLineCount)
    local cursorLine = 5

    lines[cursorLine] = table.concat(self.config.words, " ")

    local cursorCol = math.random(0, #lines[5] - 1) -- columns start at 0
    local specialCharLocation = string.find(lines[5], "[()[%]{}]") - 1
    while cursorCol >= specialCharLocation - 3 and
          cursorCol <= specialCharLocation + 3 do
        cursorCol = math.random(#lines[5])
    end

    return lines, cursorLine, cursorCol
end


return Find
