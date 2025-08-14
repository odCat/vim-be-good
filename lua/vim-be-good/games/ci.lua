local GameUtils = require("vim-be-good.game-utils")
local log = require("vim-be-good.log")
local gameLineCount = 20

local instructions = {
    "Replace the content of the outer container, or the executable content of the if statement, with \"bar\"",
    "",
    "e.g.:",
    "if (foo) {       if (foo) {",
    "  qux        ->    bar",
    "}                }",
    "",
    "[                    [",
    "   item1,            bar",
    "   item1,       ->   ]",
    "   item1,",
    "   item1,",
    "]",
    "----------------------------------------------------------------------",
    "",
}

local CiRound = {}
function CiRound:new(difficulty, window)
    log.info("New", difficulty, window)
    local round = {
        window = window,
        difficulty = difficulty,
    }

    self.__index = self
    return setmetatable(round, self)
end

function CiRound:getInstructions()
    return instructions
end

function CiRound:getConfig()
    log.info("getConfig", self.difficulty, GameUtils.difficultyToTime[self.difficulty])

    local function selectSurroundChar()
        local rand = math.random(4)
        if rand == 1 then
            self.config.braces = true
        elseif rand == 2 then
            self.config.square = true
        elseif rand == 3 then
            self.config.parenthesis = true
        elseif rand == 4 then
            self.config.quotation = true
        end
    end

    self.config = {
        roundTime = GameUtils.difficultyToTime[self.difficulty],
        randomWord = GameUtils.getRandomWord(),
    }

    selectSurroundChar()

    return self.config
end

function CiRound:checkForWin()
    local lines = self.window.buffer:getGameLines()
    local trimmed = GameUtils.trimLines(lines)
    local concatenated = table.concat(trimmed)
    local lowercased = concatenated:lower()

    log.info("CiRound:checkForWin", vim.inspect(lowercased))

    local winner = false
    if self.config.braces then
        winner = lowercased == "if (" .. self.config.randomWord .. ") {bar}"
    elseif self.config.square then
        winner = lowercased == "[bar]"
    elseif self.config.parenthesis then
        winner = lowercased == "function foo(bar)" .. self.config.randomWord .. "end"
    elseif self.config.quotation then
        local expected = "doprint(\"bar\")" .. self.config.randomWord .. "end"
        winner = lowercased == expected
    end

    if winner then
        vim.cmd("stopinsert")
    end

    return winner
end

function CiRound:render()
    local lines = GameUtils.createEmpty(gameLineCount)
    local linesAfterInstructions = gameLineCount - #instructions
    local insertionIndex = GameUtils.getRandomInsertionLocation(gameLineCount, 6, #instructions)
    local goHigh = insertionIndex < gameLineCount / 2 and math.random() > 0.5

    local cursorIdx
    if goHigh then
        cursorIdx = math.random(math.floor(linesAfterInstructions / 2))
    else
        cursorIdx = math.random(math.floor(linesAfterInstructions / 2), linesAfterInstructions)
    end

    if self.config.braces then
        lines[insertionIndex] = "if (" .. self.config.randomWord .. ") {"
        lines[insertionIndex + 1] = "    if (" .. GameUtils.getRandomWord() .. ") { "
        lines[insertionIndex + 2] = "        " .. GameUtils.getRandomWord()
        lines[insertionIndex + 3] = "    }";
        lines[insertionIndex + 4] = "}";
    elseif self.config.square then
        lines[insertionIndex] = "[";
        lines[insertionIndex + 1] = "    " .. GameUtils.getRandomWord() .. ","
        lines[insertionIndex + 2] = "    " .. GameUtils.getRandomWord() .. ","
        lines[insertionIndex + 3] = "    " .. GameUtils.getRandomWord() .. ","
        lines[insertionIndex + 4] = "    " .. GameUtils.getRandomWord() .. ","
        lines[insertionIndex + 5] = "]";
    elseif self.config.parenthesis then
        lines[insertionIndex] = "function foo(" .. GameUtils.getRandomWord() .. ")"
        lines[insertionIndex + 1] = "    " .. self.config.randomWord
        lines[insertionIndex + 2] = "end"
    elseif self.config.quotation then
        lines[insertionIndex] = "do"
        lines[insertionIndex + 1] = "    print(\"" .. GameUtils.getRandomWord() .. "\")"
        lines[insertionIndex + 2] = "    " .. self.config.randomWord
        lines[insertionIndex + 3] = "end"
    end

    return lines, cursorIdx
end

function CiRound:name()
    return "ci{"
end

return CiRound
