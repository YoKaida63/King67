local module = {}

local EPS = 1e-7

local function isZero(x)
	return math.abs(x) < EPS
end

local function targetPosition(pos, vel, accel, t, gravity)
	return pos
		+ vel * t
		+ 0.5 * accel * t * t
		+ Vector3.new(0, -0.5 * gravity * t * t, 0)
end

local function solveInitialTime(origin, targetPos, targetVel, speed)
	local r = targetPos - origin
	local v = targetVel

	local a = v:Dot(v) - speed * speed
	local b = 2 * r:Dot(v)
	local c = r:Dot(r)

	if isZero(a) then
		if isZero(b) then return nil end
		local t = -c / b
		return t > 0 and t or nil
	end

	local d = b * b - 4 * a * c
	if d < 0 then return nil end

	local s = math.sqrt(d)
	local t1 = (-b - s) / (2 * a)
	local t2 = (-b + s) / (2 * a)

	local best = math.huge

	if t1 > 0 then best = t1 end
	if t2 > 0 and t2 < best then best = t2 end

	if best == math.huge then return nil end
	return best
end

local function refineTime(origin, speed, gravity, pos, vel, accel, t)
	for _ = 1, 10 do
		local predicted = targetPosition(pos, vel, accel, t, gravity)
		local diff = predicted - origin

		local newT = diff.Magnitude / speed
		if math.abs(newT - t) < 0.001 then
			break
		end

		t = t * 0.5 + newT * 0.5
	end

	return t
end

function module.Predict(origin, targetPos, targetVel, projectileSpeed, gravity, targetAccel)
	targetAccel = targetAccel or Vector3.zero

	local t = solveInitialTime(origin, targetPos, targetVel, projectileSpeed)

	if not t then
		t = (targetPos - origin).Magnitude / projectileSpeed
	end

	t = refineTime(origin, projectileSpeed, gravity, targetPos, targetVel, targetAccel, t)

	local predicted = targetPosition(targetPos, targetVel, targetAccel, t, gravity)

	return predicted, t
end

return module
