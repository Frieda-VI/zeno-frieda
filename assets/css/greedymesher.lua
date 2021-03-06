
--// Greedy Mesher \\--
--// Terrain Generator By Frieda_VI \\--

--// Totally Customised \\--

local ChunkSize = 16

local Resolution = 50
local Frequency = 4

local Amplitude = 10

function PositionalArray()
	local Array2D = {}
	local Reserved = {}

	for X = 0, ChunkSize, 1 do

		Array2D[X] = {}
		Reserved[X] = {}
		for Z = 0, ChunkSize, 1 do
			local YPosition = math.floor(math.noise(X/Resolution * Frequency, Z/Resolution * Frequency) * Amplitude)

			Array2D[X][Z] = YPosition
			Reserved[X][Z] = false
		end
	end

	return Array2D, Reserved
end

function GeneratePart(CoreModel: Model, Position: Vector3, SizeX: number, SizeZ: number)
	--// Aims At Creating A Part And Positioning Properly

	--// Part Creation \\--

	local Part = Instance.new("Part")

	Part.Anchored = true
	Part.Color = Color3.new(0.333333, 0.666667, 0.498039)
	--Part.BrickColor = BrickColor.random()
	Part.Material = Enum.Material.SmoothPlastic	

	Part.Name = "Voxel"
	Part.Parent = CoreModel

	--// Part Formatting \\--
	-- This Is The Main Action Of This Function

	Part.Size = Vector3.new(SizeX, 1, SizeZ) * 4
	Part.Position = Position * 4

	return Part
end

local Model = Instance.new("Model")
Model.Name = "Greedy Mesher Model"
Model.Parent = workspace

function forPart(PartElementList)
	local StartX = PartElementList.StartX
	local StartY = PartElementList.StartY

	local EndX = PartElementList.EndX
	local EndY = PartElementList.EndY

	local Height = PartElementList.DimentionalHeight

	local SizeX = EndX - StartX + 1
	local SizeY = EndY - StartY + 1

	local PositionX = (StartX + EndX) / 2
	local PositionY = (StartY + EndY) / 2

	local FinalPosition = Vector3.new(PositionX, Height, PositionY)

	local Part = GeneratePart(Model, FinalPosition, SizeX, SizeY)

	return Part
end

function Generate()
	local Array2D, Resevered = PositionalArray()

	--// Constant Creation Of Data \\--
	local PartCoordinate = {}

	for X = 0, ChunkSize, 1 do
		PartCoordinate[X] = {}
		for Y = 0, ChunkSize, 1 do
			if (not Resevered[X][Y]) then
				--// Reserving To Merging When Already Merged \\--
				Resevered[X][Y] = true

				--// Setting The Initial Start And End \\--
				--// End Variables Will Be Moved Based On The Ability To Merge Or Not \\--				
				local EndX = X
				local EndY = Y

				--// Determines The Ability To Merge Or Not \\--
				local DimentionalHeight = Array2D[X][Y]

				while (EndY < ChunkSize) do
					--// New Presevating Y For Comparision In Merging \\--
					local NewEndY = EndY + 1
					if (NewEndY > ChunkSize or Resevered[X][NewEndY]) then
						--// Y Is Bigger Than The Chunk Size  ChunkSize + 1 \\--
						--// OR \\--
						--// Y Coordinate Is Already Reserved By Another Object \\--

						--// Stops Loading Invalid Or Unsable Data \\--
						break
					end
					--// Getting The Height Of The Next Y Element \\--
					local LocalDimentionalHeight = Array2D[X][NewEndY]

					--// Comparing The Height To Determine If They Can Be Merged \\--
					if (LocalDimentionalHeight == DimentionalHeight) then
						--// Reserving The Spot To Avoid Over Lapping \\--
						--// Making The Y As The New End For Futher Continuity \\--
						Resevered[X][NewEndY] = true
						EndY = NewEndY
					else
						--// Height Does Not Match, Stop Merging \\--
						--// Stops Merching To Prevent Loading Coordinates \\--
						--// Helps To Stop Overlapping Of This Coordinate \\--
						break
					end
				end

				while (EndX < ChunkSize) do
					--// Creates A New Conservating X Value \\--
					--// Used To Find If Merging Would Be Possing From Prespective X First \\--
					local NewEndX = EndX + 1
					local RowTaken = false --// Acts As A Stopper \\--

					if (NewEndX > ChunkSize) then
						--// This X Coordinate Doesn't Exists \\--
						--// Thus This Helps To Stop Errors By Terminating The Loop \\--
						break
					end

					local RecentlyFormated = {}

					for ExtendedY = Y, EndY do
						--// Loop Goes Through Started Y To The Ending Y \\--
						if (not Resevered[NewEndX][ExtendedY] and DimentionalHeight == Array2D[NewEndX][ExtendedY]) then
							--// Checks If Not Reserved Already And Compares The Height \\--
							--// Can Proceed And Loop Won't Be Terminated Since RowTaken Acts As A Stopper \\--
							RowTaken = true

							--// Reserves The Coordinate [NewX And ExtendY] To Prevent It From Being Reused \\--
							--// Inserts To A Recently Formated List To Reset The Reserves If Could Not Merge \\--
							table.insert(RecentlyFormated, {X = NewEndX, Y = ExtendedY})
							Resevered[NewEndX][ExtendedY] = true
						else
							--// Failed Both Tests \\--
							--// Breaking Is Done To Bring It To The Initial Statement \\--	
							break
						end
					end

					if (not RowTaken) then
						--// Will Terminate The Loop Because It's Not Effective Anymore \\--
						
						for _Integer, List in pairs(RecentlyFormated) do
							for _Integer2, ExtendedList in pairs(List) do
								Resevered[ExtendedList.X][ExtendedList.Y] = false
							end
						end
						
						break
					else
						--// Increment The EndX To The New EndX To Allow Continuation \\--
						EndX = NewEndX
					end
				end

				PartCoordinate[X][Y] = {
					DimentionalHeight = DimentionalHeight,
					StartX = X,
					StartY = Y,
					EndX = EndX,
					EndY = EndY
				}
			end
		end
	end

	--// Partism Section \\--
	for X, List in pairs(PartCoordinate) do
		for Y, ExtendedList in pairs(List) do
			local Part = forPart(ExtendedList)
			
			--[[
			if X == 0 and Y == 0 then
				Part.Color = Color3.new(1, 0.552941, 0.254902)
			end
			if X == ChunkSize and Y == 0 then
				Part.Color = Color3.new(0.376471, 0.521569, 1)
			end
			]]--

		end
	end

end


Generate()
