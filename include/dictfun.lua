-- module to load from luatex
module("dictfun",package.seeall)

-- Storage for database of what words begin and end each page
headtab = {}

-- Called from the page header with the page number, left word (first on page) 
-- and right word (last on page). Update the page database, and format a string
-- containing the first and last words over each two page spread to return.
function headmarks(pg,left,right)
    if not pg then return end
    pg = tonumber(pg)
    -- remember the index terms for this page, but strip off
    -- anything after a semicolon in each term
    headtab[pg]={left:gsub(";.*$",""),right:gsub(";.*$","")}
    local lpage, rpage
    if pg % 2 == 0 then
        -- left page
        lpage = headtab[pg]
        rpage = headtab[pg+1] or {"",""}
    else
        -- right page
        lpage = headtab[pg-1] or {"",""}
        rpage = headtab[pg]
    end
    tex.print(lpage[1].."---"..rpage[2])
end

-- Called from the page footer with the page number. I've demonstrated that
-- it can tell left from right. Other applications are left as an exercise.
function footmarks(pg)
    if not pg then return end
    pg = tonumber(pg)
    local lpage, rpage
    if pg % 2 == 0 then
        -- left page
        tex.print("left")
    else
        tex.print("right")
    end
end

-- Called when the module loads to attempt to open and read the table from
-- a file related to the project name.    
function readmarks()
    local f = assert(loadfile(tex.jobname..".headmarks"))
    if not f then headtab = {} return end
    headtab = f()
end

-- Called to write the page database back out to a file.    
function writemarks()
    local f = assert(io.open(tex.jobname..".headmarks","w"))
    if not f then return end
    f:write"return {\n"
    for _,t in ipairs(headtab) do
    f:write(string.format("  {%q,%q},\n", t[1], t[2]))
    end
    f:write"}\n"
end

-- Finally, load the page database.
readmarks()
