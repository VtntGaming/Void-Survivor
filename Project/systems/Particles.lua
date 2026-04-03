local Particles = {}

local particles = {}

function Particles.spawn(x, y, color, count, speed, lifetime)
    count = count or 8
    speed = speed or 100
    lifetime = lifetime or 0.5
    for i = 1, count do
        local angle = math.random() * math.pi * 2
        local spd = speed * (0.5 + math.random() * 0.5)
        table.insert(particles, {
            x = x, y = y,
            vx = math.cos(angle) * spd,
            vy = math.sin(angle) * spd,
            life = lifetime * (0.5 + math.random() * 0.5),
            maxLife = lifetime,
            radius = 2 + math.random() * 2,
            color = color or {1, 1, 1}
        })
    end
end

function Particles.update(dt)
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.life = p.life - dt
        p.vx = p.vx * 0.98
        p.vy = p.vy * 0.98
        if p.life <= 0 then
            table.remove(particles, i)
        end
    end
end

function Particles.draw()
    for _, p in ipairs(particles) do
        local alpha = p.life / p.maxLife
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
        love.graphics.circle("fill", p.x, p.y, p.radius * alpha)
    end
    love.graphics.setColor(1, 1, 1)
end

function Particles.clear()
    particles = {}
end

return Particles
