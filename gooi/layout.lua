layout = {}
layout.__index = layout

function layout.new(specs)
	local l ={}
	l.specs = specs
	if l.specs:sub(0, 4) == "grid" then
		local function split(inputstr, sep)
			if sep == nil then
				sep = "%s"
			end
			local t={} ; i=1
			for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
				t[i] = str
				i = i + 1
			end
			return t
		end
		-- Separate 'grid' and size 'MxN':
		local aux = split(l.specs, " ")
		l.kind = aux[1]
		l.size = aux[2]
		l.debug = false
		l.gridRows = tonumber(split(l.size, "x")[1])
		l.gridCols = tonumber(split(l.size, "x")[2])
		l.gridCells = {}
		l.indexRow, l.indexCol = 1, 0

		-- Debug:
		function l:drawCells()
			if self.debug then
				for i = 1, self.gridRows do
					for j = 1, self.gridCols do
						local cell = self.gridCells[i][j]
						if cell.on then
							love.graphics.setColor(255, 0, 255)
							love.graphics.rectangle("line", cell.x, cell.y, cell.w, cell.h)
						end
					end
				end
			end
		end

		function l:nextCell(c)
			--print("nextCell: "..self.indexGrid..", in: "..#self.gridCells)
			local function generateNext()
				self.indexCol = self.indexCol + 1
				if self.indexCol > self.gridCols then
					self.indexCol = 1
					self.indexRow = self.indexRow + 1
				end
				if self.gridCells[self.indexRow] and self.gridCells[self.indexRow][self.indexCol] then
					return self.gridCells[self.indexRow][self.indexCol].on
				end
			end
			while not generateNext() do end-- Ignore the not usable cells.
			return self.gridCells[self.indexRow][self.indexCol]
		end
		function l:getCell(row, col)
			for i = 1, self.gridRows do
				for j = 1, self.gridCols do
					if self.gridCells[i][j].row == row and self.gridCells[i][j].col == col then
						return self.gridCells[i][j]
					end
				end
			end
		end
		function l:offCellsInTheWay(spanType, row, col, size)
			if spanType == "rowspan" then
				for i = row + 1, row + size - 1 do
					self.gridCells[i][col].on = false
				end
			elseif spanType == "colspan" then
				for i = col + 1, col + size - 1 do
					self.gridCells[row][i].on = false
				end
			end
		end
		function l:init(panel)
			for theRow = 1, self.gridRows do
				self.gridCells[theRow] = {}
				for theCol = 1, self.gridCols do
					local thePadding = 3
					self.gridCells[theRow][theCol] =
					{
						on = true,
						x = panel.x + ((theCol - 1) * panel.w / self.gridCols + thePadding),
						y = panel.y + ((theRow - 1) * panel.h / self.gridRows + thePadding),
						w = panel.w / self.gridCols - thePadding * 2,
						h = panel.h / self.gridRows - thePadding * 2,
						row = theRow,
						col = theCol,
						rowspan = 1,
						colspan = 1,
						padding = thePadding
					}
				end
			end
		end
	end
	return setmetatable(l, layout)
end