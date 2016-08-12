Agent.destroy_all
Event.destroy_all

# Generate random employees
url = "https://randomuser.me/api/"
uri = URI.parse(url)

50.times do |i|
  response = Net::HTTP.get(uri)
  results = JSON.parse(response)["results"]
  name = "#{results[0]["name"]["first"].capitalize} #{results[0]["name"]["last"].capitalize}"
  picture_url = results[0]["picture"]["large"]
  p = rand(0)
  case p
  when 0..0.2
    position = "Manager"
  when 0.2..0.5
    position = "Consultant"
  when 0.5..1
    position = "Analyst"
  end
  Agent.create(name: name, picture_url: picture_url, position: position)
end

# Generate teams
team_names = ["Market taskforce", "Growth support", "Customer success", "Multi-channel", "Procurement", "Finance"]
team_sizes = [5, 12, 6, 8, 10, 9]

team_names.each do |t|
  Team.create(name: t)
end

current_agent_id = 1
6.times do |i|
  t = Team.find(i+1)
  team_sizes[i].times do |j|
    Staffing.create(team: t, agent: Agent.find(current_agent_id))
    current_agent_id += 1
  end
end

# Generate events
date_from  = Date.parse('2016-07-04')
date_range = date_from..Date.parse('2016-08-14')

date_range.each do |d|
  if (d.saturday? || d.sunday?)
    p = 0.1 #less likely that agents will work on week-ends
    q = 0.3 #even if there is work on the week-end, it is less than during the week
  else
    p = 1
    q = 1
  end
  Agent.all.each do |a|
    if rand(0) < p
      #go through the hours of the day, with a decreasing probability for work after hours
      (9..18).each do |h|
        if rand(0) < 0.5 * q
          if rand(0) < 0.3 then category = 'production' else category = 'communication' end
          Event.create(source: 'seed',category: category, agent: a, date: d, week: d.cweek, day: d.wday, hour: h)
        end
      end
      (19..20).each do |h|
        if rand(0) < 0.3 * q
          if rand(0) < 0.3 then category = 'production' else category = 'communication' end
          Event.create(source: 'seed',category: category, agent: a, date: d, week: d.cweek, day: d.wday, hour: h)
        end
      end
      (21..23).each do |h|
        if rand(0) < 0.1 * q
          if rand(0) < 0.3 then category = 'production' else category = 'communication' end
          Event.create(source: 'seed',category: category, agent: a, date: d, week: d.cweek, day: d.wday, hour: h)
        end
      end
    end
  end
end

# Generate policies
p = Policy.create(name: "No work on weekends", timeframe: "on weekends", adverb: "at all")
PolicySetting.create(policy: p, weight: 0.5, enabled: true)

p = Policy.create(name: "No work after 8PM", timeframe: "on weekdays", adverb: "after", hour: 20)
PolicySetting.create(policy: p, weight: 0.125, enabled: true)

p = Policy.create(name: "No work after 10PM", timeframe: "on weekdays", adverb: "after", hour: 22)
PolicySetting.create(policy: p, weight: 0.125, enabled: true)

p = Policy.create(name: "Early Friday night", timeframe: "on Fridays", adverb: "after", hour: 18)
PolicySetting.create(policy: p, weight: 0.125, enabled: true)

p = Policy.create(name: "One free night per week", timeframe: "at least once from Monday to Thursday", adverb: "after", hour: 19)
PolicySetting.create(policy: p, weight: 0.125, enabled: true)
