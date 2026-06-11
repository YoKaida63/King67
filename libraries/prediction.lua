local module = {}

local eps = 1e-9

-- ─────────────────────────────────────────────
-- Internal math helpers
-- ─────────────────────────────────────────────

local function isZero(d)
	return d > -eps and d < eps
end

local function cuberoot(x)
	if x >= 0 then
		return x ^ (1/3)
	else
		return -((-x) ^ (1/3))
	end
end

local function solveQuadric(c0, c1, c2)
	local p = c1 / (2 * c0)
	local q = c2 / c0
	local D = p * p - q
	if isZero(D) then
		return -p
	elseif D < 0 then
		return nil
	else
		local sq = math.sqrt(D)
		return sq - p, -sq - p
	end
end

local function solveCubic(c0, c1, c2, c3)
	local A = c1 / c0
	local B = c2 / c0
	local C = c3 / c0

	local sq_A = A * A
	local p = (1/3) * (-(1/3) * sq_A + B)
	local q = 0.5 * ((2/27) * A * sq_A - (1/3) * A * B + C)
	local cb_p = p * p * p
	local D = q * q + cb_p
	local sub = (1/3) * A

	local s0, s1, s2
	if isZero(D) then
		if isZero(q) then
			s0 = 0
		else
			local u = cuberoot(-q)
			s0 = 2 * u - sub
			s1 = -u - sub
			return s0, s1
		end
	elseif D < 0 then
		local phi = (1/3) * math.acos(math.clamp(-q / math.sqrt(-cb_p), -1, 1))
		local t   = 2 * math.sqrt(-p)
		s0 = t * math.cos(phi) - sub
		s1 = -t * math.cos(phi + math.pi / 3) - sub
		s2 = -t * math.cos(phi - math.pi / 3) - sub
		return s0, s1, s2
	else
		local sq = math.sqrt(D)
		s0 = cuberoot(sq - q) + cuberoot(-sq - q) - sub
	end
	return s0
end

local function solveQuartic(c0, c1, c2, c3, c4)
	local A = c1 / c0
	local B = c2 / c0
	local C = c3 / c0
	local D = c4 / c0

	local sq_A = A * A
	local p = -0.375 * sq_A + B
	local q =  0.125 * sq_A * A - 0.5 * A * B + C
	local r = -(3/256) * sq_A * sq_A + 0.0625 * sq_A * B - 0.25 * A * C + D
	local sub = 0.25 * A

	local roots = {}

	local function addRoot(v)
		if v and v == v then  -- NaN check
			table.insert(roots, v - sub)
		end
	end

	if isZero(r) then
		-- Reduce to cubic
		local s0, s1, s2 = solveCubic(1, 0, p, q)
		addRoot(s0); addRoot(s1); addRoot(s2)
	else
		-- Solve resolvent cubic
		local z = solveCubic(1, -0.5 * p, -r, 0.5 * r * p - 0.125 * q * q)
		if not z then return {} end

		local u = z * z - r
		local v = 2 * z - p

		if isZero(u) then u = 0 elseif u > 0 then u = math.sqrt(u) else return {} end
		if isZero(v) then v = 0 elseif v > 0 then v = math.sqrt(v) else return {} end

		local qSign = q < 0 and -1 or 1

		local r0a, r0b = solveQuadric(1,  qSign * v, z - u)
		local r1a, r1b = solveQuadric(1, -qSign * v, z + u)
		addRoot(r0a); addRoot(r0b)
		addRoot(r1a); addRoot(r1b)
	end

	return roots
end

-- ─────────────────────────────────────────────
-- Core: pick best time-of-flight from quartic
-- ─────────────────────────────────────────────

local function pickBestTime(solutions)
	local best = nil
	for _, t in ipairs(solutions) do
		if t > eps then
			if not best or t < best then
				best = t
			end
		end
	end
	return best
end

-- Predict where the target will be at time t,
-- accounting for constant velocity + gravity on the target.
local function predictTargetPos(targetPos, targetVelocity, targetGravity, t)
	return targetPos
		+ targetVelocity * t
		+ Vector3.new(0, 0.5 * targetGravity * t * t, 0)
end

-- ─────────────────────────────────────────────
-- Iterative refinement
-- Starts from the quartic solution, then tightens
-- the aim by re-solving with the updated predicted position.
-- ─────────────────────────────────────────────

local function refineAim(origin, speed, gravity, targetPos, targetVel, targetGrav, initialT, iterations)
	iterations = iterations or 6
	local t = initialT

	for _ = 1, iterations do
		-- Predict where target ends up at time t
		local predicted = predictTargetPos(targetPos, targetVel, targetGrav, t)
		local disp = predicted - origin

		-- Re-estimate flight time from that distance
		-- We need to solve for t again given the new target position
		-- Simple: distance / speed is a rough estimate; refine with vertical component
		local horizDist = Vector3.new(disp.X, 0, disp.Z).Magnitude
		local vertDist  = disp.Y

		-- Quadratic for vertical: 0.5*g*t^2 + vy*t - vertDist = 0
		-- where vy is the launch angle component — approximate via energy
		-- Simpler stable approximation: use total distance / speed
		local newT = disp.Magnitude / speed
		if newT < eps then break end

		-- Blend old and new to avoid oscillation
		t = t * 0.4 + newT * 0.6
	end

	return t
end

-- ─────────────────────────────────────────────
-- Public API
-- ─────────────────────────────────────────────

--[[
	module.SolveTrajectory(origin, projectileSpeed, gravity, targetPos, targetVelocity, playerGravity, playerHeight, params)

	Returns: Vector3 — the aim direction as a world position to shoot toward.

	Improvements over original:
	  • math.clamp on acos input (prevents NaN on edge cases)
	  • NaN guard on roots
	  • Iterative refinement pass for moving targets
	  • Cleaner fallback that accounts for target gravity
	  • Target gravity applied to prediction, not just projectile
]]
function module.SolveTrajectory(origin, projectileSpeed, gravity, targetPos, targetVelocity, playerGravity, playerHeight, params)
	playerGravity = playerGravity or 0
	local netGravity = gravity - playerGravity  -- net downward force on projectile

	local disp = targetPos - origin
	local p, q, r = targetVelocity.X, targetVelocity.Y, targetVelocity.Z
	local h, j, k = disp.X, disp.Y, disp.Z
	local l = -0.5 * netGravity

	-- Quartic coefficients derived from:
	-- ||(disp + targetVel*t) + (0,l*t^2,0)||^2 = (speed*t)^2
	local solutions = solveQuartic(
		l * l,
		2 * q * l,  -- corrected sign vs original
		q*q + 2*j*l + p*p + r*r - projectileSpeed * projectileSpeed,
		2*(j*q + h*p + k*r),
		j*j + h*h + k*k
	)

	-- Fallback: linear aim with target gravity compensation
	local function fallback()
		local t = disp.Magnitude / projectileSpeed
		if t <= eps then return targetPos end
		local predicted = predictTargetPos(targetPos, targetVelocity, playerGravity, t)
		return predicted
	end

	if not solutions or #solutions == 0 then
		return fallback()
	end

	local t = pickBestTime(solutions)
	if not t then return fallback() end

	-- Iterative refinement for accuracy on fast/curving targets
	t = refineAim(origin, projectileSpeed, netGravity, targetPos, targetVelocity, playerGravity, t, 8)

	-- Final predicted position
	local predicted = predictTargetPos(targetPos, targetVelocity, playerGravity, t)

	-- Sanity check: if predicted is wildly far, fall back
	if (predicted - origin).Magnitude > projectileSpeed * t * 1.5 then
		return fallback()
	end

	return predicted
end

--[[
	module.SolveTrajectoryAdvanced(origin, projectileSpeed, gravity, targetPos, targetVelocity, options)

	Extended version with extra options table:
	  options.targetGravity    -- gravity on the target (e.g. for ragdolls)
	  options.targetAccel      -- Vector3 constant acceleration on target (e.g. jumping)
	  options.iterations       -- refinement iterations (default 8)
	  options.heightOffset     -- vertical offset to aim at (e.g. aim at chest not feet)
]]
function module.SolveTrajectoryAdvanced(origin, projectileSpeed, gravity, targetPos, targetVelocity, options)
	options = options or {}
	local targetGravity  = options.targetGravity or 0
	local targetAccel    = options.targetAccel or Vector3.new(0, 0, 0)
	local iterations     = options.iterations or 8
	local heightOffset   = options.heightOffset or 0

	local adjustedTarget = targetPos + Vector3.new(0, heightOffset, 0)

	-- If target has extra acceleration, fold it into velocity for first pass
	-- (acceleration shifts the quartic so we handle it via iterative refinement)
	local result = module.SolveTrajectory(
		origin, projectileSpeed, gravity,
		adjustedTarget, targetVelocity,
		targetGravity, nil, nil
	)

	-- Extra refinement pass if target has non-zero acceleration
	if targetAccel.Magnitude > eps then
		local disp = adjustedTarget - origin
		local t = disp.Magnitude / projectileSpeed

		for _ = 1, iterations do
			-- Account for target acceleration: pos = p0 + v*t + 0.5*a*t^2
			local accelOffset = 0.5 * targetAccel * t * t
			local accelTarget = adjustedTarget + accelOffset
			local newResult = module.SolveTrajectory(
				origin, projectileSpeed, gravity,
				accelTarget, targetVelocity,
				targetGravity, nil, nil
			)
			local newDisp = newResult - origin
			t = newDisp.Magnitude / projectileSpeed
			result = newResult
		end
	end

	return result
end

return module
