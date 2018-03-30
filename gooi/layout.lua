layout = {}
layout.__index = layout
layout.padding = 5
layout.paddingGrid = 3
function layout.new(specs)
	local l ={}
	l.specs = specs
	l.padding = layout.padding
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
							love.graphics.setColor(1, 0, 1)
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
					--print(c.text or "(nil)", self.indexRow, self.indexCol)
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
					for j = col, col + self.gridCells[row][col].colspan - 1 do
						self.gridCells[i][j].on = false
					end
				end
			elseif spanType == "colspan" then
				for i = col + 1, col + size - 1 do
					for j = row, row + self.gridCells[row][col].rowspan - 1 do
						self.gridCells[j][i].on = false
					end
				end
			end
		end
		function l:init(panel)
      local pad = self.paddingGrid * 2
      local fw, fh = panel.w - pad, panel.h - pad
			for theRow = 1, self.gridRows do
				self.gridCells[theRow] = {}
				for theCol = 1, self.gridCols do
					self.gridCells[theRow][theCol] =
					{
						on = true,
						x = math.floor(panel.x + ((theCol - 1) * fw / self.gridCols)) + pad,
						y = math.floor(panel.y + ((theRow - 1) * fh / self.gridRows)) + pad,
						w = (fw / self.gridCols) - pad,
						h = (fh / self.gridRows) - pad,
						row = theRow,
						col = theCol,
						rowspan = 1,
						colspan = 1,
            padding = self.paddingGrid
					}
				end
			end
		end
	elseif l.specs:sub(0, 4) == "game" then
		l.kind = "game"
		l.padding = l.padding * 2
		l.components =
		{
			["t-l"] = {},
			["t-r"] = {},
			["b-l"] = {},
			["b-r"] = {}
		}
		function l:suit(panel, ref, position)
			local widthAccrued = self.padding
			for i = 1, #self.components[position] do
				widthAccrued = widthAccrued + (self.components[position][i].w + self.padding)
			end
			table.insert(self.components[position], ref)

			-- Set bounds according to position:

			local x, y = panel.x, panel.y + self.padding
			if position == "t-l" or position == "b-l" then
				widthAccrued = widthAccrued
				x = x + widthAccrued
			elseif position == "t-r" or position == "b-r" then
				x = x + panel.w - widthAccrued - ref.w
			end
			if position == "b-l" or position == "b-r" then
				y = y + panel.h - (ref.h + self.padding * 2)
			end

			ref:setBounds(x, y, ref.w, ref.h)
		end
	end
	return setmetatable(l, layout)
end