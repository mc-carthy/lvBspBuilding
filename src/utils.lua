local utils = {}

function utils.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function utils.tableRemove(tbl, element)
    for i, value in ipairs(tbl) do
        if value == element then
            table.remove(tbl, i)
        end
    end
end

return utils